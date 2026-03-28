#!/usr/bin/env bash
set -euo pipefail

FIGURES_DIR="src/content/figures"
OUT_DIR="public/images/figures"

mkdir -p "$OUT_DIR"

for typ in "$FIGURES_DIR"/*.typ; do
  [ -f "$typ" ] || continue
  name="$(basename "${typ%.typ}")"
  out="$OUT_DIR/$name.svg"

  if [ "$typ" -nt "$out" ]; then
    echo "compiling $name.typ → $out"
    typst compile --format svg "$typ" "$out"
  else
    echo "skip $name.typ (up to date)"
  fi
done
