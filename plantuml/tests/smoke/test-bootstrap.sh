#!/usr/bin/env bash
set -euo pipefail

# Static smoke test for plantuml-bootstrap: validates SKILL.md exists and
# has expected frontmatter + required sections. Behavioral testing happens
# in Phase 7 manual integration.

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILL="$PLUGIN_ROOT/skills/plantuml-bootstrap/SKILL.md"
CMD="$PLUGIN_ROOT/commands/plantuml-init.md"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "$SKILL" ]] || fail "missing $SKILL"
[[ -f "$CMD" ]] || fail "missing $CMD"

head -1 "$SKILL" | grep -q '^---$' || fail "SKILL.md missing frontmatter"
grep -qE '^name:\s*plantuml-bootstrap' "$SKILL" || fail "SKILL.md missing name"
grep -qE '^description:' "$SKILL" || fail "SKILL.md missing description"
grep -qE '^allowed-tools:.*Bash' "$SKILL" || fail "SKILL.md missing Bash in allowed-tools"

grep -q '\${CLAUDE_PLUGIN_ROOT}' "$SKILL" || fail "SKILL.md does not reference \${CLAUDE_PLUGIN_ROOT}"
grep -qiE 'mode\s*=\s*(bootstrap|reverse)' "$SKILL" || fail "SKILL.md does not document mode argument"

echo "PASS: plantuml-bootstrap static smoke"
