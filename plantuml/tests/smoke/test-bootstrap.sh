#!/usr/bin/env bash
set -euo pipefail

# Static smoke test for plantuml-bootstrap: validates SKILL.md exists and
# has expected frontmatter + required sections. The generator's behaviour
# is tested in test-generate-config.sh.

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

# Generation goes through the bundled script, validated per declared target.
[[ -x "$PLUGIN_ROOT/skills/plantuml-bootstrap/scripts/generate-config.sh" ]] || fail "generator script missing or not executable"
grep -qF 'bash "$GEN" generate --policy CLAUDE.md --out .plantuml' "$SKILL" || fail "bootstrap does not generate with the bundled script"
grep -qF 'PLANTUML_TARGET="$t" plantuml -checkonly' "$SKILL" || fail "bootstrap smoke check does not pass each target explicitly"
grep -q 'plantuml-migrate' "$SKILL" || fail "bootstrap does not route regeneration to plantuml-migrate"

echo "PASS: plantuml-bootstrap static smoke"
