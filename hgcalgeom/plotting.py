"""Simple SVG exporters for geometry objects."""

from __future__ import annotations

from pathlib import Path
from xml.sax.saxutils import escape

from .cells import SiliconCell
from .geometry import Point, Wafer
from .tile import Tile


def _points_attr(points: list[Point]) -> str:
    return " ".join(f"{p.x:.6g},{-p.y:.6g}" for p in points)


def _bounds(polygons: list[list[Point]]) -> tuple[float, float, float, float]:
    all_points = [point for polygon in polygons for point in polygon]
    min_x = min(p.x for p in all_points)
    max_x = max(p.x for p in all_points)
    min_y = min(p.y for p in all_points)
    max_y = max(p.y for p in all_points)
    return min_x, max_x, min_y, max_y


def _view_box(polygons: list[list[Point]], *, pad_fraction: float = 0.05) -> str:
    min_x, max_x, min_y, max_y = _bounds(polygons)
    width = max_x - min_x
    height = max_y - min_y
    pad = pad_fraction * max(width, height, 1.0)
    return f"{min_x - pad:.6g} {-max_y - pad:.6g} {width + 2 * pad:.6g} {height + 2 * pad:.6g}"


def write_wafers_svg(wafers: list[Wafer], output: str | Path, *, title: str = "HGCAL layer") -> None:
    """Write a minimal SVG view of a wafer collection."""

    if not wafers:
        raise ValueError("Cannot draw an empty wafer collection")

    lines = [
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
        f"<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"{_view_box([w.corners() for w in wafers])}\">",
        f"  <title>{escape(title)}</title>",
        "  <g fill=\"none\" stroke=\"black\" stroke-width=\"0.5\">",
    ]
    for wafer in wafers:
        klass = "LD" if wafer.is_ld else "HD"
        partial = " partial" if wafer.is_partial else ""
        lines.append(f"    <polygon class=\"{klass}{partial}\" points=\"{_points_attr(wafer.corners())}\"/>")
    lines.extend(["  </g>", "</svg>"])
    Path(output).write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_cells_svg(cells: list[SiliconCell], output: str | Path, *, title: str = "HGCAL silicon cells") -> None:
    """Write an SVG view of regular silicon cells."""

    if not cells:
        raise ValueError("Cannot draw an empty cell collection")

    lines = [
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
        f"<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"{_view_box([c.corners() for c in cells])}\">",
        f"  <title>{escape(title)}</title>",
        "  <g fill=\"none\" stroke=\"black\" stroke-width=\"0.12\">",
    ]
    for cell in cells:
        klass = "LD" if cell.is_ld else "HD"
        partial = " partial" if cell.wafer_type else ""
        lines.append(f"    <polygon class=\"cell {klass}{partial}\" points=\"{_points_attr(cell.corners())}\"/>")
    lines.extend(["  </g>", "</svg>"])
    Path(output).write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_tiles_svg(tiles: list[Tile], output: str | Path, *, title: str = "HGCAL scintillator tiles") -> None:
    """Write an SVG view of expanded scintillator tile sectors."""

    if not tiles:
        raise ValueError("Cannot draw an empty tile collection")

    lines = [
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
        f"<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"{_view_box([t.corners() for t in tiles], pad_fraction=0.03)}\">",
        f"  <title>{escape(title)}</title>",
        "  <g fill=\"none\" stroke=\"black\" stroke-width=\"0.35\">",
    ]
    for tile in tiles:
        klass = "cast" if tile.production == "c" else "moulded"
        lines.append(f"    <polygon class=\"tile {klass}\" points=\"{_points_attr(tile.corners())}\"/>")
    lines.extend(["  </g>", "</svg>"])
    Path(output).write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_combined_layer_svg(
    output: str | Path,
    *,
    wafers: list[Wafer] | None = None,
    cells: list[SiliconCell] | None = None,
    tiles: list[Tile] | None = None,
    title: str = "HGCAL layer",
    show_wafers: bool = True,
    show_cells: bool = False,
    show_tiles: bool = False,
) -> None:
    """Write a combined silicon-wafer/cell and scintillator-tile SVG."""

    wafers = wafers or []
    cells = cells or []
    tiles = tiles or []

    polygons: list[list[Point]] = []
    if show_tiles:
        polygons.extend(tile.corners() for tile in tiles)
    if show_wafers:
        polygons.extend(wafer.corners() for wafer in wafers)
    if show_cells:
        polygons.extend(cell.corners() for cell in cells)
    if not polygons:
        raise ValueError("Cannot draw an empty layer")

    lines = [
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
        f"<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"{_view_box(polygons, pad_fraction=0.03)}\">",
        f"  <title>{escape(title)}</title>",
    ]

    if show_tiles and tiles:
        lines.append("  <g id=\"tiles\" fill=\"none\" stroke=\"black\" stroke-width=\"0.35\">")
        for tile in tiles:
            klass = "cast" if tile.production == "c" else "moulded"
            lines.append(f"    <polygon class=\"tile {klass}\" points=\"{_points_attr(tile.corners())}\"/>")
        lines.append("  </g>")

    if show_cells and cells:
        lines.append("  <g id=\"silicon-cells\" fill=\"none\" stroke=\"black\" stroke-width=\"0.08\">")
        for cell in cells:
            klass = "LD" if cell.is_ld else "HD"
            partial = " partial" if cell.wafer_type else ""
            lines.append(f"    <polygon class=\"cell {klass}{partial}\" points=\"{_points_attr(cell.corners())}\"/>")
        lines.append("  </g>")

    if show_wafers and wafers:
        lines.append("  <g id=\"silicon-wafers\" fill=\"none\" stroke=\"black\" stroke-width=\"0.5\">")
        for wafer in wafers:
            klass = "LD" if wafer.is_ld else "HD"
            partial = " partial" if wafer.is_partial else ""
            lines.append(f"    <polygon class=\"wafer {klass}{partial}\" points=\"{_points_attr(wafer.corners())}\"/>")
        lines.append("  </g>")

    lines.append("</svg>")
    Path(output).write_text("\n".join(lines) + "\n", encoding="utf-8")
