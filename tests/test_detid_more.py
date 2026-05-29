import pytest

from hgcalgeom.detid import (
    DETECTOR_MASK,
    HGCAL_EE,
    HGCAL_HSI,
    IU_MASK,
    IV_MASK,
    LAYER_MASK,
    WAFER_MASK,
    decode_detid,
    encode_detid,
    replace_cell,
    replace_wafer,
)


@pytest.mark.parametrize(
    "wafer_u,wafer_v,cell_u,cell_v,layer,detector",
    [
        (0, 0, 0, 0, 1, HGCAL_EE),
        (7, 3, 15, 10, 25, HGCAL_EE),
        (-7, -3, 5, 6, 26, HGCAL_HSI),
        (15, -15, 23, 18, 47, HGCAL_HSI),
    ],
)
def test_encode_decode_roundtrip_parameterized(wafer_u, wafer_v, cell_u, cell_v, layer, detector):
    raw = encode_detid(
        wafer_u=wafer_u,
        wafer_v=wafer_v,
        cell_u=cell_u,
        cell_v=cell_v,
        layer=layer,
    )
    decoded = decode_detid(raw)

    assert decoded.detector == detector
    assert decoded.wafer_u == wafer_u
    assert decoded.wafer_v == wafer_v
    assert decoded.cell_u == cell_u
    assert decoded.cell_v == cell_v
    assert decoded.layer == layer


def test_encode_requires_detector_or_layer():
    with pytest.raises(ValueError, match="Either detector or layer"):
        encode_detid(wafer_u=0, wafer_v=0, cell_u=0, cell_v=0)


def test_explicit_detector_can_be_used_without_layer():
    raw = encode_detid(wafer_u=2, wafer_v=-2, cell_u=4, cell_v=5, detector=HGCAL_HSI)
    decoded = decode_detid(raw)
    assert decoded.detector == HGCAL_HSI
    assert decoded.layer is None
    assert decoded.wafer_u == 2
    assert decoded.wafer_v == -2


def test_replace_cell_preserves_non_cell_bits():
    raw = encode_detid(wafer_u=-4, wafer_v=6, cell_u=1, cell_v=2, layer=30)
    replaced = replace_cell(raw, 11, 12)

    assert (replaced & ~(IU_MASK | IV_MASK)) == (raw & ~(IU_MASK | IV_MASK))
    decoded = decode_detid(replaced)
    assert decoded.cell_u == 11
    assert decoded.cell_v == 12
    assert decoded.wafer_u == -4
    assert decoded.wafer_v == 6


def test_replace_wafer_preserves_detector_layer_and_cell_bits():
    raw = encode_detid(wafer_u=1, wafer_v=2, cell_u=13, cell_v=14, layer=31)
    replaced = replace_wafer(raw, -5, 7)

    preserved_mask = DETECTOR_MASK | LAYER_MASK | IU_MASK | IV_MASK
    assert (replaced & preserved_mask) == (raw & preserved_mask)
    assert (replaced & WAFER_MASK) != (raw & WAFER_MASK)
    decoded = decode_detid(replaced)
    assert decoded.wafer_u == -5
    assert decoded.wafer_v == 7
    assert decoded.cell_u == 13
    assert decoded.cell_v == 14


def test_is_ee_and_is_hsi_properties():
    ee = decode_detid(encode_detid(wafer_u=0, wafer_v=0, cell_u=1, cell_v=1, layer=1))
    hsi = decode_detid(encode_detid(wafer_u=0, wafer_v=0, cell_u=1, cell_v=1, layer=30))
    assert ee.is_ee
    assert not ee.is_hsi
    assert hsi.is_hsi
    assert not hsi.is_ee
