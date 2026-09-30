#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILL="$PLUGIN_ROOT/skills/plantuml-validate/SKILL.md"
VM="$PLUGIN_ROOT/skills/plantuml-validate/scripts/validate-matrix.sh"
VISUAL="$PLUGIN_ROOT/agents/puml-visual-checker/AGENT.md"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "$SKILL" ]] || fail "missing $SKILL"
[[ -x "$VM" ]] || fail "missing or non-executable $VM"
[[ -f "$VISUAL" ]] || fail "missing $VISUAL"
[[ ! -e "$PLUGIN_ROOT/agents/puml-renderer" ]] || fail "puml-renderer agent should be replaced by validate-matrix.sh"

grep -qE '^name:\s*plantuml-validate' "$SKILL" || fail "skill name wrong"
grep -qiE 'mode\s*=\s*(bless|check)' "$SKILL" || fail "skill missing mode arg doc"
grep -qiE 'level\s*=\s*(checkonly|svg-hash|png-perceptual)' "$SKILL" || fail "skill missing level arg doc"
grep -qF 'scripts/validate-matrix.sh' "$SKILL" || fail "skill does not run validate-matrix.sh"
grep -q 'puml-renderer' "$SKILL" && fail "skill still dispatches puml-renderer"

# In bless mode the visual check runs before any baseline is written.
preview="$(grep -n -- '--mode preview' "$SKILL" | head -n 1 | cut -d: -f1)"
bless="$(grep -n -- '--mode bless --level svg-hash' "$SKILL" | head -n 1 | cut -d: -f1)"
[[ -n "$preview" && -n "$bless" && "$preview" -lt "$bless" ]] || fail "bless must run the visual check (preview) before writing baselines"

grep -qE '^name:\s*puml-visual-checker' "$VISUAL" || fail "visual-checker name wrong"
grep -qE '^model:\s*sonnet' "$VISUAL" || fail "visual-checker not sonnet"
grep -q '10% perceptual' "$VISUAL" && fail "visual-checker still claims a perceptual tolerance"
grep -q 'skipped' "$VISUAL" || fail "visual-checker does not skip the color check without a primary color"
# primary_color is passed only for a custom theme, with the same wording in both files.
rule="\`primary_color\` is the Policy's primary brand color only when Theme is \`custom\`, otherwise \`null\`"
flat() { tr '\n' ' ' < "$1" | tr -s ' '; }
grep -qF "$rule" <<<"$(flat "$SKILL")" || fail "validate does not pass primary_color only for Theme custom"
grep -qF "$rule" <<<"$(flat "$VISUAL")" || fail "visual-checker does not state the Theme custom rule"

echo "PASS: plantuml-validate static smoke"
