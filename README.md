# ChrisGeometry

Python port of the reusable geometry logic from Chris Seez's HGCAL Hex macOS application.

The `original` branch is treated as a protected archival import of the Xcode/Cocoa application. The `main` branch contains the Python implementation.

## What is ported now

- Compact DetId encoding and decoding helpers.
- Basic wafer and cell geometry primitives.
- The nearest-neighbour algorithm from `HXGNeighbourFinder`.
- An in-memory geometry adapter for tests and early studies.
- A parser for Chris's older Hex text geometry dump format.
- A simple SVG exporter for wafer layouts.
- A command-line interface named `hgcalgeom`.

## Install

```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install --upgrade pip
python3 -m pip install -e '.[test,plot]'
```

## Commands

Decode a DetId:

```bash
hgcalgeom decode-detid 0x90000000
```

Encode a DetId:

```bash
hgcalgeom encode-detid --wafer-u -3 --wafer-v 5 --cell-u 7 --cell-v 9 --layer 30
```

Find neighbours in a small synthetic geometry:

```bash
hgcalgeom neighbours 0x90000287
```

Draw a best-effort SVG from a generic numeric flat file:

```bash
hgcalgeom draw-flatfile data/demo/geomCMSSW10052021_layer1_excerpt.txt layer_generic.svg --wafer-side 95
```

Draw from Chris's Hex geometry dump format:

```bash
hgcalgeom draw-chris-geometry data/demo/geomCMSSW10052021_layer1_excerpt.txt layer1.svg --layer 1
```

The demo excerpt was copied from `Hex/geomCMSSW10052021_corrected.txt` in the `original` branch. Its data lines have the form:

```text
layer partial_type sensor_type x_mm y_mm placement wafer_u wafer_v
```

For example:

```text
1 0 h120  502.32    0.00 0 3 0
```

## Development notes

This is not a literal GUI port. The Cocoa/AppKit code, XIB files, and Xcode project are intentionally left in the `original` branch. The Python package ports the computational pieces first, with a small API that can later be backed by a stricter parser for the chosen HGCAL flat-file format.

The current generic flat-file parser is deliberately tolerant: it preserves each raw line and extracts numeric fields. The Chris geometry parser is more specific and should be preferred for files following the older Hex dump format.

## Tests

```bash
python3 -m pytest
```
