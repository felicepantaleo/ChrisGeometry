"""Basic HGCAL geometry primitives used by the Python port."""

from __future__ import annotations

from dataclasses import dataclass, field
from math import hypot, sqrt
from typing import Iterable

SQRT3_OVER_2 = sqrt(0.75)


@dataclass(frozen=True, slots=True)
class Point:
    x: float
    y: float

    def radius(self) -> float:
        return hypot(self.x, self.y)


@dataclass(slots=True)
class Cell:
    """A silicon cell in wafer-local coordinates."""

    u: int
    v: int
    center: Point
    side: float
    detid: int | None = None

    def corners(self) -> list[Point]:
        h = SQRT3_OVER_2 * self.side
        offsets = [
            (0.0, -self.side),
            (h, -0.5 * self.side),
            (h, 0.5 * self.side),
            (0.0, self.side),
            (-h, 0.5 * self.side),
            (-h, -0.5 * self.side),
        ]
        return [Point(self.center.x + dx, self.center.y + dy) for dx, dy in offsets]

    @property
    def area(self) -> float:
        return sqrt(6.75) * self.side * self.side


@dataclass(slots=True)
class Wafer:
    """A wafer in layer-global coordinates."""

    u: int
    v: int
    center: Point
    side: float
    is_ld: bool = False
    is_partial: bool = False
    partial_type: int = 0
    placement: int = 0
    seen_from_back: bool = False
    cassette: int | None = None
    file_line: int | None = None
    metadata: dict[str, object] = field(default_factory=dict)

    def corners(self) -> list[Point]:
        h = SQRT3_OVER_2 * self.side
        offsets = [
            (0.0, -self.side),
            (h, -0.5 * self.side),
            (h, 0.5 * self.side),
            (0.0, self.side),
            (-h, 0.5 * self.side),
            (-h, -0.5 * self.side),
        ]
        return [Point(self.center.x + dx, self.center.y + dy) for dx, dy in offsets]

    @property
    def radius(self) -> float:
        return self.center.radius()

    @property
    def is_hd(self) -> bool:
        return not self.is_ld

    @property
    def active(self) -> bool:
        return True


def polygon_area(points: Iterable[Point]) -> float:
    pts = list(points)
    if len(pts) < 3:
        return 0.0
    twice_area = 0.0
    for a, b in zip(pts, pts[1:] + pts[:1]):
        twice_area += a.x * b.y - b.x * a.y
    return 0.5 * abs(twice_area)
