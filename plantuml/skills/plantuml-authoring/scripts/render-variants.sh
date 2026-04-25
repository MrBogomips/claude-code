#!/usr/bin/env bash
# Render every variant in a run directory to SVG + PNG.
# Usage: render-variants.sh <run-dir>
set -euo pipefail

RUN_DIR="${1:-$(cat /tmp/plantuml-tests-latest 2>/dev/null || true)}"
[ -n "$RUN_DIR" ] && [ -d "$RUN_DIR" ] || { echo "Usage: $0 <run-dir>"; exit 1; }

failed=0
for puml in "$RUN_DIR"/*/*/*.puml; do
  dir=$(dirname "$puml")
  base=$(basename "$puml" .puml)
  echo "Rendering $puml"

  # SVG (web target)
  if ! PLANTUML_TARGET=web plantuml -tsvg -o "$dir" "$puml" 2>"$dir/$base.svg.stderr"; then
    echo "  SVG render FAILED (see $dir/$base.svg.stderr)"
    failed=$((failed + 1))
  fi

  # PNG (docx target)
  if ! PLANTUML_TARGET=docx plantuml -tpng -Sscale=3 -o "$dir" "$puml" 2>"$dir/$base.png.stderr"; then
    echo "  PNG render FAILED (see $dir/$base.png.stderr)"
    failed=$((failed + 1))
  fi
done

# Post-check: PNG max width for docx target
echo
echo "Checking PNG widths (docx max 5800 px)…"
for png in "$RUN_DIR"/*/*/*.png; do
  [ -f "$png" ] || continue
  w=$(identify -format "%w" "$png" 2>/dev/null || echo 0)
  if [ "$w" -gt 5800 ]; then
    echo "  WARN: $png is ${w}px wide"
  fi
done

echo
if [ "$failed" -gt 0 ]; then
  echo "Render complete with $failed failure(s)."
  exit 1
else
  echo "Render complete; no failures."
fi
