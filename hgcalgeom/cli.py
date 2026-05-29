"""Command-line interface for hgcalgeom."""

from __future__ import annotations

import argparse
import json
from dataclasses import asdict
from pathlib import Path

from .detid import decode_detid, encode_detid
from .geometry import Point, Wafer
from .interface import InMemoryGeometry, default_cell_set
from .layer_map import guess_wafers_from_records, read_records
from .neighbours import NeighbourFinder
from .plotting import write_wafers_svg


def _parse_int(value: str) -> int:
    return int(value, 0)


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
    return 0


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

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
