#!/usr/bin/env bash
# Layer 1: Plugin/marketplace version sync validation
# Checks that every plugin's plugin.json version matches its marketplace.json entry,
# and that every marketplace entry corresponds to an existing plugin directory.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$REPO_ROOT/.claude-plugin/marketplace.json"
ERRORS=0
WARNINGS=0

red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }

error() { red "ERROR: $*"; ERRORS=$((ERRORS + 1)); }
warn()  { yellow "WARN: $*"; WARNINGS=$((WARNINGS + 1)); }
ok()    { green "OK: $*"; }

if ! command -v jq >/dev/null 2>&1; then
    error "jq is required but not installed"
    red "FAILED: $ERRORS error(s)"
    exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
    error "marketplace manifest not found at $MANIFEST"
    red "FAILED: $ERRORS error(s)"
    exit 1
fi

if ! jq empty "$MANIFEST" 2>/dev/null; then
    error "marketplace.json is not valid JSON"
    red "FAILED: $ERRORS error(s)"
    exit 1
fi

# Forward pass: every plugin dir's plugin.json version must match its marketplace entry.
# Track seen plugin names in a space-separated string (bash 3.2 compatible — no associative arrays).
seen_names=""
for plugin_dir in "$REPO_ROOT"/*/; do
    plugin_json="$plugin_dir/.claude-plugin/plugin.json"
    [[ -f "$plugin_json" ]] || continue

    if ! jq empty "$plugin_json" 2>/dev/null; then
        error "$(basename "$plugin_dir"): plugin.json is not valid JSON"
        continue
    fi

    name="$(jq -r '.name // empty' "$plugin_json")"
    pver="$(jq -r '.version // empty' "$plugin_json")"

    if [[ -z "$name" ]]; then
        error "$(basename "$plugin_dir"): plugin.json has no name"
        continue
    fi
    seen_names="$seen_names $name"

    if [[ -z "$pver" ]]; then
        error "$name: plugin.json has no version"
        continue
    fi

    mver="$(jq -r --arg n "$name" '.plugins[] | select(.name == $n) | .version // empty' "$MANIFEST")"

    if [[ -z "$mver" ]]; then
        error "$name: no marketplace.json entry with a version (plugin.json says $pver)"
    elif [[ "$pver" != "$mver" ]]; then
        error "$name: version drift — plugin.json=$pver, marketplace.json=$mver"
    else
        ok "$name: version $pver in sync"
    fi
done

# Reverse pass: every marketplace entry must correspond to an existing plugin directory.
while IFS= read -r entry_name; do
    [[ -z "$entry_name" ]] && continue
    found=false
    for seen in $seen_names; do
        if [[ "$seen" == "$entry_name" ]]; then
            found=true
            break
        fi
    done
    if [[ "$found" == "false" ]]; then
        error "marketplace.json entry '$entry_name' has no matching plugin directory"
    fi
done < <(jq -r '.plugins[].name' "$MANIFEST")

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
    green "PASSED: all plugin versions in sync with marketplace.json"
    exit 0
fi
