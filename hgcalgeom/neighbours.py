"""Nearest-neighbour search for Hex compact DetIds.

The implementation follows the algorithm in HXGNeighbourFinder.m. The geometry
interface is deliberately small so it can be backed either by parsed flat files
or by an adapter to another geometry source.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol

from .detid import (
    DETECTOR_MASK,
    HGCAL_EE,
    HGCAL_HSI,
    IU_MASK,
    IV_MASK,
    IV_SHIFT,
    WAFER_MASK,
    decode_detid,
    replace_cell,
    replace_wafer,
)

DENSITY_NUMBER_LD = 8
DENSITY_NUMBER_HD = 12

DU_CELL = (-1, 0, +1, +1, 0, -1)
DV_CELL = (-1, -1, 0, +1, +1, 0)
DU_WAFER = (0, +1, +1, 0, -1, -1)
DV_WAFER = (-1, 0, +1, +1, 0, -1)


class GeometryInterface(Protocol):
    """Minimal geometry callbacks needed by the neighbour algorithm."""

    def wafer_exists(self, detid: int) -> bool: ...

    def wafer_is_hd(self, detid: int) -> bool: ...

    def wafer_is_partial(self, detid: int) -> bool: ...

    def detid_exists(self, detid: int) -> bool: ...

    def placement_index_for_wafer(self, detid: int) -> int: ...


@dataclass(slots=True)
class NeighbourFinder:
    geometry: GeometryInterface

    def __post_init__(self) -> None:
        self.iu_edge_ld, self.iv_edge_ld, self.side_ld = self._build_tables(DENSITY_NUMBER_LD)
        self.iu_edge_hd, self.iv_edge_hd, self.side_hd = self._build_tables(DENSITY_NUMBER_HD)

    @staticmethod
    def edge_index_for_cell(iu: int, iv: int, *, hd: bool) -> int:
        density_number = DENSITY_NUMBER_HD if hd else DENSITY_NUMBER_LD
        max_index = 2 * density_number - 1
        half_max = density_number - 1

        if iv > iu + half_max or iv < iu - density_number:
            return -1

        if iv == 0 or iu - iv == density_number:
            return iu
        if iu == max_index:
            return max_index + iv - half_max
        if iv == max_index:
            return 2 * max_index + density_number - iu
        if iv - iu == half_max:
            return 2 * max_index + density_number - iu
        if iu == 0:
            return 3 * max_index - iv
        return -1

    @classmethod
    def _build_tables(cls, density_number: int) -> tuple[list[int], list[int], list[int]]:
        nedge = 6 * density_number - 3
        iu_edge = [0] * nedge
        iv_edge = [0] * nedge
        side = [0] * nedge

        for iu in range(2 * density_number):
            for iv in range(2 * density_number):
                edge = cls.edge_index_for_cell(iu, iv, hd=(density_number == DENSITY_NUMBER_HD))
                if edge > -1:
                    iu_edge[edge] = iu
                    iv_edge[edge] = iv

        edge_index = 1
        edge_count = density_number - 1
        for i in range(6):
            for j in range(edge_index, edge_index + edge_count + i % 2):
                side[j % nedge] = i
            edge_index += edge_count + i % 2

        edge_index = 0
        for i in range(6):
            side[edge_index] += (i + 1) * 10
            edge_index += edge_count + (i + 1) % 2

        return iu_edge, iv_edge, side

    def nearest_neighbours(self, detid: int) -> list[int]:
        """Return the existing nearest-neighbour DetIds.

        The original API returned a fixed-size C array padded with zeroes. The
        Python API returns only non-zero neighbours.
        """

        if (detid & DETECTOR_MASK) not in (HGCAL_EE, HGCAL_HSI):
            return []

        hd = self.geometry.wafer_is_hd(detid)
        decoded = decode_detid(detid)
        iu = decoded.cell_u
        iv = decoded.cell_v
        edge_index = self.edge_index_for_cell(iu, iv, hd=hd)
        partial_wafer = self.geometry.wafer_is_partial(detid)

        if edge_index < 0:
            neighbours = [replace_cell(detid, iu + du, iv + dv) for du, dv in zip(DU_CELL, DV_CELL)]
            if partial_wafer:
                return [n for n in neighbours if self.geometry.detid_exists(n)]
            return neighbours

        iu_edge = self.iu_edge_hd if hd else self.iu_edge_ld
        iv_edge = self.iv_edge_hd if hd else self.iv_edge_ld
        side = self.side_hd if hd else self.side_ld
        density_number = DENSITY_NUMBER_HD if hd else DENSITY_NUMBER_LD

        edge_count = 3 * (2 * density_number - 1)
        mod = 2 * density_number
        iside = side[edge_index] % 10
        corner = side[edge_index] // 10 - 1

        icount = 4
        ioff = iside + 2
        if corner > -1:
            icount = 3
            ioff = corner + 2

        out: list[int] = []
        for i in range(icount):
            j = (ioff + i) % 6
            n = replace_cell(detid, (iu + DU_CELL[j] + mod) % mod, (iv + DV_CELL[j] + mod) % mod)
            if not partial_wafer or self.geometry.detid_exists(n):
                out.append(n)

        if partial_wafer and not hd and edge_index == 37:
            return out

        irot = self.geometry.placement_index_for_wafer(detid)
        idir = (iside + irot) % 6
        mirror = False
        if irot > 5:
            mirror = True
            irot = (12 - irot) % 6
            idir = (irot - iside + 5) % 6

        next_wafer_u = decoded.wafer_u + DU_WAFER[idir]
        next_wafer_v = decoded.wafer_v + DV_WAFER[idir]
        next_detid = replace_wafer(detid, next_wafer_u, next_wafer_v)

        if not self.geometry.wafer_exists(next_detid):
            return out

        jrot = self.geometry.placement_index_for_wafer(next_detid)
        if jrot > 5:
            jrot = (12 - jrot) % 6

        drot = (irot - jrot + 6) % 6
        if mirror:
            drot = (6 - drot) % 6

        next_hd = self.geometry.wafer_is_hd(next_detid)
        same_density = hd == next_hd
        max_index = 2 * density_number - 1

        if drot % 2 == 0:
            total = max_index * ((iside + 2) % 3)
            new_index = (total - edge_index + (drot // 2) * max_index + edge_count) % edge_count
            istart = 0
            iend = 2
        else:
            total = ((density_number - 1) + (iside + 4) * max_index) % (3 * max_index)
            new_index = (total - edge_index + (drot // 2 + 1) * max_index + edge_count) % edge_count
            istart = 0
            iend = 3
            if corner > -1:
                if corner % 2 == 0:
                    istart = 1
                else:
                    iend = 2

        if not same_density:
            if next_hd:
                new_index = (3 * new_index) // 2 + drot % 2
                iu_edge = self.iu_edge_hd
                iv_edge = self.iv_edge_hd
                edge_count = 3 * (2 * DENSITY_NUMBER_HD - 1)
                iend = 3
                next_side = self.side_hd[new_index]
                if corner > -1:
                    if corner == 0 and next_side == 1:
                        new_index += 1
                    elif corner == 1 and next_side == 1:
                        iend = 2
                    elif corner == 3 and next_side in (3, 4):
                        istart = 1
                    elif corner == 4 and next_side == 3:
                        new_index += 1
                    elif corner == 5 and next_side == 3:
                        istart = 1
            else:
                new_index = (2 * new_index) // 3
                iu_edge = self.iu_edge_ld
                iv_edge = self.iv_edge_ld
                edge_count = 3 * (2 * DENSITY_NUMBER_LD - 1)
                iend = 2
                next_side = self.side_ld[new_index] % 10
                if iside == 1:
                    if next_side == 1 and edge_index % 3 == 0:
                        new_index += 1
                    elif next_side == 4:
                        if edge_index % 3 == 0:
                            new_index -= 1
                        elif edge_index % 3 == 1:
                            iend = 1
                elif iside == 2:
                    if next_side == 2 and edge_index % 3 == 2:
                        istart = 1
                    elif next_side == 4 and edge_index % 3 == 2:
                        iend = 1
                    elif next_side == 5 and edge_index % 3 != 1:
                        new_index -= 1
                elif iside == 3:
                    if next_side == 5 and edge_index % 3 == 1:
                        new_index -= 1
                elif iside == 4:
                    if next_side == 3 and edge_index % 3 == 2:
                        new_index -= 1
                if corner > -1:
                    if corner == 1 and next_side == 5:
                        new_index -= 1
                    elif corner == 3:
                        iend = 1
                    elif corner == 4 and next_side == 5:
                        istart = 0
                        iend = 1

        next_partial = self.geometry.wafer_is_partial(next_detid)
        for i in range(istart, iend):
            idx = (new_index + i) % edge_count
            n = replace_cell(next_detid, iu_edge[idx], iv_edge[idx])
            if not next_partial or self.geometry.detid_exists(n):
                out.append(n)

        return out
