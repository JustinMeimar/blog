#!/usr/bin/env bash
set -euo pipefail

FIGURES_DIR="$HOME/tools/figure-factory"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$SCRIPT_DIR/public/images/figures"

mkdir -p "$OUT_DIR"

LIB_DIR="$FIGURES_DIR/lib"
lib_changed=false
for typ in "$FIGURES_DIR"/*.typ; do
  [ -f "$typ" ] || continue
  name="$(basename "${typ%.typ}")"
  out="$OUT_DIR/$name.svg"

  needs_build=false
  if [ ! -f "$out" ] || [ "$typ" -nt "$out" ]; then
    needs_build=true
  elif [ -d "$LIB_DIR" ]; then
    for lib in "$LIB_DIR"/*.typ; do
      [ -f "$lib" ] || continue
      if [ "$lib" -nt "$out" ]; then
        needs_build=true
        break
      fi
    done
  fi

  if $needs_build; then
    echo "compiling $name.typ → $out"
    typst compile --format svg "$typ" "$out"
  else
    echo "skip $name.typ (up to date)"
  fi
done
