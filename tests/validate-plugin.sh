#!/usr/bin/env bash
# Layer 1: Structural validation for marketplace plugins
# Validates plugin.json, SKILL.md frontmatter, AGENT.md frontmatter,
# hooks.json, commands, and marketplace.json
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

# Check if jq is available
if ! command -v jq &>/dev/null; then
    red "jq is required but not installed. Install with: brew install jq"
    exit 1
fi

# --- Plugin validation ---

validate_plugin() {
    local plugin_dir="$1"
    local plugin_name
    plugin_name="$(basename "$plugin_dir")"

    echo ""
    echo "=== Validating plugin: $plugin_name ==="

    # Check plugin.json exists and is valid JSON
    local pjson="$plugin_dir/.claude-plugin/plugin.json"
    if [[ ! -f "$pjson" ]]; then
        error "$plugin_name: missing .claude-plugin/plugin.json"
        return
    fi

    if ! jq empty "$pjson" 2>/dev/null; then
        error "$plugin_name: plugin.json is not valid JSON"
        return
    fi

    # Check required fields
    for field in name version description; do
        if [[ "$(jq -r ".$field // empty" "$pjson")" == "" ]]; then
            error "$plugin_name: plugin.json missing required field '$field'"
        fi
    done

    ok "$plugin_name: plugin.json valid"

    # Check skills
    if [[ -d "$plugin_dir/skills" ]]; then
        for skill_dir in "$plugin_dir"/skills/*/; do
            [[ -d "$skill_dir" ]] || continue
            local skill_name
            skill_name="$(basename "$skill_dir")"
            local skill_md="$skill_dir/SKILL.md"

            if [[ ! -f "$skill_md" ]]; then
                error "$plugin_name/skills/$skill_name: missing SKILL.md"
                continue
            fi

            # Check YAML frontmatter
            if ! head -1 "$skill_md" | grep -q '^---$'; then
                error "$plugin_name/skills/$skill_name: SKILL.md missing YAML frontmatter"
                continue
            fi

            # Extract frontmatter (between first and second ---)
            local frontmatter
            frontmatter="$(awk 'NR==1{next} /^---$/{exit} {print}' "$skill_md")"

            # Check required frontmatter fields
            if ! echo "$frontmatter" | grep -q '^name:'; then
                error "$plugin_name/skills/$skill_name: SKILL.md frontmatter missing 'name'"
            fi
            if ! echo "$frontmatter" | grep -q '^description:'; then
                error "$plugin_name/skills/$skill_name: SKILL.md frontmatter missing 'description'"
            fi

            # Check for angle brackets in description (common mistake)
            local desc_line
            desc_line="$(echo "$frontmatter" | grep '^description:' || true)"
            if echo "$desc_line" | grep -q '<[^>]*>'; then
                warn "$plugin_name/skills/$skill_name: description contains angle brackets (may cause parsing issues)"
            fi

            ok "$plugin_name/skills/$skill_name: SKILL.md frontmatter valid"
        done
    fi

    # Check agents
    if [[ -d "$plugin_dir/agents" ]]; then
        for agent_dir in "$plugin_dir"/agents/*/; do
            [[ -d "$agent_dir" ]] || continue
            local agent_name
            agent_name="$(basename "$agent_dir")"
            local agent_md="$agent_dir/AGENT.md"

            if [[ ! -f "$agent_md" ]]; then
                error "$plugin_name/agents/$agent_name: missing AGENT.md"
                continue
            fi

            if ! head -1 "$agent_md" | grep -q '^---$'; then
                error "$plugin_name/agents/$agent_name: AGENT.md missing YAML frontmatter"
                continue
            fi

            local frontmatter
            frontmatter="$(awk 'NR==1{next} /^---$/{exit} {print}' "$agent_md")"

            if ! echo "$frontmatter" | grep -q '^name:'; then
                error "$plugin_name/agents/$agent_name: AGENT.md frontmatter missing 'name'"
            fi
            if ! echo "$frontmatter" | grep -q '^description:'; then
                error "$plugin_name/agents/$agent_name: AGENT.md frontmatter missing 'description'"
            fi

            ok "$plugin_name/agents/$agent_name: AGENT.md frontmatter valid"
        done
    fi

    # Check profiles
    if [[ -d "$plugin_dir/profiles" ]]; then
        for profile_dir in "$plugin_dir"/profiles/*/; do
            [[ -d "$profile_dir" ]] || continue
            local profile_name
            profile_name="$(basename "$profile_dir")"
            local profile_md="$profile_dir/PROFILE.md"

            if [[ ! -f "$profile_md" ]]; then
                error "$plugin_name/profiles/$profile_name: missing PROFILE.md"
                continue
            fi

            if ! head -1 "$profile_md" | grep -q '^---$'; then
                error "$plugin_name/profiles/$profile_name: PROFILE.md missing YAML frontmatter"
                continue
            fi

            local frontmatter
            frontmatter="$(awk 'NR==1{next} /^---$/{exit} {print}' "$profile_md")"

            # Check required frontmatter fields
            if ! echo "$frontmatter" | grep -q '^name:'; then
                error "$plugin_name/profiles/$profile_name: PROFILE.md frontmatter missing 'name'"
            fi
            if ! echo "$frontmatter" | grep -q '^description:'; then
                error "$plugin_name/profiles/$profile_name: PROFILE.md frontmatter missing 'description'"
            fi
            if ! echo "$frontmatter" | grep -q '^version:'; then
                error "$plugin_name/profiles/$profile_name: PROFILE.md frontmatter missing 'version'"
            fi
            if ! echo "$frontmatter" | grep -q '^strategy:'; then
                error "$plugin_name/profiles/$profile_name: PROFILE.md frontmatter missing 'strategy'"
            fi
            if ! echo "$frontmatter" | grep -q '^autonomy:'; then
                error "$plugin_name/profiles/$profile_name: PROFILE.md frontmatter missing 'autonomy'"
            fi

            # Check KPI definitions exist
            if ! echo "$frontmatter" | grep -q '^kpis:'; then
                error "$plugin_name/profiles/$profile_name: PROFILE.md frontmatter missing 'kpis'"
            else
                # Check each KPI has required subfields
                local kpi_count
                kpi_count="$(echo "$frontmatter" | grep -c '^ *- name:' || true)"
                if [[ "$kpi_count" -eq 0 ]]; then
                    error "$plugin_name/profiles/$profile_name: PROFILE.md has 'kpis' but no KPI entries"
                else
                    # Check direction is present for each KPI
                    local dir_count
                    dir_count="$(echo "$frontmatter" | grep -c '^ *direction:' || true)"
                    if [[ "$dir_count" -lt "$kpi_count" ]]; then
                        warn "$plugin_name/profiles/$profile_name: some KPIs missing 'direction' field"
                    fi
                    local unit_count
                    unit_count="$(echo "$frontmatter" | grep -c '^ *unit:' || true)"
                    if [[ "$unit_count" -lt "$kpi_count" ]]; then
                        warn "$plugin_name/profiles/$profile_name: some KPIs missing 'unit' field"
                    fi
                fi
            fi

            ok "$plugin_name/profiles/$profile_name: PROFILE.md frontmatter valid"
        done
    fi

    # Check hooks
    local hooks_json="$plugin_dir/hooks/hooks.json"
    if [[ -f "$hooks_json" ]]; then
        if ! jq empty "$hooks_json" 2>/dev/null; then
            error "$plugin_name: hooks/hooks.json is not valid JSON"
        else
            ok "$plugin_name: hooks/hooks.json valid"
        fi
    fi

    # Check commands
    if [[ -d "$plugin_dir/commands" ]]; then
        for cmd_file in "$plugin_dir"/commands/*.md; do
            [[ -f "$cmd_file" ]] || continue
            local cmd_name
            cmd_name="$(basename "$cmd_file")"

            if ! head -1 "$cmd_file" | grep -q '^---$'; then
                error "$plugin_name/commands/$cmd_name: missing YAML frontmatter"
                continue
            fi

            local frontmatter
            frontmatter="$(awk 'NR==1{next} /^---$/{exit} {print}' "$cmd_file")"

            if ! echo "$frontmatter" | grep -q '^description:'; then
                warn "$plugin_name/commands/$cmd_name: frontmatter missing 'description'"
            fi

            ok "$plugin_name/commands/$cmd_name: command frontmatter valid"
        done
    fi
}

# --- Marketplace validation ---

validate_marketplace() {
    local manifest="$REPO_ROOT/.claude-plugin/marketplace.json"

    echo ""
    echo "=== Validating marketplace.json ==="

    if [[ ! -f "$manifest" ]]; then
        error "Missing .claude-plugin/marketplace.json"
        return
    fi

    if ! jq empty "$manifest" 2>/dev/null; then
        error "marketplace.json is not valid JSON"
        return
    fi

    # Check required top-level fields
    for field in name plugins; do
        if [[ "$(jq -r ".$field // empty" "$manifest")" == "" ]]; then
            error "marketplace.json missing required field '$field'"
        fi
    done

    # Check version (may be top-level or in metadata)
    local version
    version="$(jq -r '.version // .metadata.version // empty' "$manifest")"
    if [[ -z "$version" ]]; then
        error "marketplace.json missing 'version' (top-level or metadata.version)"
    fi

    # Check each plugin entry
    local plugin_count
    plugin_count="$(jq '.plugins | length' "$manifest")"

    local prev_name=""
    for ((i = 0; i < plugin_count; i++)); do
        local name source description
        name="$(jq -r ".plugins[$i].name // empty" "$manifest")"
        source="$(jq -r ".plugins[$i].source // empty" "$manifest")"
        description="$(jq -r ".plugins[$i].description // empty" "$manifest")"

        if [[ -z "$name" ]]; then
            error "marketplace.json: plugin at index $i missing 'name'"
        fi
        if [[ -z "$source" ]]; then
            error "marketplace.json: plugin '$name' missing 'source'"
        fi
        if [[ -z "$description" ]]; then
            error "marketplace.json: plugin '$name' missing 'description'"
        fi

        # Check source path exists
        if [[ -n "$source" && ! -d "$REPO_ROOT/$source" ]]; then
            error "marketplace.json: plugin '$name' source path '$source' does not exist"
        elif [[ -n "$source" && ! -f "$REPO_ROOT/$source/.claude-plugin/plugin.json" ]]; then
            error "marketplace.json: plugin '$name' source '$source' missing .claude-plugin/plugin.json"
        fi

        # Check string-only entries (bare paths are not valid)
        if jq -e ".plugins[$i] | type == \"string\"" "$manifest" >/dev/null 2>&1; then
            error "marketplace.json: plugin at index $i is a bare string — must be an object"
        fi

        # Check alphabetical ordering
        if [[ -n "$prev_name" && "$name" < "$prev_name" ]]; then
            warn "marketplace.json: plugins not sorted alphabetically ('$name' after '$prev_name')"
        fi
        prev_name="$name"
    done

    # Check for duplicate names
    local dupes
    dupes="$(jq -r '.plugins[].name' "$manifest" | sort | uniq -d)"
    if [[ -n "$dupes" ]]; then
        error "marketplace.json: duplicate plugin names: $dupes"
    fi

    ok "marketplace.json: structure valid ($plugin_count plugins)"
}

# --- Main ---

echo "Marketplace Plugin Validator"
echo "============================"

# Validate each plugin directory
for plugin_dir in "$REPO_ROOT"/*/; do
    [[ -d "$plugin_dir/.claude-plugin" ]] || continue
    validate_plugin "$plugin_dir"
done

# Validate marketplace manifest
validate_marketplace

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
    green "PASSED: all checks clean"
    exit 0
fi
