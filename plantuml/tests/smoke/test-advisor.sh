#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILL="$PLUGIN_ROOT/skills/plantuml-advisor/SKILL.md"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "$SKILL" ]] || fail "missing $SKILL"

grep -qE '^name:\s*plantuml-advisor' "$SKILL" || fail "skill name wrong"
grep -qE '^model:\s*sonnet' "$SKILL" || fail "skill not sonnet"
for section in "Current type" "Intent reading" "Recommended type" "Migration sketch"; do
  grep -q "$section" "$SKILL" || fail "SKILL.md does not document section '$section'"
done
grep -q 'principles.md' "$SKILL" || fail "advisor must reference principles.md"

echo "PASS: plantuml-advisor static smoke"
