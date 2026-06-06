"""Simple SVG and PDF exporters for geometry objects."""

from __future__ import annotations

from pathlib import Path
from xml.sax.saxutils import escape

from .cells import SiliconCell, partial_wafer_polygon
from .geometry import Point, Wafer
from .tile import Tile


SILICON_FILL = {
    "h120": "#dcdcdc",  # light grey  — HD 120 µm
    "h200": "#F703FE",
    "l200": "#FA0203",
    "l300": "#0BE513",
}
THICKNESS_LABELS = [
    ("h120", "HD 120 µm"),
    ("h200", "HD 200 µm"),
    ("l200", "LD 200 µm"),
    ("l300", "LD 300 µm"),
]
# ObjC uses three blues for tiles: base fadedBlue, with pastelBlue on every
# 10th complete ring and paleBlue on every 5th (matching HXGLayerMapFiles.m).
TILE_FILL_BASE = "#cce6ff"   # fadedBlue  — all tiles
TILE_FILL_FIVES = "#9ebfe3"  # paleBlue   — complete rings where (ring+1) % 5 == 0
TILE_FILL_TENS = "#47a6ff"   # pastelBlue — complete rings where (ring+1) % 10 == 0


def _tile_fill(tile: "Tile") -> str:
    if tile.is_complete_ring:
        r1 = tile.ring + 1  # file is 0-indexed; ObjC displays 1-indexed
        if r1 % 10 == 0:
            return TILE_FILL_TENS
        if r1 % 5 == 0:
            return TILE_FILL_FIVES
    return TILE_FILL_BASE


def _points_attr(points: list[Point]) -> str:
    return " ".join(f"{p.x:.6g},{-p.y:.6g}" for p in points)


def _bounds(polygons: list[list[Point]]) -> tuple[float, float, float, float]:
    all_points = [point for polygon in polygons for point in polygon]
    min_x = min(p.x for p in all_points)
    max_x = max(p.x for p in all_points)
    min_y = min(p.y for p in all_points)
    max_y = max(p.y for p in all_points)
    return min_x, max_x, min_y, max_y


def _view_box(polygons: list[list[Point]], *, pad_fraction: float = 0.05, extra_right: float = 0.0) -> str:
    min_x, max_x, min_y, max_y = _bounds(polygons)
    width = max_x - min_x
    height = max_y - min_y
    pad = pad_fraction * max(width, height, 1.0)
    return f"{min_x - pad:.6g} {-max_y - pad:.6g} {width + 2 * pad + extra_right:.6g} {height + 2 * pad:.6g}"


def _sensor_fill(sensor_type: str | None) -> str:
    return SILICON_FILL.get((sensor_type or "").lower(), "#ffffff")


def _wafer_fill(wafer: Wafer) -> str:
    sensor_type = wafer.metadata.get("sensor_type")
    return _sensor_fill(sensor_type if isinstance(sensor_type, str) else None)


def _cell_fill(cell: SiliconCell) -> str:
    return _sensor_fill(cell.sensor_type)


def _hex_to_rgb01(value: str) -> tuple[float, float, float]:
    value = value.lstrip("#")
    return tuple(int(value[i : i + 2], 16) / 255.0 for i in (0, 2, 4))  # type: ignore[return-value]


def _draw_pdf_polygon(canvas, points: list[Point], *, fill: str | None, stroke: str = "#000000", stroke_width: float = 0.2, mapper) -> None:
    if len(points) < 3:
        return
    path = canvas.beginPath()
    x0, y0 = mapper(points[0])
    path.moveTo(x0, y0)
    for point in points[1:]:
        x, y = mapper(point)
        path.lineTo(x, y)
    path.close()
    canvas.setLineWidth(stroke_width)
    canvas.setStrokeColorRGB(*_hex_to_rgb01(stroke))
    if fill is None:
        canvas.drawPath(path, stroke=1, fill=0)
    else:
        canvas.setFillColorRGB(*_hex_to_rgb01(fill))
        canvas.drawPath(path, stroke=1, fill=1)


def _combined_polygons(
    *,
    wafers: list[Wafer],
    cells: list[SiliconCell],
    tiles: list[Tile],
    show_wafers: bool,
    show_cells: bool,
    show_tiles: bool,
) -> list[list[Point]]:
    polygons: list[list[Point]] = []
    if show_tiles:
        polygons.extend(tile.corners() for tile in tiles)
    if show_wafers:
        polygons.extend(partial_wafer_polygon(wafer) for wafer in wafers)
    if show_cells:
        polygons.extend(cell.corners() for cell in cells)
    return polygons


def _legend_panel_w(span: float) -> float:
    """Width to reserve (in data units) to the right of the drawing for the legend."""
    entry_h = span * 0.042
    swatch_w = entry_h * 1.8
    gap = entry_h * 0.22
    font_size = entry_h * 0.60
    text_w = 9 * 0.58 * font_size  # 9 chars for longest label
    return swatch_w + gap + text_w + gap * 5  # extra padding


def _svg_legend(panel_x: float, svg_cy: float, span: float) -> str:
    """Return SVG legend markup, placed in a panel to the right of the data.

    panel_x : left edge of the legend panel in data-x / SVG-x coordinates.
    svg_cy  : vertical centre of the drawing in SVG coordinates (y-inverted).
    span    : characteristic size of the drawing (for scaling).
    """
    entry_h = span * 0.042
    swatch_w = entry_h * 1.8
    gap = entry_h * 0.22
    font_size = entry_h * 0.60
    text_w = 9 * 0.58 * font_size
    legend_w = swatch_w + gap + text_w
    stroke_w = max(span * 0.0015, 0.1)
    total_h = len(THICKNESS_LABELS) * (entry_h + gap) - gap
    bg_pad = gap * 0.8
    lx = panel_x + gap * 1.5
    ly = svg_cy - total_h * 0.5
    lines = [
        f'  <g id="legend" font-family="sans-serif" font-size="{font_size:.4g}">',
        f'    <rect x="{lx - bg_pad:.4g}" y="{ly - bg_pad:.4g}" '
        f'width="{legend_w + 2 * bg_pad:.4g}" height="{total_h + 2 * bg_pad:.4g}" '
        f'fill="white" fill-opacity="0.92" stroke="#888" stroke-width="{stroke_w:.3g}" rx="{bg_pad:.3g}"/>',
    ]
    yi = ly
    for key, label in THICKNESS_LABELS:
        color = SILICON_FILL.get(key, "#ffffff")
        lines += [
            f'    <rect x="{lx:.4g}" y="{yi:.4g}" width="{swatch_w:.4g}" height="{entry_h:.4g}" '
            f'fill="{color}" stroke="#888" stroke-width="{stroke_w:.3g}" rx="{entry_h * 0.12:.3g}"/>',
            f'    <text x="{lx + swatch_w + gap:.4g}" y="{yi + entry_h * 0.73:.4g}" '
            f'fill="#111">{escape(label)}</text>',
        ]
        yi += entry_h + gap
    lines.append('  </g>')
    return "\n".join(lines)


def _pdf_legend(canvas, page_w: float, page_h: float, margin: float) -> None:
    """Draw a thickness colour legend in the bottom-right corner of the page."""
    entry_h = 13.0
    swatch_w = 26.0
    gap = 2.5
    font_size = 7.5
    text_col_w = 68.0
    total_h = len(THICKNESS_LABELS) * (entry_h + gap) - gap
    legend_w = swatch_w + gap + text_col_w
    bg_pad = gap
    lx = page_w - margin - legend_w
    ly = margin
    canvas.setStrokeColorRGB(0.53, 0.53, 0.53)
    canvas.setFillColorRGB(1, 1, 1)
    canvas.setLineWidth(0.5)
    canvas.roundRect(lx - bg_pad, ly - bg_pad, legend_w + 2 * bg_pad, total_h + 2 * bg_pad, bg_pad, fill=1)
    canvas.setFont("Helvetica", font_size)
    yi = ly + total_h - entry_h
    for key, label in THICKNESS_LABELS:
        r, g, b = _hex_to_rgb01(SILICON_FILL.get(key, "#ffffff"))
        canvas.setFillColorRGB(r, g, b)
        canvas.setStrokeColorRGB(0.53, 0.53, 0.53)
        canvas.setLineWidth(0.35)
        canvas.roundRect(lx, yi, swatch_w, entry_h, 1.5, fill=1)
        canvas.setFillColorRGB(0.07, 0.07, 0.07)
        canvas.drawString(lx + swatch_w + gap, yi + 3.5, label)
        yi -= entry_h + gap


def write_wafers_svg(wafers: list[Wafer], output: str | Path, *, title: str = "HGCAL layer") -> None:
    if not wafers:
        raise ValueError("Cannot draw an empty wafer collection")
    polys = [partial_wafer_polygon(w) for w in wafers]
    min_x, max_x, min_y, max_y = _bounds(polys)
    span = max(max_x - min_x, max_y - min_y, 1.0)
    pad = 0.05 * span
    panel_w = _legend_panel_w(span)
    vb = _view_box(polys, extra_right=panel_w)
    svg_cy = -(min_y + max_y) * 0.5
    lines = [
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
        f"<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"{vb}\">",
        f"  <title>{escape(title)}</title>",
        "  <g fill-opacity=\"0.80\" stroke=\"#333\" stroke-width=\"0.5\">",
    ]
    for wafer, poly in zip(wafers, polys):
        klass = "LD" if wafer.is_ld else "HD"
        partial = " partial" if wafer.is_partial else ""
        lines.append(
            f"    <polygon class=\"{klass}{partial}\" fill=\"{_wafer_fill(wafer)}\" "
            f"points=\"{_points_attr(poly)}\"/>"
        )
    lines.extend(["  </g>", _svg_legend(max_x + pad, svg_cy, span), "</svg>"])
    Path(output).write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_cells_svg(cells: list[SiliconCell], output: str | Path, *, title: str = "HGCAL silicon cells") -> None:
    if not cells:
        raise ValueError("Cannot draw an empty cell collection")
    corners_list = [c.corners() for c in cells]
    min_x, max_x, min_y, max_y = _bounds(corners_list)
    span = max(max_x - min_x, max_y - min_y, 1.0)
    pad = 0.05 * span
    panel_w = _legend_panel_w(span)
    vb = _view_box(corners_list, extra_right=panel_w)
    svg_cy = -(min_y + max_y) * 0.5
    lines = [
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
        f"<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"{vb}\">",
        f"  <title>{escape(title)}</title>",
        "  <g fill-opacity=\"0.85\" stroke=\"#333\" stroke-width=\"0.12\">",
    ]
    for cell, corners in zip(cells, corners_list):
        klass = "LD" if cell.is_ld else "HD"
        partial = " partial" if cell.wafer_type else ""
        lines.append(
            f"    <polygon class=\"cell {klass}{partial}\" fill=\"{_cell_fill(cell)}\" "
            f"points=\"{_points_attr(corners)}\"/>"
        )
    lines.extend(["  </g>", _svg_legend(max_x + pad, svg_cy, span), "</svg>"])
    Path(output).write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_tiles_svg(tiles: list[Tile], output: str | Path, *, title: str = "HGCAL scintillator tiles") -> None:
    if not tiles:
        raise ValueError("Cannot draw an empty tile collection")
    lines = [
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
        f"<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"{_view_box([t.corners() for t in tiles], pad_fraction=0.03)}\">",
        f"  <title>{escape(title)}</title>",
        "  <g fill-opacity=\"0.68\" stroke=\"black\" stroke-width=\"0.35\">",
    ]
    for tile in tiles:
        klass = "cast" if tile.production == "c" else "moulded"
        lines.append(
            f"    <polygon class=\"tile {klass}\" fill=\"{_tile_fill(tile)}\" "
            f"points=\"{_points_attr(tile.corners())}\"/>"
        )
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
    wafers = wafers or []
    cells = cells or []
    tiles = tiles or []
    polygons = _combined_polygons(wafers=wafers, cells=cells, tiles=tiles, show_wafers=show_wafers, show_cells=show_cells, show_tiles=show_tiles)
    if not polygons:
        raise ValueError("Cannot draw an empty layer")
    min_x, max_x, min_y, max_y = _bounds(polygons)
    span = max(max_x - min_x, max_y - min_y, 1.0)
    pad = 0.03 * span
    panel_w = _legend_panel_w(span) if (wafers or cells) else 0.0
    vb = _view_box(polygons, pad_fraction=0.03, extra_right=panel_w)
    svg_cy = -(min_y + max_y) * 0.5
    lines = [
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
        f"<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"{vb}\">",
        f"  <title>{escape(title)}</title>",
    ]
    if show_tiles and tiles:
        lines.append("  <g id=\"tiles\" fill-opacity=\"0.55\" stroke=\"black\" stroke-width=\"0.35\">")
        for tile in tiles:
            klass = "cast" if tile.production == "c" else "moulded"
            lines.append(
                f"    <polygon class=\"tile {klass}\" fill=\"{_tile_fill(tile)}\" "
                f"points=\"{_points_attr(tile.corners())}\"/>"
            )
        lines.append("  </g>")
    # Wafers drawn first so cells render on top and remain visible
    if show_wafers and wafers:
        # When cells are also shown they cover the wafer fill; keep it for shape context
        wafer_fill_opacity = "0.45" if (show_cells and cells) else "0.80"
        lines.append(f"  <g id=\"silicon-wafers\" fill-opacity=\"{wafer_fill_opacity}\" stroke=\"#333\" stroke-width=\"0.55\">")
        for wafer in wafers:
            klass = "LD" if wafer.is_ld else "HD"
            partial = " partial" if wafer.is_partial else ""
            lines.append(
                f"    <polygon class=\"wafer {klass}{partial}\" fill=\"{_wafer_fill(wafer)}\" "
                f"points=\"{_points_attr(partial_wafer_polygon(wafer))}\"/>"
            )
        lines.append("  </g>")
    # Cells drawn after wafers so they are visible on top
    if show_cells and cells:
        lines.append("  <g id=\"silicon-cells\" fill-opacity=\"0.85\" stroke=\"#888\" stroke-width=\"0.08\">")
        for cell in cells:
            klass = "LD" if cell.is_ld else "HD"
            partial = " partial" if cell.wafer_type else ""
            lines.append(
                f"    <polygon class=\"cell {klass}{partial}\" fill=\"{_cell_fill(cell)}\" "
                f"points=\"{_points_attr(cell.corners())}\"/>"
            )
        lines.append("  </g>")
    if wafers or cells:
        lines.append(_svg_legend(max_x + pad, svg_cy, span))
    lines.append("</svg>")
    Path(output).write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_combined_layer_pdf(
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
    try:
        from reportlab.lib.pagesizes import A4, landscape
        from reportlab.pdfgen import canvas as reportlab_canvas
    except ImportError as exc:
        raise RuntimeError("PDF export requires reportlab. Install with: python3 -m pip install reportlab") from exc

    wafers = wafers or []
    cells = cells or []
    tiles = tiles or []
    polygons = _combined_polygons(wafers=wafers, cells=cells, tiles=tiles, show_wafers=show_wafers, show_cells=show_cells, show_tiles=show_tiles)
    if not polygons:
        raise ValueError("Cannot draw an empty layer")

    page_w, page_h = landscape(A4)
    margin = 24.0
    min_x, max_x, min_y, max_y = _bounds(polygons)
    data_w = max_x - min_x
    data_h = max_y - min_y
    scale = min((page_w - 2.0 * margin) / data_w, (page_h - 2.0 * margin) / data_h)
    offset_x = 0.5 * (page_w - scale * data_w) - scale * min_x
    offset_y = 0.5 * (page_h - scale * data_h) - scale * min_y

    def mapper(point: Point) -> tuple[float, float]:
        return offset_x + scale * point.x, offset_y + scale * point.y

    c = reportlab_canvas.Canvas(str(output), pagesize=landscape(A4))
    c.setTitle(title)
    c.setFont("Helvetica", 8)
    c.drawString(margin, page_h - 14.0, title)

    if show_tiles and tiles:
        for tile in tiles:
            _draw_pdf_polygon(c, tile.corners(), fill=_tile_fill(tile), stroke="#000000", stroke_width=0.12, mapper=mapper)
    # Wafers drawn first; cells drawn on top so the cell grid is visible
    if show_wafers and wafers:
        alpha_fill = _wafer_fill  # always fill with thickness colour
        for wafer in wafers:
            _draw_pdf_polygon(c, partial_wafer_polygon(wafer), fill=alpha_fill(wafer), stroke="#333333", stroke_width=0.22, mapper=mapper)
    if show_cells and cells:
        for cell in cells:
            _draw_pdf_polygon(c, cell.corners(), fill=_cell_fill(cell), stroke="#888888", stroke_width=0.035, mapper=mapper)
    if wafers or cells:
        _pdf_legend(c, page_w, page_h, margin)

    c.showPage()
    c.save()
