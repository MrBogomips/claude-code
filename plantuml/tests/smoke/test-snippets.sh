#!/usr/bin/env bash
set -euo pipefail

# Executable smoke test: every snippet in plantuml-authoring/diagrams/*.md,
# saved as diagrams/<name>.puml in a generated project, passes
# `plantuml -checkonly` for all four targets, with a custom theme and with a
# left-to-right built-in theme. SKIPs (exit 0) when plantuml is not on PATH.

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GEN="$PLUGIN_ROOT/skills/plantuml-bootstrap/scripts/generate-config.sh"
DIAGRAMS="$PLUGIN_ROOT/skills/plantuml-authoring/diagrams"

fail() { echo "FAIL: $*" >&2; exit 1; }

if ! command -v plantuml >/dev/null 2>&1; then
  echo "SKIP: plantuml not on PATH (test-snippets)"
  exit 0
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# extract <dir>: one file per fenced plantuml block that uses the include chain.
# Fragments (blocks with an ellipsis) are skipped.
extract() {
  local dir="$1" md type
  mkdir -p "$dir"
  for md in "$DIAGRAMS"/*.md; do
    type="$(basename "$md" .md)"
    awk -v dir="$dir" -v type="$type" '
      /^```plantuml/ { inb = 1; buf = ""; next }
      inb && /^```/ {
        inb = 0; n++
        if (buf ~ /_base\.puml/ && buf !~ /…/) { f = dir "/" type "_" n ".puml"; printf "%s", buf > f; close(f) }
        next
      }
      inb { buf = buf $0 "\n" }
    ' "$md"
  done
}

check_project() {
  local label="$1" t count
  "$GEN" generate >/dev/null
  extract diagrams
  count="$(find diagrams -name '*.puml' | wc -l | awk '{print $1}')"
  [[ "$count" -ge 23 ]] || fail "$label: extracted only $count snippets"
  for t in web docx pdf pptx; do
    if ! out="$(PLANTUML_TARGET="$t" plantuml -checkonly diagrams/*.puml 2>&1)"; then
      echo "$out" | grep -i 'error' >&2 || true
      fail "$label: a snippet fails -checkonly for target $t"
    fi
  done
}

mkdir -p "$WORK/custom" && cd "$WORK/custom"
cat > CLAUDE.md <<'EOF'
## PlantUML Policy
- **Primary target**: `web`
- **Additional targets**: `docx`, `pdf`, `pptx`
- **Theme**: `custom`
- **Brand colors**:
  - primary: `#0B5FFF`
  - accent: `#F59E0B`
  - neutral: `#475569`
  - surface: `#F8FAFC`
  - danger: `#DC2626`
EOF
check_project "custom theme"

mkdir -p "$WORK/builtin" && cd "$WORK/builtin"
cat > CLAUDE.md <<'EOF'
## PlantUML Policy
- **Primary target**: `docx`
- **Additional targets**: `web`, `pdf`, `pptx`
- **Theme**: `plain`
- **Default direction**: `left-to-right`
- **Layout engine**: `smetana`
EOF
check_project "built-in theme, left-to-right"

echo "PASS: every authoring snippet compiles for every target"
