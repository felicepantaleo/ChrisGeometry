from pathlib import Path

import pytest

from hgcalgeom.geometry import Point, Wafer
from hgcalgeom.plotting import write_wafers_svg


def test_write_wafers_svg_creates_svg_file(tmp_path: Path):
    output = tmp_path / "layer.svg"
    wafers = [
        Wafer(u=0, v=0, center=Point(0.0, 0.0), side=1.0),
        Wafer(u=1, v=0, center=Point(2.0, 0.0), side=1.0, is_ld=True, is_partial=True),
    ]

    write_wafers_svg(wafers, output, title="Layer & test")

    text = output.read_text(encoding="utf-8")
    assert text.startswith("<?xml")
    assert "<svg" in text
    assert "Layer &amp; test" in text
    assert text.count("<polygon") == 2
    assert "class=\"HD\"" in text
    assert "class=\"LD partial\"" in text


def test_write_wafers_svg_rejects_empty_input(tmp_path: Path):
    with pytest.raises(ValueError, match="empty wafer"):
        write_wafers_svg([], tmp_path / "empty.svg")
