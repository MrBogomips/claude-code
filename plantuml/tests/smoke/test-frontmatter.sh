#!/usr/bin/env bash
set -euo pipefail

# Frontmatter hygiene for every plantuml skill and agent:
# - skills pin no model (a skill-level pin switches the session model for
#   the rest of the turn); agents keep theirs;
# - agents restrict tools with `tools:` (`allowed-tools:` has no effect there);
# - every SKILL.md stays under 500 lines;
# - every frontmatter block parses with a strict YAML parser (PyYAML), which
#   claude.ai uploads and package_skill.py use. Skipped without PyYAML.

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

fail() { echo "FAIL: $*" >&2; exit 1; }
frontmatter() { awk 'NR == 1 && /^---$/ { f = 1; next } f && /^---$/ { exit } f { print }' "$1"; }

skills=("$PLUGIN_ROOT"/skills/*/SKILL.md)
agents=("$PLUGIN_ROOT"/agents/*/AGENT.md)
[[ ${#skills[@]} -ge 8 ]] || fail "expected at least 8 skills"

for f in "${skills[@]}"; do
  rel="${f#"$PLUGIN_ROOT"/}"
  fm="$(frontmatter "$f")"
  [[ -n "$fm" ]] || fail "$rel has no frontmatter"
  grep -qE '^model:' <<<"$fm" && fail "$rel pins a model"
  lines="$(wc -l < "$f" | awk '{print $1}')"
  [[ "$lines" -lt 500 ]] || fail "$rel has $lines lines (limit 500)"
done

for f in "${agents[@]}"; do
  rel="${f#"$PLUGIN_ROOT"/}"
  fm="$(frontmatter "$f")"
  grep -qE '^tools:' <<<"$fm" || fail "$rel does not restrict tools with tools:"
  grep -qE '^allowed-tools:' <<<"$fm" && fail "$rel uses allowed-tools:, which agents ignore"
  grep -qE '^model:' <<<"$fm" || fail "$rel has no model pin"
done

if python3 -c 'import yaml' >/dev/null 2>&1; then
  for f in "${skills[@]}" "${agents[@]}"; do
    rel="${f#"$PLUGIN_ROOT"/}"
    frontmatter "$f" | python3 -c 'import sys, yaml; d = yaml.safe_load(sys.stdin); assert isinstance(d, dict) and d.get("name")' \
      2>/dev/null || fail "$rel frontmatter is not strict YAML with a name"
  done
else
  echo "SKIP: PyYAML not available; strict YAML parse not run"
fi

echo "PASS: plantuml frontmatter hygiene"
