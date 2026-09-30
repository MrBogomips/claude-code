#!/usr/bin/env bash
set -euo pipefail

# Static smoke for plantuml-lint: validates skill + agent files exist
# with expected structure. Behavioral testing of the lint output happens
# in Phase 7 manual integration.

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILL="$PLUGIN_ROOT/skills/plantuml-lint/SKILL.md"
AGENT="$PLUGIN_ROOT/agents/puml-linter/AGENT.md"
FIXTURE="$PLUGIN_ROOT/tests/fixtures/minimal-project"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "$SKILL" ]] || fail "missing $SKILL"
[[ -f "$AGENT" ]] || fail "missing $AGENT"
[[ -d "$FIXTURE/.plantuml" ]] || fail "fixture .plantuml/ missing"
[[ -f "$FIXTURE/diagrams/Valid.puml" ]] || fail "fixture Valid.puml missing"
[[ -f "$FIXTURE/diagrams/Drift.puml" ]] || fail "fixture Drift.puml missing"
[[ -f "$FIXTURE/diagrams/nested/Nested.puml" ]] || fail "fixture nested diagram missing"
grep -qF '!include ../../.plantuml/_base.puml' "$FIXTURE/diagrams/nested/Nested.puml" || fail "nested fixture does not include relative to its own directory"

# Skill frontmatter
grep -qE '^name:\s*plantuml-lint' "$SKILL" || fail "skill name wrong"
grep -qE '^allowed-tools:.*Agent' "$SKILL" || fail "skill missing Agent"

# Agent frontmatter: agents restrict tools with `tools:`
grep -qE '^name:\s*puml-linter' "$AGENT" || fail "agent name wrong"
grep -qE '^model:\s*haiku' "$AGENT" || fail "agent missing haiku model"
grep -qE '^tools:' "$AGENT" || fail "agent must restrict tools with tools:"

# Include files are exempt from the diagram-only rules; include targets are checked.
grep -q 'R6 (include targets exist)' "$AGENT" || fail "agent does not define R6"
grep -q 'R1–R6' "$AGENT" || fail "agent rule range is not R1–R6"
grep -qE '\.iuml.*R1, R3, R4 and R5|R1, R3, R4 and R5.*\.iuml' <<<"$(tr '\n' ' ' < "$AGENT")" || fail "agent does not exempt .iuml include files"
grep -q 'R1–R6' "$PLUGIN_ROOT/skills/plantuml-authoring/SKILL.md" || fail "authoring SKILL.md restates an outdated rule range"

# Spot-check that the fixture's Drift file would actually produce
# violations: it contains a hex literal AND a hardcoded skinparam.
grep -qE '#[0-9A-Fa-f]{6}' "$FIXTURE/diagrams/Drift.puml" || \
  fail "fixture Drift.puml does not contain a hex literal"
grep -qE 'skinparam (defaultFontName|defaultFontSize|backgroundColor|ArrowColor)' "$FIXTURE/diagrams/Drift.puml" || \
  fail "fixture Drift.puml does not contain a base-set skinparam"

echo "PASS: plantuml-lint static smoke"
