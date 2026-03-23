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

### allowedTools

Tools that should typically be allowed for productive development:

```json
{
  "allowedTools": [
    "Read",
    "Write",
    "Edit",
    "Grep",
    "Glob",
    "Bash(git *)",
    "Bash(npm *)",
    "Bash(npx *)"
  ]
}
```

Adjust based on tech stack (add `pip`, `cargo`, `go`, `docker` as needed).

### Model Configuration

- Use `sonnet` for day-to-day development
- Switch to `opus` for complex architectural decisions
- Use `haiku` for lightweight agents

## Recommended Rules

The `.claude/rules/` directory should contain:

- `coding-style.md` — language-specific conventions
- `git-workflow.md` — commit message format, branch naming
- `testing.md` — coverage requirements, TDD workflow
- `security.md` — input validation, secret handling

## Recommended Memory Usage

Active memory should capture:

- User role and expertise level
- Project-specific feedback (corrections, preferences)
- External resource references (issue trackers, dashboards)

## Configuration Completeness Checklist

The `config_completeness` KPI measures coverage of these items:

| Item | Category | Weight |
|------|----------|--------|
| CLAUDE.md exists | Essential | 2 |
| CLAUDE.md has project overview | Essential | 2 |
| CLAUDE.md has directory structure | Essential | 2 |
| CLAUDE.md has dev workflow | Important | 1 |
| CLAUDE.md has tool conventions | Important | 1 |
| settings.json exists | Essential | 2 |
| allowedTools configured | Essential | 2 |
| Rules directory exists | Important | 1 |
| At least 1 rule file | Important | 1 |
| Memory directory exists | Optional | 1 |
| At least 1 memory file | Optional | 1 |
| .gitignore includes .claude/ | Important | 1 |

**Score:** `sum(present_items * weight) / sum(all_items * weight) * 100`

## Skill Portfolio Guidelines

- **Install only skills relevant to current work** — dormant skills add context overhead
- **Review skill descriptions** — ensure trigger phrases match your typical requests
- **Prefer specific over generic** — a language-specific reviewer beats a generic one
- **Remove after project ends** — project-specific skills should be uninstalled when done
