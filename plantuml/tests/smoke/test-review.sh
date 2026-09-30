#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILL="$PLUGIN_ROOT/skills/plantuml-review/SKILL.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
frontmatter() { awk 'NR == 1 && /^---$/ { f = 1; next } f && /^---$/ { exit } f { print }' "$1"; }

[[ -f "$SKILL" ]] || fail "missing $SKILL"
FM="$(frontmatter "$SKILL")"

grep -qE '^name:\s*plantuml-review' <<<"$FM" || fail "skill name wrong"
grep -qE '^model:' <<<"$FM" && fail "review must not pin a model"
grep -qE '^disallowed-tools:.*Write' <<<"$FM" || fail "review must disallow Write"
grep -qE '^disallowed-tools:.*Edit' <<<"$FM" || fail "review must disallow Edit"
grep -qE '^description:.*Not for .*plantuml-advisor' <<<"$FM" || fail "review description must exclude plantuml-advisor"
# The compile check passes the Policy's primary target explicitly.
grep -qF 'PLANTUML_TARGET=<Primary target> plantuml -checkonly' "$SKILL" || fail "review runs -checkonly without an explicit target"
# Required output sections
for section in "Type fit" "Detail level" "Layout" "Labels"; do
  grep -q "$section" "$SKILL" || fail "SKILL.md does not document section '$section'"
done
# No agent dispatch — review is interactive
if grep -qE '^allowed-tools:.*(Task|Agent)' <<<"$FM"; then
  fail "review must NOT use Task or Agent"
fi

echo "PASS: plantuml-review static smoke"
