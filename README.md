# ChrisGeometry

Python port of the reusable geometry logic from Chris Seez's HGCAL Hex macOS application.

The `original` branch is treated as a protected archival import of the Xcode/Cocoa application. The `main` branch contains the Python implementation.

## What is ported now

- Compact DetId encoding and decoding helpers.
- Basic wafer and cell geometry primitives.
- The nearest-neighbour algorithm from `HXGNeighbourFinder`.
- An in-memory geometry adapter for tests and early studies.
- A tolerant numeric flat-file reader.
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

Draw a best-effort SVG from a numeric flat file:

```bash
hgcalgeom draw-flatfile data/v17-22042022-cmssw_flatfile.txt layer.svg --wafer-side 1.0
```

## Development notes

This is not a literal GUI port. The Cocoa/AppKit code, XIB files, and Xcode project are intentionally left in the `original` branch. The Python package ports the computational pieces first, with a small API that can later be backed by a stricter parser for the chosen HGCAL flat-file format.

The current flat-file parser is deliberately tolerant: it preserves each raw line and extracts numeric fields. Once the exact production input file is selected, the parser should be specialized and covered by regression tests.

## Tests

```bash
python3 -m pytest
```
