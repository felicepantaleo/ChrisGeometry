from math import isclose

from hgcalgeom.cells import cells_for_wafer, density_number, local_cells, regular_cell_side, valid_cell_coordinates
from hgcalgeom.geometry import Point, Wafer


def test_density_numbers_are_documented_values():
    assert density_number(is_ld=True) == 8
    assert density_number(is_ld=False) == 12


def test_regular_cell_counts_match_ld_and_hd():
    assert len(local_cells(is_ld=True)) == 192
    assert len(local_cells(is_ld=False)) == 432


def test_valid_coordinates_match_expected_counts():
    assert len(valid_cell_coordinates(is_ld=True)) == 192
    assert len(valid_cell_coordinates(is_ld=False)) == 432


def test_local_cells_are_centered_on_wafer_origin():
    cells = local_cells(is_ld=True)
    mean_x = sum(cell.center.x for cell in cells) / len(cells)
    mean_y = sum(cell.center.y for cell in cells) / len(cells)
    assert isclose(mean_x, 0.0, abs_tol=1.0e-12)
    assert isclose(mean_y, 0.0, abs_tol=1.0e-12)


def test_ld_cells_are_larger_than_hd_cells():
    assert regular_cell_side(is_ld=True) > regular_cell_side(is_ld=False)


def test_cells_for_wafer_translates_to_wafer_center():
    wafer = Wafer(u=1, v=-2, center=Point(100.0, -50.0), side=10.0, is_ld=True)
    cells = cells_for_wafer(wafer)
    mean_x = sum(cell.center.x for cell in cells) / len(cells)
    mean_y = sum(cell.center.y for cell in cells) / len(cells)
    assert isclose(mean_x, 100.0, abs_tol=1.0e-12)
    assert isclose(mean_y, -50.0, abs_tol=1.0e-12)
    assert {cell.wafer_u for cell in cells} == {1}
    assert {cell.wafer_v for cell in cells} == {-2}
