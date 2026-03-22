#!/usr/bin/env bash
# Layer 1: Connector cross-reference validation
# Checks that every ~~placeholder in SKILL.md files has a matching entry in CONNECTORS.md
# and that no connector is defined but never referenced.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0
WARNINGS=0

red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }

error() { red "ERROR: $*"; ERRORS=$((ERRORS + 1)); }
warn()  { yellow "WARN: $*"; WARNINGS=$((WARNINGS + 1)); }
ok()    { green "OK: $*"; }

for plugin_dir in "$REPO_ROOT"/*/; do
    [[ -d "$plugin_dir/.claude-plugin" ]] || continue
    plugin_name="$(basename "$plugin_dir")"
    connectors_md="$plugin_dir/CONNECTORS.md"

    echo ""
    echo "=== Checking connectors: $plugin_name ==="

    # Collect all ~~placeholder references from SKILL.md files
    declared_refs=()
    if [[ -d "$plugin_dir/skills" ]]; then
        while IFS= read -r ref; do
            declared_refs+=("$ref")
        done < <(grep -rIoh '~~[a-zA-Z ]*' "$plugin_dir/skills/" 2>/dev/null | sort -u || true)
    fi

    if [[ ${#declared_refs[@]} -eq 0 ]]; then
        ok "$plugin_name: no connector references found in skills"
        continue
    fi

    # Check CONNECTORS.md exists
    if [[ ! -f "$connectors_md" ]]; then
        error "$plugin_name: skills reference connectors but CONNECTORS.md is missing"
        for ref in "${declared_refs[@]}"; do
            error "$plugin_name: unresolved connector reference: $ref"
        done
        continue
    fi

    # Check each reference has a matching entry in CONNECTORS.md
    for ref in "${declared_refs[@]}"; do
        # Strip the ~~ prefix for matching
        placeholder="${ref#\~\~}"
        if ! grep -qi "$placeholder" "$connectors_md"; then
            error "$plugin_name: connector '$ref' referenced in skills but not defined in CONNECTORS.md"
        else
            ok "$plugin_name: connector '$ref' → defined in CONNECTORS.md"
        fi
    done

    # Check for orphan connectors (defined but never referenced)
    while IFS= read -r line; do
        # Extract placeholder names from the registry table
        placeholder="$(echo "$line" | grep -o '`~~[^`]*`' | sed 's/`//g; s/^~~//' || true)"
        [[ -z "$placeholder" ]] && continue

        found=false
        for ref in "${declared_refs[@]}"; do
            if echo "$ref" | grep -qi "$placeholder"; then
                found=true
                break
            fi
        done

        if [[ "$found" == "false" ]]; then
            warn "$plugin_name: connector '~~$placeholder' defined in CONNECTORS.md but never referenced in skills"
        fi
    done < "$connectors_md"
done

# Summary
echo ""
echo "============================"
if [[ $ERRORS -gt 0 ]]; then
    red "FAILED: $ERRORS error(s), $WARNINGS warning(s)"
    exit 1
elif [[ $WARNINGS -gt 0 ]]; then
    yellow "PASSED with $WARNINGS warning(s)"
    exit 0
else
    green "PASSED: all connector references valid"
    exit 0
fi
