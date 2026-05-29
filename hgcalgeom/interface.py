"""In-memory geometry adapter for neighbour queries."""

from __future__ import annotations

from dataclasses import dataclass, field

from .detid import decode_detid
from .geometry import Wafer


@dataclass(slots=True)
class InMemoryGeometry:
    """Small geometry container implementing the neighbour callbacks."""

    wafers: dict[tuple[int, int], Wafer] = field(default_factory=dict)
    cell_sets: dict[tuple[bool, int], set[tuple[int, int]]] = field(default_factory=dict)

    def add_wafer(self, wafer: Wafer) -> None:
        self.wafers[(wafer.u, wafer.v)] = wafer

    def set_cells(self, *, hd: bool, partial_type: int, cells: set[tuple[int, int]]) -> None:
        self.cell_sets[(hd, partial_type)] = set(cells)

    def wafer_for_detid(self, detid: int) -> Wafer | None:
        decoded = decode_detid(detid)
        return self.wafers.get((decoded.wafer_u, decoded.wafer_v))

    def wafer_exists(self, detid: int) -> bool:
        return self.wafer_for_detid(detid) is not None

    def wafer_is_hd(self, detid: int) -> bool:
        wafer = self.wafer_for_detid(detid)
        return bool(wafer and wafer.is_hd)

    def wafer_is_partial(self, detid: int) -> bool:
        wafer = self.wafer_for_detid(detid)
        return bool(wafer and wafer.is_partial)

    def detid_exists(self, detid: int) -> bool:
        decoded = decode_detid(detid)
        wafer = self.wafer_for_detid(detid)
        if wafer is None:
            return False
        key = (wafer.is_hd, wafer.partial_type if wafer.is_partial else 0)
        cells = self.cell_sets.get(key)
        if cells is None:
            cells = default_cell_set(hd=wafer.is_hd)
        return (decoded.cell_u, decoded.cell_v) in cells

    def placement_index_for_wafer(self, detid: int) -> int:
        wafer = self.wafer_for_detid(detid)
        if wafer is None:
            return 0
        return wafer.placement + (6 if wafer.seen_from_back else 0)


def default_cell_set(*, hd: bool) -> set[tuple[int, int]]:
    """Return the whole-wafer valid cell coordinates for LD or HD density."""

    density = 12 if hd else 8
    cells: set[tuple[int, int]] = set()
    for iu in range(2 * density):
        for iv in range(2 * density):
            if iv <= iu + density - 1 and iv >= iu - density:
                cells.add((iu, iv))
    return cells
