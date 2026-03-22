#!/usr/bin/env bash
# Layer 1: Reference path validation
# Checks that every references/ path mentioned in SKILL.md files resolves to an existing file
# and that no broken relative links exist in markdown files.
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

    echo ""
    echo "=== Checking references: $plugin_name ==="

    if [[ ! -d "$plugin_dir/skills" ]]; then
        ok "$plugin_name: no skills directory"
        continue
    fi

    for skill_dir in "$plugin_dir"/skills/*/; do
        [[ -d "$skill_dir" ]] || continue
        skill_name="$(basename "$skill_dir")"
        skill_md="$skill_dir/SKILL.md"

        [[ -f "$skill_md" ]] || continue

        # Extract references/ paths from SKILL.md
        # Matches patterns like: references/workflow.md, `references/foo.md`, references/language-packs/en.md
        while IFS= read -r ref_path; do
            # Clean up the path (remove backticks, quotes, trailing punctuation)
            clean_path="$(echo "$ref_path" | sed 's/[`"'"'"']//g; s/[),;]$//')"

            # Skip paths that are clearly templated
            [[ "$clean_path" == *"{lang}"* ]] && continue
            [[ "$clean_path" == *"{LANG}"* ]] && continue

            # Resolve relative to skill directory
            full_path="$skill_dir/$clean_path"

            if [[ -f "$full_path" ]]; then
                ok "$plugin_name/skills/$skill_name: $clean_path exists"
            else
                error "$plugin_name/skills/$skill_name: broken reference '$clean_path' (resolved to $full_path)"
            fi
        done < <(grep -oE 'references/[a-zA-Z0-9_./-]+\.[a-z]+' "$skill_md" | sort -u || true)

        # Check for references to assets/ and scripts/ paths
        while IFS= read -r asset_path; do
            clean_path="$(echo "$asset_path" | sed 's/[`"'"'"']//g; s/[),;]$//')"
            full_path="$skill_dir/$clean_path"

            if [[ -f "$full_path" ]]; then
                ok "$plugin_name/skills/$skill_name: $clean_path exists"
            else
                # Only warn for assets/scripts since they may use <skill-dir> placeholder
                warn "$plugin_name/skills/$skill_name: asset/script reference '$clean_path' not found at $full_path"
            fi
        done < <(grep -oE '(assets|scripts)/[a-zA-Z0-9_./-]+\.[a-z]+' "$skill_md" | sort -u || true)
    done

    # Check markdown links in plugin-level files (README.md, CONNECTORS.md)
    for md_file in "$plugin_dir"/*.md; do
        [[ -f "$md_file" ]] || continue
        md_name="$(basename "$md_file")"

        while IFS= read -r link_target; do
            # Skip URLs
            [[ "$link_target" == http* ]] && continue
            # Skip anchors
            [[ "$link_target" == \#* ]] && continue

            # Resolve relative to plugin directory
            full_path="$plugin_dir/$link_target"
            if [[ ! -f "$full_path" && ! -d "$full_path" ]]; then
                warn "$plugin_name/$md_name: broken link '$link_target'"
            fi
        done < <(sed -n 's/.*\[.*\](\([^)]*\)).*/\1/p' "$md_file" 2>/dev/null || true)
    done
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
    green "PASSED: all references valid"
    exit 0
fi
