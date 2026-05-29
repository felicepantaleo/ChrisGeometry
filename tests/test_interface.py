from hgcalgeom.detid import encode_detid
from hgcalgeom.geometry import Point, Wafer
from hgcalgeom.interface import InMemoryGeometry, default_cell_set


def test_default_cell_set_sizes_match_ld_and_hd_hexes():
    assert len(default_cell_set(hd=False)) == 192
    assert len(default_cell_set(hd=True)) == 432


def test_default_cell_set_rejects_outside_hex_coordinates():
    ld_cells = default_cell_set(hd=False)
    assert (0, 0) in ld_cells
    assert (15, 15) in ld_cells
    assert (0, 15) not in ld_cells
    assert (15, 0) not in ld_cells


def test_in_memory_geometry_wafer_lookup_and_flags():
    geom = InMemoryGeometry()
    geom.add_wafer(
        Wafer(
            u=-2,
            v=3,
            center=Point(0.0, 0.0),
            side=1.0,
            is_ld=True,
            is_partial=True,
            partial_type=2,
            placement=4,
            seen_from_back=True,
        )
    )
    raw = encode_detid(wafer_u=-2, wafer_v=3, cell_u=1, cell_v=1, layer=30)

    assert geom.wafer_exists(raw)
    assert not geom.wafer_is_hd(raw)
    assert geom.wafer_is_partial(raw)
    assert geom.placement_index_for_wafer(raw) == 10


def test_in_memory_geometry_missing_wafer():
    geom = InMemoryGeometry()
    raw = encode_detid(wafer_u=9, wafer_v=9, cell_u=1, cell_v=1, layer=30)

    assert not geom.wafer_exists(raw)
    assert not geom.wafer_is_hd(raw)
    assert not geom.wafer_is_partial(raw)
    assert geom.placement_index_for_wafer(raw) == 0
    assert not geom.detid_exists(raw)


def test_detid_exists_uses_custom_partial_cell_set():
    geom = InMemoryGeometry()
    geom.add_wafer(
        Wafer(
            u=0,
            v=0,
            center=Point(0.0, 0.0),
            side=1.0,
            is_ld=True,
            is_partial=True,
            partial_type=3,
        )
    )
    geom.set_cells(hd=False, partial_type=3, cells={(1, 1), (2, 2)})

    existing = encode_detid(wafer_u=0, wafer_v=0, cell_u=1, cell_v=1, layer=30)
    missing = encode_detid(wafer_u=0, wafer_v=0, cell_u=3, cell_v=3, layer=30)

    assert geom.detid_exists(existing)
    assert not geom.detid_exists(missing)
