from hgcalgeom.detid import decode_detid, encode_detid
from hgcalgeom.geometry import Point, Wafer
from hgcalgeom.interface import InMemoryGeometry, default_cell_set
from hgcalgeom.neighbours import DENSITY_NUMBER_HD, DENSITY_NUMBER_LD, NeighbourFinder


def make_grid_geometry(*, hd=True, placement=0):
    geom = InMemoryGeometry()
    for u in range(-2, 3):
        for v in range(-2, 3):
            geom.add_wafer(
                Wafer(
                    u=u,
                    v=v,
                    center=Point(float(u), float(v)),
                    side=1.0,
                    is_ld=not hd,
                    placement=placement,
                )
            )
    geom.set_cells(hd=hd, partial_type=0, cells=default_cell_set(hd=hd))
    return geom


def test_edge_index_rejects_nonexistent_cell_coordinates():
    assert NeighbourFinder.edge_index_for_cell(0, 20, hd=False) == -1
    assert NeighbourFinder.edge_index_for_cell(0, 30, hd=True) == -1


def test_ld_edge_index_known_boundaries():
    assert NeighbourFinder.edge_index_for_cell(0, 0, hd=False) == 0
    assert NeighbourFinder.edge_index_for_cell(15, 7, hd=False) == 15
    assert NeighbourFinder.edge_index_for_cell(0, 7, hd=False) == 38


def test_hd_edge_index_known_boundaries():
    assert NeighbourFinder.edge_index_for_cell(0, 0, hd=True) == 0
    assert NeighbourFinder.edge_index_for_cell(23, 11, hd=True) == 23
    assert NeighbourFinder.edge_index_for_cell(0, 11, hd=True) == 58


def test_table_sizes_follow_chris_edge_count_formula():
    finder = NeighbourFinder(make_grid_geometry(hd=True))
    assert len(finder.iu_edge_ld) == 6 * DENSITY_NUMBER_LD - 3
    assert len(finder.iv_edge_ld) == 6 * DENSITY_NUMBER_LD - 3
    assert len(finder.side_ld) == 6 * DENSITY_NUMBER_LD - 3
    assert len(finder.iu_edge_hd) == 6 * DENSITY_NUMBER_HD - 3
    assert len(finder.iv_edge_hd) == 6 * DENSITY_NUMBER_HD - 3
    assert len(finder.side_hd) == 6 * DENSITY_NUMBER_HD - 3


def test_edge_cell_crosses_to_adjacent_wafer():
    raw = encode_detid(wafer_u=0, wafer_v=0, cell_u=0, cell_v=0, layer=30)
    neighbours = NeighbourFinder(make_grid_geometry(hd=True)).nearest_neighbours(raw)

    assert len(neighbours) >= 3
    decoded_wafers = {(decode_detid(n).wafer_u, decode_detid(n).wafer_v) for n in neighbours}
    assert (0, 0) in decoded_wafers
    assert len(decoded_wafers) > 1


def test_edge_cell_on_acceptance_boundary_returns_same_wafer_neighbours_only():
    geom = InMemoryGeometry()
    geom.add_wafer(Wafer(u=0, v=0, center=Point(0.0, 0.0), side=1.0, is_ld=False))
    geom.set_cells(hd=True, partial_type=0, cells=default_cell_set(hd=True))

    raw = encode_detid(wafer_u=0, wafer_v=0, cell_u=0, cell_v=0, layer=30)
    neighbours = NeighbourFinder(geom).nearest_neighbours(raw)

    assert neighbours
    assert all((decode_detid(n).wafer_u, decode_detid(n).wafer_v) == (0, 0) for n in neighbours)


def test_partial_wafer_filters_missing_interior_neighbours():
    geom = InMemoryGeometry()
    geom.add_wafer(
        Wafer(
            u=0,
            v=0,
            center=Point(0.0, 0.0),
            side=1.0,
            is_ld=False,
            is_partial=True,
            partial_type=1,
        )
    )
    geom.set_cells(hd=True, partial_type=1, cells={(8, 8), (7, 7), (8, 7)})

    raw = encode_detid(wafer_u=0, wafer_v=0, cell_u=8, cell_v=8, layer=30)
    neighbours = NeighbourFinder(geom).nearest_neighbours(raw)
    decoded_cells = {(decode_detid(n).cell_u, decode_detid(n).cell_v) for n in neighbours}

    assert decoded_cells == {(7, 7), (8, 7)}
