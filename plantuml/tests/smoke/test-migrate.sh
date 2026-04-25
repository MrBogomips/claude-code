#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILL="$PLUGIN_ROOT/skills/plantuml-migrate/SKILL.md"
AGENT="$PLUGIN_ROOT/agents/puml-migrator/AGENT.md"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "$SKILL" ]] || fail "missing $SKILL"
[[ -f "$AGENT" ]] || fail "missing $AGENT"

grep -qE '^name:\s*plantuml-migrate' "$SKILL" || fail "skill name wrong"
grep -qiE 'manual.edit.detect|hash|divergent' "$SKILL" || fail "skill missing manual-edit detection language"

grep -qE '^name:\s*puml-migrator' "$AGENT" || fail "agent name wrong"
grep -qE '^model:\s*haiku' "$AGENT" || fail "agent not haiku"
grep -qE '^allowed-tools:.*Edit' "$AGENT" || fail "agent missing Edit"

echo "PASS: plantuml-migrate static smoke"
