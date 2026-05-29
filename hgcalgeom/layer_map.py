"""Parsers for geometry flat files.

The historical files have evolved over time. The generic reader keeps the
original line around and extracts numeric fields conservatively. The
``parse_chris_geometry`` parser handles the older Hex geometry dump format used
by files such as ``geomCMSSW10052021_corrected.txt``.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re

from .geometry import Point, Wafer

_NUMBER_RE = re.compile(r"[-+]?\d+(?:\.\d+)?(?:[eE][-+]?\d+)?")

SENSOR_SIDE_MM = {
    # The dump stores wafer centre coordinates in mm. These side lengths are
    # approximate display-side lengths, good enough for quick visualisation.
    "h120": 95.0,
    "h200": 95.0,
    "l200": 95.0,
    "l300": 95.0,
}


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


def parse_chris_geometry(path: str | Path, *, layer: int | None = None, wafer_side: float | None = None) -> list[Wafer]:
    """Parse Chris Seez's text geometry dump into wafer objects.

    Data lines have the form::

        layer partial_type sensor_type x_mm y_mm placement wafer_u wafer_v

    Example::

        1 0 h120  502.32    0.00 0 3 0

    The first two header lines are skipped automatically because they do not
    match this token pattern.
    """

    wafers: list[Wafer] = []
    for record in read_records(path):
        tokens = record.tokens
        if len(tokens) < 8:
            continue
        if not tokens[0].lstrip("+-").isdigit() or not tokens[1].lstrip("+-").isdigit():
            continue
        sensor_type = tokens[2].lower()
        if not sensor_type[0:1] in {"h", "l"}:
            continue
        try:
            record_layer = int(tokens[0])
            partial_type = int(tokens[1])
            x = float(tokens[3])
            y = float(tokens[4])
            placement = int(tokens[5])
            wafer_u = int(tokens[6])
            wafer_v = int(tokens[7])
        except ValueError:
            continue
        if layer is not None and record_layer != layer:
            continue

        side = wafer_side if wafer_side is not None else SENSOR_SIDE_MM.get(sensor_type, 95.0)
        wafers.append(
            Wafer(
                u=wafer_u,
                v=wafer_v,
                center=Point(x, y),
                side=side,
                is_ld=sensor_type.startswith("l"),
                is_partial=partial_type != 0,
                partial_type=partial_type,
                placement=placement,
                file_line=record.line_number,
                metadata={
                    "raw": record.raw,
                    "layer": record_layer,
                    "sensor_type": sensor_type,
                    "partial_type": partial_type,
                },
            )
        )
    return wafers
