"""Parser and geometry helpers for scintillator tile layer files."""

from __future__ import annotations

from dataclasses import dataclass
from math import cos, pi, sin
from pathlib import Path

from .geometry import Point
from .layer_map import read_records


@dataclass(frozen=True, slots=True)
class TileLayerHeader:
    layer: int
    tiles_per_ring: int
    cassette_retraction_mm: float
    line_number: int


@dataclass(frozen=True, slots=True)
class TileRing:
    layer: int
    ring: int
    inner_radius_mm: float
    outer_radius_mm: float
    sipm_area_mm2: float
    words: tuple[str, str, str, str]
    production: str
    line_number: int

    @property
    def tiles_per_120_degrees(self) -> int:
        return sum(len(word) * 4 for word in self.words)

    @property
    def tiles_per_full_ring(self) -> int:
        return 3 * self.tiles_per_120_degrees

    def presence_bits_120_degrees(self) -> tuple[bool, ...]:
        bits: list[bool] = []
        for word in self.words:
            width = len(word) * 4
            value = int(word, 16)
            for bit in range(width - 1, -1, -1):
                bits.append(bool((value >> bit) & 1))
        return tuple(bits)


@dataclass(frozen=True, slots=True)
class Tile:
    layer: int
    ring: int
    index: int
    inner_radius_mm: float
    outer_radius_mm: float
    phi_min_rad: float
    phi_max_rad: float
    sipm_area_mm2: float
    production: str

    def corners(self) -> list[Point]:
        return [
            Point(self.inner_radius_mm * cos(self.phi_min_rad), self.inner_radius_mm * sin(self.phi_min_rad)),
            Point(self.outer_radius_mm * cos(self.phi_min_rad), self.outer_radius_mm * sin(self.phi_min_rad)),
            Point(self.outer_radius_mm * cos(self.phi_max_rad), self.outer_radius_mm * sin(self.phi_max_rad)),
            Point(self.inner_radius_mm * cos(self.phi_max_rad), self.inner_radius_mm * sin(self.phi_max_rad)),
        ]


def parse_tile_file(path: str | Path) -> tuple[list[TileLayerHeader], list[TileRing]]:
    """Parse a scintillator tile file.

    Header lines have three fields: layer, tiles per full ring, and cassette
    radial retraction in mm. Ring lines have ten fields: layer, ring, inner
    radius, outer radius, SiPM area, four hexadecimal occupancy words, and a
    production flag (c or m).
    """

    headers: list[TileLayerHeader] = []
    rings: list[TileRing] = []

    for record in read_records(path):
        tokens = record.tokens
        if len(tokens) == 3:
            try:
                headers.append(
                    TileLayerHeader(
                        layer=int(tokens[0]),
                        tiles_per_ring=int(tokens[1]),
                        cassette_retraction_mm=float(tokens[2]),
                        line_number=record.line_number,
                    )
                )
            except ValueError:
                continue
        elif len(tokens) == 10:
            try:
                words = tuple(token.upper() for token in tokens[5:9])
                if len(words) != 4 or not all(all(ch in "0123456789ABCDEF" for ch in word) for word in words):
                    continue
                rings.append(
                    TileRing(
                        layer=int(tokens[0]),
                        ring=int(tokens[1]),
                        inner_radius_mm=float(tokens[2]),
                        outer_radius_mm=float(tokens[3]),
                        sipm_area_mm2=float(tokens[4]),
                        words=words,  # type: ignore[arg-type]
                        production=tokens[9].lower(),
                        line_number=record.line_number,
                    )
                )
            except ValueError:
                continue

    return headers, rings


def tiles_for_layer(path: str | Path, *, layer: int) -> list[Tile]:
    """Expand tile-ring bitmaps into drawable tile sectors for one layer."""

    headers, rings = parse_tile_file(path)
    header_by_layer = {header.layer: header for header in headers}
    out: list[Tile] = []

    for ring in rings:
        if ring.layer != layer:
            continue
        header = header_by_layer.get(ring.layer)
        tiles_per_ring = header.tiles_per_ring if header is not None else ring.tiles_per_full_ring
        bits_120 = ring.presence_bits_120_degrees()
        if 3 * len(bits_120) != tiles_per_ring:
            # Keep the parser usable for malformed or transitional files, but
            # do not draw inconsistent ring definitions.
            continue
        delta_phi = 2.0 * pi / tiles_per_ring
        for sector in range(3):
            base = sector * len(bits_120)
            for local_index, present in enumerate(bits_120):
                if not present:
                    continue
                index = base + local_index
                out.append(
                    Tile(
                        layer=ring.layer,
                        ring=ring.ring,
                        index=index,
                        inner_radius_mm=ring.inner_radius_mm,
                        outer_radius_mm=ring.outer_radius_mm,
                        phi_min_rad=index * delta_phi,
                        phi_max_rad=(index + 1) * delta_phi,
                        sipm_area_mm2=ring.sipm_area_mm2,
                        production=ring.production,
                    )
                )
    return out
