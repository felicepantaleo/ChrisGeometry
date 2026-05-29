"""Simple SVG exporters for geometry objects."""

from __future__ import annotations

from pathlib import Path
from xml.sax.saxutils import escape

from .geometry import Point, Wafer
from .tile import Tile


def _points_attr(points: list[Point]) -> str:
    return " ".join(f"{p.x:.6g},{-p.y:.6g}" for p in points)


def write_wafers_svg(wafers: list[Wafer], output: str | Path, *, title: str = "HGCAL layer") -> None:
    """Write a minimal SVG view of a wafer collection."""

    if not wafers:
        raise ValueError("Cannot draw an empty wafer collection")

    all_points = [p for wafer in wafers for p in wafer.corners()]
    min_x = min(p.x for p in all_points)
    max_x = max(p.x for p in all_points)
    min_y = min(p.y for p in all_points)
    max_y = max(p.y for p in all_points)
    width = max_x - min_x
    height = max_y - min_y
    pad = 0.05 * max(width, height, 1.0)
    view_box = f"{min_x - pad:.6g} {-max_y - pad:.6g} {width + 2 * pad:.6g} {height + 2 * pad:.6g}"

    lines = [
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
        f"<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"{view_box}\">",
        f"  <title>{escape(title)}</title>",
        "  <g fill=\"none\" stroke=\"black\" stroke-width=\"0.5\">",
    ]
    for wafer in wafers:
        klass = "LD" if wafer.is_ld else "HD"
        partial = " partial" if wafer.is_partial else ""
        lines.append(f"    <polygon class=\"{klass}{partial}\" points=\"{_points_attr(wafer.corners())}\"/>")
    lines.extend(["  </g>", "</svg>"])
    Path(output).write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_tiles_svg(tiles: list[Tile], output: str | Path, *, title: str = "HGCAL scintillator tiles") -> None:
    """Write an SVG view of expanded scintillator tile sectors."""

    if not tiles:
        raise ValueError("Cannot draw an empty tile collection")

    all_points = [point for tile in tiles for point in tile.corners()]
    min_x = min(p.x for p in all_points)
    max_x = max(p.x for p in all_points)
    min_y = min(p.y for p in all_points)
    max_y = max(p.y for p in all_points)
    width = max_x - min_x
    height = max_y - min_y
    pad = 0.03 * max(width, height, 1.0)
    view_box = f"{min_x - pad:.6g} {-max_y - pad:.6g} {width + 2 * pad:.6g} {height + 2 * pad:.6g}"

    lines = [
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
        f"<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"{view_box}\">",
        f"  <title>{escape(title)}</title>",
        "  <g fill=\"none\" stroke=\"black\" stroke-width=\"0.35\">",
    ]
    for tile in tiles:
        klass = "cast" if tile.production == "c" else "moulded"
        lines.append(f"    <polygon class=\"tile {klass}\" points=\"{_points_attr(tile.corners())}\"/>")
    lines.extend(["  </g>", "</svg>"])
    Path(output).write_text("\n".join(lines) + "\n", encoding="utf-8")
