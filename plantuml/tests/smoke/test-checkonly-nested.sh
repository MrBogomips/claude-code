#!/usr/bin/env bash
set -euo pipefail

# Executable smoke test: a docx-only Policy plus nested diagrams pass
# `plantuml -checkonly` with an explicit PLANTUML_TARGET, and the Policy's
# font, layout and target settings reach the rendered output.
# SKIPs (exit 0) when plantuml is not on PATH.

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GEN="$PLUGIN_ROOT/skills/plantuml-bootstrap/scripts/generate-config.sh"
FIXTURES="$PLUGIN_ROOT/tests/fixtures"

fail() { echo "FAIL: $*" >&2; exit 1; }

if ! command -v plantuml >/dev/null 2>&1; then
  echo "SKIP: plantuml not on PATH (test-checkonly-nested)"
  exit 0
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

checkonly() { PLANTUML_TARGET="$1" plantuml -checkonly "$2" >/dev/null 2>&1; }

# --- docx-only project: includes relative to each diagram's own directory ---
cp -R "$FIXTURES/docx-only-project" "$WORK/docx"
cd "$WORK/docx"
"$GEN" generate >/dev/null

for f in diagrams/Overview.puml diagrams/auth/Login.puml; do
  checkonly docx "$f" || fail "$f fails -checkonly with PLANTUML_TARGET=docx"
done
( unset PLANTUML_TARGET; plantuml -checkonly diagrams/Overview.puml >/dev/null 2>&1 ) \
  || fail "unset PLANTUML_TARGET does not fall back to the primary target docx"
if checkonly web diagrams/Overview.puml; then
  fail "undeclared target web passed -checkonly; the explicit target must be honored"
fi

PLANTUML_TARGET=docx plantuml -tsvg -o "$WORK/svg-docx" diagrams/Overview.puml >/dev/null 2>&1 \
  || fail "docx SVG render failed"
svg="$WORK/svg-docx/Overview.svg"
# SVG sizes are scaled by the target dpi: docx sets dpi 150, so 16 pt renders as 16 * 150 / 96 = 25.
grep -q 'font-size="25"' "$svg" || fail "Base font size 16 does not reach the render"
grep -q 'font-family="[^"]*Inter' "$svg" || fail "Font family is overridden by the built-in theme"

# --- custom theme: per-target font sizes derive from the Policy base size ---
# Expected SVG sizes: pptx 14 + 4 = 18 at dpi 150 -> 28.125; pdf 14 - 2 = 12 at
# dpi 300 -> 37.5; web 14 with no dpi override.
mkdir -p "$WORK/custom/diagrams" && cd "$WORK/custom"
cat > CLAUDE.md <<'EOF'
## PlantUML Policy
- **Primary target**: `pptx`
- **Additional targets**: `pdf`, `web`
- **Theme**: `custom`
- **Brand colors**:
  - primary: `#0B5FFF`
  - accent: `#F59E0B`
  - neutral: `#475569`
  - surface: `#F8FAFC`
  - danger: `#DC2626`
- **Layout engine**: `dot`
EOF
cp -R "$FIXTURES/docx-only-project/diagrams/." diagrams/
"$GEN" generate >/dev/null
for pair in pptx:28.125 pdf:37.5 web:14; do
  t="${pair%%:*}" size="${pair##*:}"
  checkonly "$t" diagrams/Overview.puml || fail "custom: -checkonly fails for target $t"
  # A sequence diagram must survive the left-to-right pptx target.
  checkonly "$t" diagrams/auth/Login.puml || fail "custom: sequence diagram fails -checkonly for target $t"
  PLANTUML_TARGET="$t" plantuml -tsvg -o "$WORK/svg-$t" diagrams/Overview.puml >/dev/null 2>&1 \
    || fail "custom: SVG render fails for target $t"
  grep -q "font-size=\"$size\"" "$WORK/svg-$t/Overview.svg" || fail "custom: target $t does not render at font size $size"
done
grep -qi '0B5FFF' "$WORK/svg-web/Overview.svg" || fail "custom: primary brand color missing from the render"

# --- the committed minimal-project fixture, including the nested diagram ---
cd "$FIXTURES/minimal-project"
for f in diagrams/Valid.puml diagrams/nested/Nested.puml; do
  checkonly web "$f" || fail "fixture $f fails -checkonly with PLANTUML_TARGET=web"
done
if checkonly web diagrams/Broken.puml; then fail "fixture Broken.puml passed -checkonly"; fi

echo "PASS: checkonly with explicit target on nested diagrams"
