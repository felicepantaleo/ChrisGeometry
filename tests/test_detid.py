from hgcalgeom.detid import HGCAL_EE, HGCAL_HSI, decode_detid, encode_detid


def test_encode_decode_negative_wafer_coordinates():
    raw = encode_detid(wafer_u=-3, wafer_v=5, cell_u=7, cell_v=9, layer=25)
    decoded = decode_detid(raw)
    assert decoded.detector == HGCAL_EE
    assert decoded.wafer_u == -3
    assert decoded.wafer_v == 5
    assert decoded.cell_u == 7
    assert decoded.cell_v == 9


def test_layer_selects_hsi_after_ee_layers():
    raw = encode_detid(wafer_u=1, wafer_v=-2, cell_u=3, cell_v=4, layer=26)
    assert decode_detid(raw).detector == HGCAL_HSI
