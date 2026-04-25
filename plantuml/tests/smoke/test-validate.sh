#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILL="$PLUGIN_ROOT/skills/plantuml-validate/SKILL.md"
RENDERER="$PLUGIN_ROOT/agents/puml-renderer/AGENT.md"
VISUAL="$PLUGIN_ROOT/agents/puml-visual-checker/AGENT.md"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "$SKILL" ]] || fail "missing $SKILL"
[[ -f "$RENDERER" ]] || fail "missing $RENDERER"
[[ -f "$VISUAL" ]] || fail "missing $VISUAL"

grep -qE '^name:\s*plantuml-validate' "$SKILL" || fail "skill name wrong"
grep -qiE 'mode\s*=\s*(bless|check)' "$SKILL" || fail "skill missing mode arg doc"
grep -qiE 'level\s*=\s*(checkonly|svg-hash|png-perceptual)' "$SKILL" || fail "skill missing level arg doc"

grep -qE '^name:\s*puml-renderer' "$RENDERER" || fail "renderer name wrong"
grep -qE '^model:\s*haiku' "$RENDERER" || fail "renderer not haiku"

grep -qE '^name:\s*puml-visual-checker' "$VISUAL" || fail "visual-checker name wrong"
grep -qE '^model:\s*sonnet' "$VISUAL" || fail "visual-checker not sonnet"

echo "PASS: plantuml-validate static smoke"
