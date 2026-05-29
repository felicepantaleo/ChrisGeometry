"""Tolerant parsers for geometry flat files.

The historical files have evolved over time. This parser keeps the original
line around and extracts numeric fields conservatively so the rest of the port
can be built incrementally.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re

from .geometry import Point, Wafer

_NUMBER_RE = re.compile(r"[-+]?\d+(?:\.\d+)?(?:[eE][-+]?\d+)?")


@dataclass(frozen=True, slots=True)
class FlatFileRecord:
    line_number: int
    raw: str
    numbers: tuple[float, ...]
    tokens: tuple[str, ...]


def read_records(path: str | Path) -> list[FlatFileRecord]:
    records: list[FlatFileRecord] = []
    with Path(path).open("r", encoding="utf-8", errors="replace") as handle:
        for line_number, line in enumerate(handle, start=1):
            stripped = line.strip()
            if not stripped or stripped.startswith("#"):
                continue
            numbers = tuple(float(x) for x in _NUMBER_RE.findall(stripped))
            records.append(
                FlatFileRecord(
                    line_number=line_number,
                    raw=stripped,
                    numbers=numbers,
                    tokens=tuple(stripped.replace(",", " ").split()),
                )
            )
    return records


def guess_wafers_from_records(records: list[FlatFileRecord], *, wafer_side: float = 1.0) -> list[Wafer]:
    """Build a best-effort wafer list from numeric flat-file records.

    This is intentionally conservative. It assumes the first four numeric
    columns are approximately wafer u, wafer v, x, y. For production use the
    parser should be specialized once the exact chosen flat-file version is
    fixed.
    """

    wafers: list[Wafer] = []
    for record in records:
        if len(record.numbers) < 4:
            continue
        u = int(record.numbers[0])
        v = int(record.numbers[1])
        x = float(record.numbers[2])
        y = float(record.numbers[3])
        wafers.append(
            Wafer(
                u=u,
                v=v,
                center=Point(x, y),
                side=wafer_side,
                file_line=record.line_number,
                metadata={"raw": record.raw, "numbers": record.numbers},
            )
        )
    return wafers
