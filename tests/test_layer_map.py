from pathlib import Path

from hgcalgeom.layer_map import guess_wafers_from_records, read_records


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
