from hgcalgeom.detid import encode_detid
from hgcalgeom.geometry import Point, Wafer
from hgcalgeom.interface import InMemoryGeometry, default_cell_set
from hgcalgeom.neighbours import NeighbourFinder


def make_geometry(hd=True):
    geom = InMemoryGeometry()
    for u in range(-1, 2):
        for v in range(-1, 2):
            geom.add_wafer(Wafer(u=u, v=v, center=Point(float(u), float(v)), side=1.0, is_ld=not hd))
    geom.set_cells(hd=hd, partial_type=0, cells=default_cell_set(hd=hd))
    return geom


def test_interior_hd_cell_has_six_neighbours():
    raw = encode_detid(wafer_u=0, wafer_v=0, cell_u=8, cell_v=8, layer=30)
    neighbours = NeighbourFinder(make_geometry(hd=True)).nearest_neighbours(raw)
    assert len(neighbours) == 6


def test_interior_ld_cell_has_six_neighbours():
    raw = encode_detid(wafer_u=0, wafer_v=0, cell_u=5, cell_v=5, layer=30)
    neighbours = NeighbourFinder(make_geometry(hd=False)).nearest_neighbours(raw)
    assert len(neighbours) == 6
