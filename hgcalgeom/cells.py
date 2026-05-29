"""Silicon cell generation for LD and HD wafers.

This module builds regular grid-cell geometry for full wafers and clips those
cells to approximate partial-wafer polygons. The exact Zoltan/mouse-bite edge
shapes are still a later refinement, but partial wafers are no longer drawn as
full pre-dicing hexagons.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import cos, pi, sin, sqrt

from .geometry import Point, Wafer, polygon_area
from .interface import default_cell_set
from .layer_map import DEFAULT_WAFER_SIDE_MM


DENSITY_LD = 8
DENSITY_HD = 12
MIN_POLYGON_AREA_MM2 = 1.0e-6


def _rotate_offset(dx: float, dy: float, angle_rad: float) -> tuple[float, float]:
    c = cos(angle_rad)
    s = sin(angle_rad)
    return c * dx - s * dy, s * dx + c * dy


def _flat_top_hex_offsets(side: float, angle_rad: float = 0.0) -> list[tuple[float, float]]:
    """Return flat-top hexagon offsets, optionally rotated."""

    h = sqrt(0.75) * side
    offsets = [
        (side, 0.0),
        (0.5 * side, h),
        (-0.5 * side, h),
        (-side, 0.0),
        (-0.5 * side, -h),
        (0.5 * side, -h),
    ]
    if angle_rad == 0.0:
        return offsets
    return [_rotate_offset(dx, dy, angle_rad) for dx, dy in offsets]


def _signed_area(points: list[Point]) -> float:
    if len(points) < 3:
        return 0.0
    total = 0.0
    for a, b in zip(points, points[1:] + points[:1]):
        total += a.x * b.y - b.x * a.y
    return 0.5 * total


def _ensure_ccw(points: list[Point]) -> list[Point]:
    return points if _signed_area(points) >= 0.0 else list(reversed(points))


def _intersection(a: Point, b: Point, p: Point, q: Point) -> Point:
    ax = b.x - a.x
    ay = b.y - a.y
    bx = q.x - p.x
    by = q.y - p.y
    denom = ax * by - ay * bx
    if abs(denom) < 1.0e-12:
        return b
    t = ((p.x - a.x) * by - (p.y - a.y) * bx) / denom
    return Point(a.x + t * ax, a.y + t * ay)


def _inside_half_plane(point: Point, edge_start: Point, edge_end: Point) -> bool:
    return (edge_end.x - edge_start.x) * (point.y - edge_start.y) - (edge_end.y - edge_start.y) * (
        point.x - edge_start.x
    ) >= -1.0e-9


def clip_polygon(subject: list[Point], clip: list[Point]) -> list[Point]:
    """Clip a polygon by a convex polygon using Sutherland-Hodgman."""

    output = _ensure_ccw(subject)
    clip_ccw = _ensure_ccw(clip)
    for edge_start, edge_end in zip(clip_ccw, clip_ccw[1:] + clip_ccw[:1]):
        if not output:
            break
        input_points = output
        output = []
        previous = input_points[-1]
        previous_inside = _inside_half_plane(previous, edge_start, edge_end)
        for current in input_points:
            current_inside = _inside_half_plane(current, edge_start, edge_end)
            if current_inside:
                if not previous_inside:
                    output.append(_intersection(previous, current, edge_start, edge_end))
                output.append(current)
            elif previous_inside:
                output.append(_intersection(previous, current, edge_start, edge_end))
            previous = current
            previous_inside = current_inside
    return output


@dataclass(frozen=True, slots=True)
class SiliconCell:
    """Drawable silicon cell polygon in layer-global coordinates."""

    layer: int | None
    wafer_u: int
    wafer_v: int
    iu: int
    iv: int
    center: Point
    side: float
    is_ld: bool
    wafer_type: int
    sensor_type: str | None = None
    orientation_rad: float = 0.0
    vertices: tuple[Point, ...] | None = None

    def corners(self) -> list[Point]:
        if self.vertices is not None:
            return list(self.vertices)
        return [
            Point(self.center.x + dx, self.center.y + dy)
            for dx, dy in _flat_top_hex_offsets(self.side, self.orientation_rad)
        ]


@dataclass(frozen=True, slots=True)
class LocalSiliconCell:
    iu: int
    iv: int
    center: Point
    side: float

    def corners(self) -> list[Point]:
        return [Point(self.center.x + dx, self.center.y + dy) for dx, dy in _flat_top_hex_offsets(self.side)]


def density_number(*, is_ld: bool) -> int:
    return DENSITY_LD if is_ld else DENSITY_HD


def regular_cell_side(*, is_ld: bool) -> float:
    """Return the regular cell hexagon side in mm."""

    nc = density_number(is_ld=is_ld)
    return DEFAULT_WAFER_SIDE_MM / (nc * sqrt(3.0))


def valid_cell_coordinates(*, is_ld: bool) -> set[tuple[int, int]]:
    return default_cell_set(hd=not is_ld)


def _raw_local_center(iu: int, iv: int, side: float) -> Point:
    q = iu
    r = iv - iu
    return Point(1.5 * side * q, sqrt(3.0) * side * (r + 0.5 * q))


def local_cells(*, is_ld: bool) -> list[LocalSiliconCell]:
    side = regular_cell_side(is_ld=is_ld)
    coords = sorted(valid_cell_coordinates(is_ld=is_ld))
    raw = [(iu, iv, _raw_local_center(iu, iv, side)) for iu, iv in coords]
    mean_x = sum(point.x for _, _, point in raw) / len(raw)
    mean_y = sum(point.y for _, _, point in raw) / len(raw)
    return [
        LocalSiliconCell(iu=iu, iv=iv, center=Point(point.x - mean_x, point.y - mean_y), side=side)
        for iu, iv, point in raw
    ]


def rotate_point(point: Point, angle_rad: float) -> Point:
    c = cos(angle_rad)
    s = sin(angle_rad)
    return Point(c * point.x - s * point.y, s * point.x + c * point.y)


def _interpolate(a: Point, b: Point, t: float) -> Point:
    return Point((1.0 - t) * a.x + t * b.x, (1.0 - t) * a.y + t * b.y)


def partial_wafer_polygon(wafer: Wafer) -> list[Point]:
    """Return an approximate drawable polygon for the wafer active partial.

    The vertex selections for LD 1 and LD 2 match the coarse partial polygons in
    the original Mac view. The other partials use convex approximations aligned
    to the same wafer-corner convention until the exact Zoltan dicing bands are
    ported.
    """

    corners = wafer.corners()
    if wafer.partial_type == 0:
        return corners

    p = wafer.partial_type
    if wafer.is_ld:
        if p == 1:
            polygon = [corners[1], corners[4], corners[5], corners[0]]
        elif p == 2:
            polygon = [corners[1], corners[2], corners[3], corners[4]]
        elif p == 3:
            cut_a = _interpolate(corners[2], corners[3], 0.55)
            cut_b = _interpolate(corners[5], corners[0], 0.55)
            polygon = [cut_b, corners[0], corners[1], corners[2], cut_a]
        elif p == 4:
            cut_a = _interpolate(corners[2], corners[3], 0.45)
            cut_b = _interpolate(corners[5], corners[0], 0.45)
            polygon = [cut_a, corners[3], corners[4], corners[5], cut_b]
        elif p == 5:
            cut_a = _interpolate(corners[4], corners[5], 0.45)
            cut_b = _interpolate(corners[3], corners[4], 0.45)
            polygon = [corners[0], corners[1], corners[2], corners[3], cut_b, cut_a, corners[5]]
        else:
            polygon = corners
    else:
        if p == 1:
            cut_a = _interpolate(corners[5], corners[0], 0.35)
            cut_b = _interpolate(corners[2], corners[3], 0.35)
            polygon = [cut_a, corners[0], corners[1], corners[2], cut_b]
        elif p == 2:
            cut_a = _interpolate(corners[5], corners[0], 0.65)
            cut_b = _interpolate(corners[2], corners[3], 0.65)
            polygon = [cut_b, corners[3], corners[4], corners[5], cut_a]
        elif p == 3:
            cut_a = _interpolate(corners[0], corners[1], 0.45)
            cut_b = _interpolate(corners[3], corners[4], 0.45)
            polygon = [corners[0], cut_a, corners[2], corners[3], cut_b, corners[5]]
        elif p == 4:
            cut_a = _interpolate(corners[0], corners[1], 0.55)
            cut_b = _interpolate(corners[3], corners[4], 0.55)
            polygon = [cut_a, corners[1], corners[2], corners[3], cut_b]
        else:
            polygon = corners

    return _ensure_ccw(polygon)


def transform_to_wafer(cell: LocalSiliconCell, wafer: Wafer) -> SiliconCell:
    angle = wafer.placement * pi / 3.0
    rotated = rotate_point(cell.center, angle)
    center = Point(wafer.center.x + rotated.x, wafer.center.y + rotated.y)
    full_cell = SiliconCell(
        layer=wafer.metadata.get("layer") if isinstance(wafer.metadata.get("layer"), int) else None,
        wafer_u=wafer.u,
        wafer_v=wafer.v,
        iu=cell.iu,
        iv=cell.iv,
        center=center,
        side=cell.side,
        is_ld=wafer.is_ld,
        wafer_type=wafer.partial_type,
        sensor_type=wafer.metadata.get("sensor_type") if isinstance(wafer.metadata.get("sensor_type"), str) else None,
        orientation_rad=angle,
    )
    if wafer.partial_type == 0:
        return full_cell
    clipped = clip_polygon(full_cell.corners(), partial_wafer_polygon(wafer))
    if len(clipped) < 3 or polygon_area(clipped) <= MIN_POLYGON_AREA_MM2:
        return full_cell
    return SiliconCell(
        layer=full_cell.layer,
        wafer_u=full_cell.wafer_u,
        wafer_v=full_cell.wafer_v,
        iu=full_cell.iu,
        iv=full_cell.iv,
        center=full_cell.center,
        side=full_cell.side,
        is_ld=full_cell.is_ld,
        wafer_type=full_cell.wafer_type,
        sensor_type=full_cell.sensor_type,
        orientation_rad=full_cell.orientation_rad,
        vertices=tuple(clipped),
    )


def cells_for_wafer(wafer: Wafer) -> list[SiliconCell]:
    """Return regular or clipped grid cells for one wafer."""

    out: list[SiliconCell] = []
    clip = partial_wafer_polygon(wafer)
    for local_cell in local_cells(is_ld=wafer.is_ld):
        cell = transform_to_wafer(local_cell, wafer)
        if wafer.partial_type == 0 or polygon_area(cell.corners()) > MIN_POLYGON_AREA_MM2:
            if wafer.partial_type == 0 or polygon_area(clip_polygon(cell.corners(), clip)) > MIN_POLYGON_AREA_MM2:
                out.append(cell)
    return out


def cells_for_wafers(wafers: list[Wafer]) -> list[SiliconCell]:
    out: list[SiliconCell] = []
    for wafer in wafers:
        out.extend(cells_for_wafer(wafer))
    return out
