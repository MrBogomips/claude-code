#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILL="$PLUGIN_ROOT/skills/plantuml-migrate/SKILL.md"
GEN="$PLUGIN_ROOT/skills/plantuml-bootstrap/scripts/generate-config.sh"
VM="$PLUGIN_ROOT/skills/plantuml-validate/scripts/validate-matrix.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "$SKILL" ]] || fail "missing $SKILL"
[[ -x "$GEN" ]] || fail "missing or non-executable $GEN"
[[ -x "$VM" ]] || fail "missing or non-executable $VM"

grep -qE '^name:\s*plantuml-migrate' "$SKILL" || fail "skill name wrong"
# Expected files come from the shared generator, never from the model.
grep -qF 'plantuml-bootstrap/scripts/generate-config.sh' "$SKILL" || fail "migrate does not use the bundled generator"
grep -qF 'generate --policy CLAUDE.md --out "$EXPECTED/.plantuml"' "$SKILL" || fail "migrate does not generate into a temp dir"
grep -qF 'diff -r .plantuml "$EXPECTED/.plantuml"' "$SKILL" || fail "migrate does not diff against the generator output"
grep -qF 'bash "$GEN" verify .plantuml --against "$EXPECTED/.plantuml"' "$SKILL" \
  || fail "migrate does not detect hand edits from the header hash against the expected output"
grep -q 'without asking' "$SKILL" && grep -qF 'verify --against` reports it' "$SKILL" \
  || fail "migrate does not say that a promoted file is regenerated without asking again"
grep -q 'no-header' "$SKILL" || fail "migrate does not handle partials without a header"
grep -qF 'cp -R .plantuml "$BACKUP/"' "$SKILL" || fail "migrate does not back up before writing"
grep -qF 'bash "$VM" --level checkonly' "$SKILL" || fail "migrate does not validate with an explicit target per cell"

# The edit-plan step and its agent are gone.
[[ ! -e "$PLUGIN_ROOT/agents/puml-migrator" ]] || fail "puml-migrator agent should be removed"
grep -q 'puml-migrator' "$SKILL" && fail "migrate still dispatches puml-migrator"
grep -qE '^allowed-tools:.*Agent' "$SKILL" && fail "migrate no longer dispatches agents"

echo "PASS: plantuml-migrate static smoke"
