#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILL="$PLUGIN_ROOT/skills/plantuml-review/SKILL.md"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "$SKILL" ]] || fail "missing $SKILL"

grep -qE '^name:\s*plantuml-review' "$SKILL" || fail "skill name wrong"
grep -qE '^model:\s*sonnet' "$SKILL" || fail "skill not sonnet"
# Required output sections
for section in "Type fit" "Detail level" "Layout" "Labels"; do
  grep -q "$section" "$SKILL" || fail "SKILL.md does not document section '$section'"
done
# No agent dispatch — review is interactive
if grep -qE '^allowed-tools:.*Task' "$SKILL"; then
  fail "review must NOT use Task"
fi

echo "PASS: plantuml-review static smoke"
