"""Helpers for the compact DetId encoding used by the Hex geometry toy.

This module mirrors the bit layout used in Chris Seez's Objective-C code in
HXGDetIdInterface and HXGNeighbourFinder. It is intentionally small and does
not depend on CMSSW.
"""

from __future__ import annotations

from dataclasses import dataclass

IU_MASK = 0x0000001F
IV_MASK = 0x000003E0
WAFER_MASK = 0x000FFC00
LAYER_MASK = 0x01F00000
DETECTOR_MASK = 0xF0000000

HGCAL_EE = 0x80000000
HGCAL_HSI = 0x90000000

SIGN_MASK = 0x00000010
IV_SHIFT = 5
WAFER_SHIFT = 10
LAYER_SHIFT = 20


def _encode_signed_5bit(value: int) -> int:
    encoded = abs(value)
    if value < 0:
        encoded |= SIGN_MASK
    return encoded & IU_MASK


def _decode_signed_5bit(value: int) -> int:
    value &= IU_MASK
    if value & SIGN_MASK:
        return -(value & ~SIGN_MASK)
    return value


@dataclass(frozen=True, slots=True)
class DetId:
    """Decoded representation of the compact DetId.

    The layer field is optional because the original helper only used the
    detector prefix to distinguish EE from HSi in the local toy code.
    """

    raw: int
    detector: int
    cell_u: int
    cell_v: int
    wafer_u: int
    wafer_v: int
    layer: int | None = None

    @property
    def is_ee(self) -> bool:
        return self.detector == HGCAL_EE

    @property
    def is_hsi(self) -> bool:
        return self.detector == HGCAL_HSI


def encode_detid(
    *,
    wafer_u: int,
    wafer_v: int,
    cell_u: int,
    cell_v: int,
    layer: int | None = None,
    detector: int | None = None,
) -> int:
    """Encode wafer and cell coordinates into the Hex compact DetId."""

    wu = _encode_signed_5bit(wafer_u)
    wv = _encode_signed_5bit(wafer_v)
    wafer_id = wu | (wv << IV_SHIFT)

    raw = (cell_u & IU_MASK) | ((cell_v & IU_MASK) << IV_SHIFT) | (wafer_id << WAFER_SHIFT)

    if detector is None:
        if layer is None:
            raise ValueError("Either detector or layer must be provided")
        detector = HGCAL_EE if layer < 26 else HGCAL_HSI

    raw |= detector
    if layer is not None:
        raw |= (layer << LAYER_SHIFT) & LAYER_MASK
    return raw


def decode_detid(raw: int) -> DetId:
    """Decode the Hex compact DetId into cell and wafer coordinates."""

    cell_u = raw & IU_MASK
    cell_v = (raw & IV_MASK) >> IV_SHIFT
    wafer_id = (raw & WAFER_MASK) >> WAFER_SHIFT
    wafer_u = _decode_signed_5bit(wafer_id & IU_MASK)
    wafer_v = _decode_signed_5bit((wafer_id & IV_MASK) >> IV_SHIFT)
    layer_bits = (raw & LAYER_MASK) >> LAYER_SHIFT
    layer = layer_bits if layer_bits else None
    return DetId(
        raw=raw,
        detector=raw & DETECTOR_MASK,
        cell_u=cell_u,
        cell_v=cell_v,
        wafer_u=wafer_u,
        wafer_v=wafer_v,
        layer=layer,
    )


def replace_cell(raw: int, cell_u: int, cell_v: int) -> int:
    """Return raw with only the cell coordinates replaced."""

    return (raw & ~(IU_MASK | IV_MASK)) | (cell_u & IU_MASK) | ((cell_v & IU_MASK) << IV_SHIFT)


def replace_wafer(raw: int, wafer_u: int, wafer_v: int) -> int:
    """Return raw with only the wafer coordinates replaced."""

    wu = _encode_signed_5bit(wafer_u)
    wv = _encode_signed_5bit(wafer_v)
    wafer_id = wu | (wv << IV_SHIFT)
    return (raw & ~WAFER_MASK) | (wafer_id << WAFER_SHIFT)
