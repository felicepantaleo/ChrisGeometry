"""Command-line interface for hgcalgeom."""

from __future__ import annotations

import argparse
import json
from dataclasses import asdict
from pathlib import Path

from .cells import cells_for_wafers
from .detid import decode_detid, encode_detid
from .geometry import Point, Wafer
from .interface import InMemoryGeometry, default_cell_set
from .layer_map import guess_wafers_from_records, parse_chris_geometry, read_records
from .neighbours import NeighbourFinder
from .plotting import write_cells_svg, write_combined_layer_pdf, write_combined_layer_svg, write_tiles_svg, write_wafers_svg
from .tile import tiles_for_layer


def _parse_int(value: str) -> int:
    return int(value, 0)


def _parse_layer_list(value: str) -> list[int]:
    layers: list[int] = []
    for chunk in value.split(","):
        chunk = chunk.strip()
        if not chunk:
            continue
        if "-" in chunk:
            first, last = chunk.split("-", 1)
            layers.extend(range(int(first), int(last) + 1))
        else:
            layers.append(int(chunk))
    return sorted(dict.fromkeys(layers))


def _default_layers() -> list[int]:
    return list(range(1, 48))


def _layer_objects(args: argparse.Namespace, layer: int):
    wafers = parse_chris_geometry(args.silicon, layer=layer, wafer_side=args.wafer_side) if args.silicon else []
    cells = cells_for_wafers(wafers) if args.show_cells else []
    tiles = tiles_for_layer(args.tiles, layer=layer) if args.tiles and args.show_tiles else []
    return wafers, cells, tiles


def _write_layer_outputs(
    *,
    output_base: Path,
    layer: int,
    wafers,
    cells,
    tiles,
    show_wafers: bool,
    show_cells: bool,
    show_tiles: bool,
    write_svg: bool,
    write_pdf: bool,
) -> tuple[Path | None, Path | None]:
    title = f"HGCAL layer {layer}"
    svg_path = output_base.with_suffix(".svg") if write_svg else None
    pdf_path = output_base.with_suffix(".pdf") if write_pdf else None
    if write_svg:
        write_combined_layer_svg(
            svg_path,
            wafers=wafers,
            cells=cells,
            tiles=tiles,
            title=title,
            show_wafers=show_wafers,
            show_cells=show_cells,
            show_tiles=show_tiles,
        )
    if write_pdf:
        write_combined_layer_pdf(
            pdf_path,
            wafers=wafers,
            cells=cells,
            tiles=tiles,
            title=title,
            show_wafers=show_wafers,
            show_cells=show_cells,
            show_tiles=show_tiles,
        )
    return svg_path, pdf_path


def cmd_decode(args: argparse.Namespace) -> int:
    decoded = decode_detid(_parse_int(args.detid))
    print(json.dumps(asdict(decoded), indent=2, sort_keys=True))
    return 0


def cmd_encode(args: argparse.Namespace) -> int:
    raw = encode_detid(
        wafer_u=args.wafer_u,
        wafer_v=args.wafer_v,
        cell_u=args.cell_u,
        cell_v=args.cell_v,
        layer=args.layer,
        detector=args.detector,
    )
    print(f"0x{raw:08x}")
    return 0


def cmd_neighbours(args: argparse.Namespace) -> int:
    decoded = decode_detid(_parse_int(args.detid))
    geom = InMemoryGeometry()
    for du in range(-1, 2):
        for dv in range(-1, 2):
            geom.add_wafer(
                Wafer(
                    u=decoded.wafer_u + du,
                    v=decoded.wafer_v + dv,
                    center=Point(float(du), float(dv)),
                    side=1.0,
                    is_ld=args.ld,
                    placement=args.placement,
                )
            )
    geom.set_cells(hd=not args.ld, partial_type=0, cells=default_cell_set(hd=not args.ld))
    finder = NeighbourFinder(geom)
    print(json.dumps([f"0x{x:08x}" for x in finder.nearest_neighbours(_parse_int(args.detid))], indent=2))
    return 0


def cmd_draw(args: argparse.Namespace) -> int:
    records = read_records(args.input)
    wafers = guess_wafers_from_records(records, wafer_side=args.wafer_side)
    write_wafers_svg(wafers, args.output, title=Path(args.input).name)
    print(f"wrote {len(wafers)} wafers to {args.output}")
    return 0


def cmd_draw_chris(args: argparse.Namespace) -> int:
    wafers = parse_chris_geometry(args.input, layer=args.layer, wafer_side=args.wafer_side)
    title = Path(args.input).name if args.layer is None else f"{Path(args.input).name}, layer {args.layer}"
    write_wafers_svg(wafers, args.output, title=title)
    print(f"wrote {len(wafers)} wafers to {args.output}")
    return 0


def cmd_draw_cells(args: argparse.Namespace) -> int:
    wafers = parse_chris_geometry(args.input, layer=args.layer, wafer_side=args.wafer_side)
    cells = cells_for_wafers(wafers)
    title = f"{Path(args.input).name}, silicon cells, layer {args.layer}"
    write_cells_svg(cells, args.output, title=title)
    print(f"wrote {len(cells)} cells from {len(wafers)} wafers to {args.output}")
    return 0


def cmd_draw_tiles(args: argparse.Namespace) -> int:
    tiles = tiles_for_layer(args.input, layer=args.layer)
    title = f"{Path(args.input).name}, layer {args.layer}"
    write_tiles_svg(tiles, args.output, title=title)
    print(f"wrote {len(tiles)} tiles to {args.output}")
    return 0


def cmd_draw_layer(args: argparse.Namespace) -> int:
    wafers, cells, tiles = _layer_objects(args, args.layer)
    output = Path(args.output)
    suffix = output.suffix.lower()
    write_svg = suffix != ".pdf"
    write_pdf = suffix == ".pdf" or args.pdf
    base = output.with_suffix("") if suffix in {".svg", ".pdf"} else output
    svg_path, pdf_path = _write_layer_outputs(
        output_base=base,
        layer=args.layer,
        wafers=wafers,
        cells=cells,
        tiles=tiles,
        show_wafers=args.show_wafers,
        show_cells=args.show_cells,
        show_tiles=args.show_tiles,
        write_svg=write_svg,
        write_pdf=write_pdf,
    )
    produced = [str(path) for path in (svg_path, pdf_path) if path is not None]
    print(
        f"wrote layer {args.layer}: {len(wafers)} wafers, {len(cells)} cells, "
        f"{len(tiles)} tiles -> {', '.join(produced)}"
    )
    return 0


def cmd_export_all_layers(args: argparse.Namespace) -> int:
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    layers = _parse_layer_list(args.layers) if args.layers else _default_layers()
    write_svg = args.format in {"svg", "both"}
    write_pdf = args.format in {"pdf", "both"}
    written = 0
    for layer in layers:
        wafers, cells, tiles = _layer_objects(args, layer)
        if not wafers and not tiles:
            print(f"skip layer {layer}: no silicon wafers or tiles")
            continue
        base = output_dir / f"layer_{layer:02d}"
        svg_path, pdf_path = _write_layer_outputs(
            output_base=base,
            layer=layer,
            wafers=wafers,
            cells=cells,
            tiles=tiles,
            show_wafers=args.show_wafers,
            show_cells=args.show_cells,
            show_tiles=args.show_tiles,
            write_svg=write_svg,
            write_pdf=write_pdf,
        )
        produced = [str(path.name) for path in (svg_path, pdf_path) if path is not None]
        print(f"layer {layer:02d}: {len(wafers)} wafers, {len(cells)} cells, {len(tiles)} tiles -> {', '.join(produced)}")
        written += len(produced)
    print(f"wrote {written} files in {output_dir}")
    return 0


def add_layer_plot_options(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--wafer-side", type=float, help="Override display wafer side in mm")
    parser.add_argument("--show-wafers", action=argparse.BooleanOptionalAction, default=True)
    parser.add_argument("--show-cells", action=argparse.BooleanOptionalAction, default=True)
    parser.add_argument("--show-tiles", action=argparse.BooleanOptionalAction, default=True)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="hgcalgeom")
    sub = parser.add_subparsers(dest="command", required=True)

    decode = sub.add_parser("decode-detid", help="Decode a compact Hex DetId")
    decode.add_argument("detid", help="DetId in decimal or 0x hexadecimal form")
    decode.set_defaults(func=cmd_decode)

    encode = sub.add_parser("encode-detid", help="Encode a compact Hex DetId")
    encode.add_argument("--wafer-u", type=int, required=True)
    encode.add_argument("--wafer-v", type=int, required=True)
    encode.add_argument("--cell-u", type=int, required=True)
    encode.add_argument("--cell-v", type=int, required=True)
    encode.add_argument("--layer", type=int)
    encode.add_argument("--detector", type=_parse_int)
    encode.set_defaults(func=cmd_encode)

    neighbours = sub.add_parser("neighbours", help="Compute neighbours in a simple in-memory geometry")
    neighbours.add_argument("detid", help="DetId in decimal or 0x hexadecimal form")
    neighbours.add_argument("--ld", action="store_true", help="Treat wafers as LD instead of HD")
    neighbours.add_argument("--placement", type=int, default=0)
    neighbours.set_defaults(func=cmd_neighbours)

    draw = sub.add_parser("draw-flatfile", help="Draw a best-effort SVG from a numeric flat file")
    draw.add_argument("input")
    draw.add_argument("output")
    draw.add_argument("--wafer-side", type=float, default=1.0)
    draw.set_defaults(func=cmd_draw)

    draw_chris = sub.add_parser("draw-chris-geometry", help="Draw an SVG from Chris's silicon geometry dump")
    draw_chris.add_argument("input")
    draw_chris.add_argument("output")
    draw_chris.add_argument("--layer", type=int, help="Only draw this layer")
    draw_chris.add_argument("--wafer-side", type=float, help="Override display wafer side in mm")
    draw_chris.set_defaults(func=cmd_draw_chris)

    draw_cells = sub.add_parser("draw-silicon-cells", help="Draw regular silicon grid cells from a silicon flat file")
    draw_cells.add_argument("input")
    draw_cells.add_argument("output")
    draw_cells.add_argument("--layer", type=int, required=True, help="Silicon layer to draw")
    draw_cells.add_argument("--wafer-side", type=float, help="Override display wafer side in mm")
    draw_cells.set_defaults(func=cmd_draw_cells)

    draw_tiles = sub.add_parser("draw-tile-layer", help="Draw an SVG from a scintillator tile file")
    draw_tiles.add_argument("input")
    draw_tiles.add_argument("output")
    draw_tiles.add_argument("--layer", type=int, required=True, help="Scintillator layer to draw")
    draw_tiles.set_defaults(func=cmd_draw_tiles)

    draw_layer = sub.add_parser("draw-layer", help="Draw one combined silicon and scintillator layer")
    draw_layer.add_argument("--silicon", help="Silicon flat-file path")
    draw_layer.add_argument("--tiles", help="Scintillator tile-file path")
    draw_layer.add_argument("--layer", type=int, required=True)
    draw_layer.add_argument("--output", required=True)
    draw_layer.add_argument("--pdf", action="store_true", help="Also write a PDF next to the SVG")
    add_layer_plot_options(draw_layer)
    draw_layer.set_defaults(func=cmd_draw_layer)

    export_all = sub.add_parser("export-all-layers", help="Export SVG/PDF files for all layers")
    export_all.add_argument("--silicon", required=True, help="Silicon flat-file path")
    export_all.add_argument("--tiles", help="Scintillator tile-file path")
    export_all.add_argument("--output-dir", required=True)
    export_all.add_argument("--layers", help="Layer list, for example 1-47 or 1,2,34-47")
    export_all.add_argument("--format", choices=["svg", "pdf", "both"], default="both")
    add_layer_plot_options(export_all)
    export_all.set_defaults(func=cmd_export_all_layers)

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
