# ChrisGeometry

Python port of the reusable geometry logic from Chris Seez's HGCAL Hex macOS application.

The `original` branch is treated as a protected archival import of the Xcode/Cocoa application. The `main` branch contains the Python implementation, data files, tests, and GitHub Actions layer export workflow.

## Status

This is not a literal GUI port of the macOS application. The goal is to preserve the useful geometry functionality in a form that can run on CERN Alma 9, batch nodes, or containers.

Currently implemented:

- Silicon layer flat-file parser for the documented format:

  ```text
  layer wafer_type sensor_type x_mm y_mm placement wafer_u wafer_v cassette
  ```

- Scintillator tile-file parser for the documented format:

  ```text
  layer ring inner_radius outer_radius sipm_area word0 word1 word2 word3 production
  ```

- Compact DetId encoding and decoding helpers.
- Basic wafer and cell geometry primitives.
- LD and HD silicon cell generation.
- Partial-wafer clipping using the Zoltan/dicing-line points ported from Chris's Mac application.
- SVG drawing for silicon wafers, silicon cells, scintillator tiles, and combined layers.
- PDF drawing for combined layers.
- Batch export of all layers.
- GitHub Actions artifact production for layer PDFs.
- Unit tests for parsers, DetId helpers, cells, neighbours, plotting, and CLI commands.

Still to refine:

- Exact mouse-bite and fine edge-cell details where the Mac app uses the full active-wafer geometry.
- A strict one-to-one validation suite against reference Mac-app drawings.
- Full hardware mapping and ECON-D / trigger-cell lookup tools.

## Install

```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install --upgrade pip
python3 -m pip install -e '.[test,plot]'
python3 -m pip install reportlab
```

`reportlab` is needed only for PDF export.

## Basic commands

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

## Draw one layer

Silicon only:

```bash
hgcalgeom draw-layer \
  --silicon data/modmapv16.6_cmssw_flatfile.txt \
  --layer 1 \
  --output layer_01.svg \
  --show-wafers \
  --show-cells \
  --no-show-tiles
```

Silicon plus scintillator tiles:

```bash
hgcalgeom draw-layer \
  --silicon data/modmapv16.6_cmssw_flatfile.txt \
  --tiles data/tilefile-Nov2023-v3.txt \
  --layer 34 \
  --output layer_34.svg \
  --pdf \
  --show-wafers \
  --show-cells \
  --show-tiles
```

This writes `layer_34.svg` and `layer_34.pdf`.

## Export all layers

```bash
hgcalgeom export-all-layers \
  --silicon data/modmapv16.6_cmssw_flatfile.txt \
  --tiles data/tilefile-Nov2023-v3.txt \
  --output-dir layers_export \
  --layers 1-47 \
  --format pdf \
  --show-wafers \
  --show-cells \
  --show-tiles
```

This produces:

```text
layers_export/layer_01.pdf
layers_export/layer_02.pdf
...
layers_export/layer_47.pdf
```

Use `--format svg` or `--format both` for SVG output or combined SVG/PDF output.

## GitHub Actions artifacts

The workflow

```text
.github/workflows/export-layers.yml
```

runs on pushes, pull requests, and manual dispatch. It exports the requested layers as PDF files and uploads two artifacts:

```text
hgcal-layer-pdfs
hgcal-layer-pdfs-tarball
```

The default manual dispatch setting exports layers `1-47`.

## Data files

The repository includes data files under `data/`, including:

```text
data/modmapv16.6_cmssw_flatfile.txt
data/tilefile-Nov2023-v3.txt
```

The older demo excerpt is kept under:

```text
data/demo/geomCMSSW10052021_layer1_excerpt.txt
```

## Development notes

The Cocoa/AppKit code, XIB files, and Xcode project are intentionally left in the `original` branch. The Python package ports the computational and drawing pieces in a Linux-friendly form.

The current partial-wafer implementation uses the Zoltan/dicing-line constants from Chris's Mac application and clips the generated cell polygons to the active wafer polygon. This is already sufficient for useful layer drawings, but the exact mouse-bite shapes and all fine edge-cell details should still be validated against the original application.

## Tests

```bash
python3 -m pytest
```
