from math import isclose, sqrt
from pathlib import Path

from hgcalgeom.layer_map import (
    DEFAULT_WAFER_SIDE_MM,
    guess_wafers_from_records,
    parse_chris_geometry,
    parse_silicon_headers,
    read_records,
)


def test_read_records_skips_empty_and_comment_lines(tmp_path: Path):
    path = tmp_path / "geometry.txt"
    path.write_text(
        "\n"
        "# comment\n"
        "1 2 3.5 -4.5 token\n"
        "5, 6, 7.0, 8.0\n",
        encoding="utf-8",
    )

    records = read_records(path)

    assert len(records) == 2
    assert records[0].line_number == 3
    assert records[0].numbers == (1.0, 2.0, 3.5, -4.5)
    assert records[1].line_number == 4
    assert records[1].numbers == (5.0, 6.0, 7.0, 8.0)


def test_read_records_understands_scientific_notation(tmp_path: Path):
    path = tmp_path / "numbers.txt"
    path.write_text("-1 +2 3.0e2 -4.5E-1\n", encoding="utf-8")

    records = read_records(path)

    assert records[0].numbers == (-1.0, 2.0, 300.0, -0.45)


def test_guess_wafers_from_records_uses_first_four_numeric_columns(tmp_path: Path):
    path = tmp_path / "geometry.txt"
    path.write_text("-2 3 10.5 -20.25 99 100\n", encoding="utf-8")
    records = read_records(path)

    wafers = guess_wafers_from_records(records, wafer_side=12.3)

    assert len(wafers) == 1
    wafer = wafers[0]
    assert wafer.u == -2
    assert wafer.v == 3
    assert wafer.center.x == 10.5
    assert wafer.center.y == -20.25
    assert wafer.side == 12.3
    assert wafer.file_line == 1
    assert wafer.metadata["raw"] == "-2 3 10.5 -20.25 99 100"


def test_guess_wafers_ignores_records_with_too_few_numbers(tmp_path: Path):
    path = tmp_path / "geometry.txt"
    path.write_text("1 2 3\n1 2 3 4\n", encoding="utf-8")
    records = read_records(path)

    wafers = guess_wafers_from_records(records)

    assert len(wafers) == 1
    assert wafers[0].u == 1
    assert wafers[0].v == 2


def test_parse_silicon_headers(tmp_path: Path):
    path = tmp_path / "modmap.txt"
    path.write_text(
        "1 0 4.10 2.37 0.00 4.73 -4.10 2.37 -4.10 -2.37 -0.00 -4.73 4.10 -2.37\n"
        "27 0 h120 -85.98 442.19 1 1 3 4\n",
        encoding="utf-8",
    )

    headers = parse_silicon_headers(path)

    assert len(headers) == 1
    assert headers[0].layer == 1
    assert headers[0].layer_type == 0
    assert headers[0].layer_type_name.startswith("wafer-centred")
    assert len(headers[0].cassette_retractions) == 6
    assert headers[0].cassette_retractions[0].x == 4.10
    assert headers[0].cassette_retractions[0].y == 2.37


def test_parse_chris_geometry_documented_nine_column_format(tmp_path: Path):
    path = tmp_path / "modmap.txt"
    path.write_text(
        "27 0 h120 -85.98 442.19 1 1 3 4\n"
        "27 3 l300 502.92 -1456.53 2 -2 -10 5\n"
        "28 0 h200 1.0 2.0 3 4 5 6\n",
        encoding="utf-8",
    )

    wafers = parse_chris_geometry(path, layer=27)

    assert len(wafers) == 2
    assert wafers[0].u == 1
    assert wafers[0].v == 3
    assert wafers[0].center.x == -85.98
    assert wafers[0].center.y == 442.19
    assert wafers[0].placement == 1
    assert wafers[0].cassette == 4
    assert not wafers[0].is_ld
    assert not wafers[0].is_partial
    assert wafers[0].metadata["wafer_type_name"] == "Full"

    assert wafers[1].u == -2
    assert wafers[1].v == -10
    assert wafers[1].cassette == 5
    assert wafers[1].is_ld
    assert wafers[1].is_partial
    assert wafers[1].partial_type == 3
    assert wafers[1].metadata["wafer_type_name"] == "Left"


def test_parse_chris_geometry_accepts_old_eight_column_dump(tmp_path: Path):
    path = tmp_path / "old.txt"
    path.write_text("1 0 h120 502.32 0.00 0 3 0\n", encoding="utf-8")

    wafers = parse_chris_geometry(path)

    assert len(wafers) == 1
    assert wafers[0].cassette is None
    assert wafers[0].u == 3
    assert wafers[0].v == 0


def test_default_wafer_side_comes_from_layout_width():
    assert isclose(DEFAULT_WAFER_SIDE_MM, 167.4408 / sqrt(3.0), rel_tol=1.0e-15)
