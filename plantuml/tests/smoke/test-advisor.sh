#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILL="$PLUGIN_ROOT/skills/plantuml-advisor/SKILL.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
frontmatter() { awk 'NR == 1 && /^---$/ { f = 1; next } f && /^---$/ { exit } f { print }' "$1"; }

[[ -f "$SKILL" ]] || fail "missing $SKILL"
FM="$(frontmatter "$SKILL")"

grep -qE '^name:\s*plantuml-advisor' <<<"$FM" || fail "skill name wrong"
# A skill-level model pin would switch the session model for the rest of the turn.
grep -qE '^model:' <<<"$FM" && fail "advisor must not pin a model"
# Read-only by intent: allowed-tools only pre-approves, so Write/Edit are disallowed.
grep -qE '^disallowed-tools:.*Write' <<<"$FM" || fail "advisor must disallow Write"
grep -qE '^disallowed-tools:.*Edit' <<<"$FM" || fail "advisor must disallow Edit"
grep -qE '^description:.*Not for .*plantuml-review' <<<"$FM" || fail "advisor description must exclude plantuml-review"
for section in "Current type" "Intent reading" "Recommended type" "Migration sketch"; do
  grep -q "$section" "$SKILL" || fail "SKILL.md does not document section '$section'"
done
grep -q 'principles.md' "$SKILL" || fail "advisor must reference principles.md"

# No agent dispatch — advisor is interactive
if grep -qE '^allowed-tools:.*(Task|Agent)' <<<"$FM"; then
  fail "advisor must NOT use Task or Agent"
fi

echo "PASS: plantuml-advisor static smoke"
