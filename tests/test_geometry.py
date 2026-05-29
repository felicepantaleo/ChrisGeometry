from math import isclose, sqrt

from hgcalgeom.geometry import Cell, Point, Wafer, polygon_area


def assert_point_close(point, x, y):
    assert isclose(point.x, x, abs_tol=1.0e-12)
    assert isclose(point.y, y, abs_tol=1.0e-12)


def test_cell_corners_match_flat_top_hexagon_offsets():
    cell = Cell(u=1, v=2, center=Point(10.0, -5.0), side=2.0)
    corners = cell.corners()

    h = sqrt(0.75) * 2.0
    expected = [
        (10.0, -7.0),
        (10.0 + h, -6.0),
        (10.0 + h, -4.0),
        (10.0, -3.0),
        (10.0 - h, -4.0),
        (10.0 - h, -6.0),
    ]
    assert len(corners) == 6
    for point, (x, y) in zip(corners, expected):
        assert_point_close(point, x, y)


def test_cell_area_matches_original_formula():
    cell = Cell(u=0, v=0, center=Point(0.0, 0.0), side=3.0)
    assert isclose(cell.area, sqrt(6.75) * 9.0, rel_tol=1.0e-15)
    assert isclose(polygon_area(cell.corners()), cell.area, rel_tol=1.0e-15)


def test_wafer_corners_are_translated_like_cells():
    wafer = Wafer(u=-1, v=2, center=Point(1.0, 2.0), side=4.0, is_ld=True)
    corners = wafer.corners()
    assert len(corners) == 6
    assert_point_close(corners[0], 1.0, -2.0)
    assert_point_close(corners[3], 1.0, 6.0)
    assert wafer.is_ld
    assert not wafer.is_hd


def test_polygon_area_is_orientation_independent():
    points = [Point(0.0, 0.0), Point(2.0, 0.0), Point(2.0, 3.0), Point(0.0, 3.0)]
    assert polygon_area(points) == 6.0
    assert polygon_area(list(reversed(points))) == 6.0


def test_polygon_area_degenerate_inputs():
    assert polygon_area([]) == 0.0
    assert polygon_area([Point(0.0, 0.0), Point(1.0, 1.0)]) == 0.0
