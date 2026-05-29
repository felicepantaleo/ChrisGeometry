"""Silicon cell generation for LD and HD wafers.

This module builds the regular grid-cell geometry documented by Chris Seez. It
is intentionally limited to the ideal grid cells for now: edge-cell clipping,
mouse-bites, calibration holes, and partial-wafer dicing lines are handled later.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import cos, pi, sin, sqrt

from .geometry import Point, Wafer
from .interface import default_cell_set
from .layer_map import DEFAULT_WAFER_SIDE_MM


DENSITY_LD = 8
DENSITY_HD = 12


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

    def corners(self) -> list[Point]:
        h = sqrt(0.75) * self.side
        offsets = [
            (0.0, -self.side),
            (h, -0.5 * self.side),
            (h, 0.5 * self.side),
            (0.0, self.side),
            (-h, 0.5 * self.side),
            (-h, -0.5 * self.side),
        ]
        return [Point(self.center.x + dx, self.center.y + dy) for dx, dy in offsets]


@dataclass(frozen=True, slots=True)
class LocalSiliconCell:
    iu: int
    iv: int
    center: Point
    side: float

    def corners(self) -> list[Point]:
        h = sqrt(0.75) * self.side
        offsets = [
            (0.0, -self.side),
            (h, -0.5 * self.side),
            (h, 0.5 * self.side),
            (0.0, self.side),
            (-h, 0.5 * self.side),
            (-h, -0.5 * self.side),
        ]
        return [Point(self.center.x + dx, self.center.y + dy) for dx, dy in offsets]


def density_number(*, is_ld: bool) -> int:
    return DENSITY_LD if is_ld else DENSITY_HD


def regular_cell_side(*, is_ld: bool) -> float:
    """Return the regular cell hexagon side in mm.

    The documentation gives layout hexagon width = 167.4408 mm and
    cellWidth = waferSide / Nc. In the hexagon drawing convention used here,
    cell side = cellWidth / sqrt(3).
    """

    nc = density_number(is_ld=is_ld)
    return DEFAULT_WAFER_SIDE_MM / (nc * sqrt(3.0))


def valid_cell_coordinates(*, is_ld: bool) -> set[tuple[int, int]]:
    return default_cell_set(hd=not is_ld)


def _raw_local_center(iu: int, iv: int, side: float) -> Point:
    # Use axial coordinates q=iu, r=iv-iu. This reproduces the neighbour
    # directions used by the nearest-neighbour algorithm.
    q = iu
    r = iv - iu
    return Point(sqrt(3.0) * side * (q + 0.5 * r), 1.5 * side * r)


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


def transform_to_wafer(cell: LocalSiliconCell, wafer: Wafer) -> SiliconCell:
    angle = wafer.placement * pi / 3.0
    rotated = rotate_point(cell.center, angle)
    center = Point(wafer.center.x + rotated.x, wafer.center.y + rotated.y)
    return SiliconCell(
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
    )


def cells_for_wafer(wafer: Wafer) -> list[SiliconCell]:
    """Return regular grid cells for one wafer.

    Partial wafers currently return the full pre-dicing grid. This is useful for
    visual debugging, but not yet the final physical partial-wafer geometry.
    """

    return [transform_to_wafer(cell, wafer) for cell in local_cells(is_ld=wafer.is_ld)]


def cells_for_wafers(wafers: list[Wafer]) -> list[SiliconCell]:
    out: list[SiliconCell] = []
    for wafer in wafers:
        out.extend(cells_for_wafer(wafer))
    return out
