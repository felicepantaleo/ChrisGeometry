from pathlib import Path

from hgcalgeom.cli import main


def test_cli_encode_detid(capsys):
    exit_code = main([
        "encode-detid",
        "--wafer-u",
        "-3",
        "--wafer-v",
        "5",
        "--cell-u",
        "7",
        "--cell-v",
        "9",
        "--layer",
        "30",
    ])
    captured = capsys.readouterr()

    assert exit_code == 0
    assert captured.out.startswith("0x")


def test_cli_decode_detid(capsys):
    exit_code = main(["decode-detid", "0x90000000"])
    captured = capsys.readouterr()

    assert exit_code == 0
    assert '"detector"' in captured.out
    assert '"raw"' in captured.out


def test_cli_neighbours(capsys):
    exit_code = main(["neighbours", "0x90000287"])
    captured = capsys.readouterr()

    assert exit_code == 0
    assert "[" in captured.out
    assert "0x" in captured.out


def test_cli_draw_flatfile(tmp_path: Path):
    input_file = tmp_path / "flat.txt"
    output_file = tmp_path / "layer.svg"
    input_file.write_text("0 0 0.0 0.0\n1 0 2.0 0.0\n", encoding="utf-8")

    exit_code = main(["draw-flatfile", str(input_file), str(output_file), "--wafer-side", "1.0"])

    assert exit_code == 0
    assert output_file.exists()
    assert output_file.read_text(encoding="utf-8").count("<polygon") == 2
