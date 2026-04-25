#!/usr/bin/env bash
# Copy the canonical test-variants into a fresh timestamped run dir.
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VARIANTS_DIR="$SKILL_DIR/test-variants"

if [ ! -d "$VARIANTS_DIR" ] || [ -z "$(ls -A "$VARIANTS_DIR" 2>/dev/null)" ]; then
  echo "ERROR: $VARIANTS_DIR is missing or empty. Run seed-variants.sh first."
  exit 1
fi

RUN_DATE="$(date +%Y-%m-%d)"
# Next run number (ls failure on no-match is fine under pipefail with || true)
existing=$( (ls -d "$HOME/temp/plantuml-tests/${RUN_DATE}-run-"* 2>/dev/null || true) | wc -l | awk '{print $1}')
next=$(printf '%02d' $((existing + 1)))
RUN_DIR="$HOME/temp/plantuml-tests/${RUN_DATE}-run-${next}"
mkdir -p "$RUN_DIR"
echo "Run directory: $RUN_DIR"

for type_dir in "$VARIANTS_DIR"/*/; do
  type_name=$(basename "$type_dir")
  for variant in minimal standard detailed; do
    src="$type_dir/$variant.puml"
    if [ -f "$src" ]; then
      dst="$RUN_DIR/$type_name/$variant"
      mkdir -p "$dst"
      cp "$src" "$dst/"
    else
      echo "SKIP: $type_name/$variant (no source)"
    fi
  done
done

cat > "$RUN_DIR/README.md" <<EOF
# PlantUML Test Run — $(date -u +"%Y-%m-%dT%H:%M:%SZ")

Variants generated from $VARIANTS_DIR.

Next steps:
  1. bash scripts/render-variants.sh $RUN_DIR
  2. Dispatch adversarial reviewers (see SKILL.md "Test harness")
  3. bash scripts/aggregate-reviews.sh $RUN_DIR
EOF

echo "$RUN_DIR" > /tmp/plantuml-tests-latest
echo "$RUN_DIR"
