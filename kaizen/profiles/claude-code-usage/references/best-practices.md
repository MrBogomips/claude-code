# Claude Code Best Practices — Configuration Reference

## Recommended CLAUDE.md Sections

A well-configured CLAUDE.md should include:

1. **Project Overview** — what the project does, tech stack, architecture
2. **Directory Structure** — purpose of each top-level directory
3. **Development Workflow** — how to build, test, and deploy
4. **Tool Usage Conventions** — preferred tools for common operations
5. **Coding Standards** — naming, formatting, patterns to follow
6. **Testing Requirements** — coverage targets, test patterns

## Recommended settings.json Configuration

### Permission rules

Permissions live under the `permissions` key of `.claude/settings.json` (shared with the team) or `.claude/settings.local.json` (personal), as `allow`, `ask` and `deny` lists of rules. Allow the commands the project runs often:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run test *)",
      "Bash(npm run build)",
      "Bash(git diff *)"
    ]
  }
}
```

Adjust the commands to the tech stack. Read-only tools such as Read need no rule inside the working directory.

MCP servers are not configured in settings files: they go in `.mcp.json` at the project root (shared) or are added with `claude mcp add`.

Before recommending a setting, check it against the current Claude Code settings documentation, since keys and defaults change between releases.

## Recommended Rules

The `.claude/rules/` directory holds the project's rule files, one topic per file. Which topics a project needs depends on the project; there is no required set of names. A rule file may carry `paths` frontmatter so it loads only for matching files.

## Recommended Memory Usage

Active memory should capture:

- User role and expertise level
- Project-specific feedback (corrections, preferences)
- External resource references (issue trackers, dashboards)

## Configuration Completeness Checklist

The `config_completeness` KPI measures coverage of these items:

| Item | Category | Weight |
|------|----------|--------|
| CLAUDE.md exists (`CLAUDE.md` or `.claude/CLAUDE.md`) | Essential | 2 |
| CLAUDE.md has project overview | Essential | 2 |
| CLAUDE.md has directory structure | Essential | 2 |
| CLAUDE.md has dev workflow | Important | 1 |
| CLAUDE.md has tool conventions | Important | 1 |
| settings.json exists | Essential | 2 |
| `permissions.allow` configured | Essential | 2 |
| Rules directory exists | Important | 1 |
| At least 1 rule file | Important | 1 |
| Memory directory exists | Optional | 1 |
| At least 1 memory file | Optional | 1 |
| .gitignore includes .claude/settings.local.json | Important | 1 |

**Score:** `sum(present_items * weight) / sum(all_items * weight) * 100`

## Skill Portfolio Guidelines

- **Install only skills relevant to current work** — dormant skills add context overhead
- **Review skill descriptions** — ensure trigger phrases match your typical requests
- **Prefer specific over generic** — a language-specific reviewer beats a generic one
- **Remove after project ends** — project-specific skills should be uninstalled when done
