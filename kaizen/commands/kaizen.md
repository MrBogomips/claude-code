---
description: "Run a kaizen improvement loop with a specified profile"
---

# /kaizen

Run a recursive improvement loop using the kaizen engine.

## Usage

```
/kaizen [profile-name] [--scope <path>] [--budget <N>] [--autonomy <level>]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `profile-name` | No | Name of a bundled profile or path to a custom PROFILE.md. If omitted, shows available profiles and asks user to choose. |
| `--scope <path>` | No | Override the default mutation targets. Narrows the improvement scope to the specified path. |
| `--budget <N>` | No | Override the iteration budget for this run. |
| `--autonomy <level>` | No | Override autonomy level: `supervised`, `autonomous`, or `hybrid(N)`. |

## Available Profiles

| Profile | Description | Default Autonomy |
|---------|-------------|------------------|
| `claude-code-usage` | Analyze and improve Claude Code tool/skill usage | supervised |
| `code-refactoring` | Recursively improve code quality metrics | hybrid(3) |
| `process-improvement` | Design kaizen loops for business processes | supervised |

## Examples

```
/kaizen claude-code-usage
/kaizen code-refactoring --scope src/api/
/kaizen process-improvement
/kaizen ./my-custom-profile/PROFILE.md --budget 5
```

## What Happens

1. **BOOTSTRAP** — loads the profile, collects data sources, scaffolds measurement tools, captures baseline
2. **ITERATION LOOP** — repeats: MEASURE → ANALYZE → HYPOTHESIZE → PROPOSE → APPLY → VERIFY → DECIDE → LOG
3. **FINAL REVIEW** — adversarial review of all changes and KPI integrity
4. **REPORT** — summary of improvements, KPI results, and recommendations

Audit trail is written to `.kaizen/runs/` (project-level) or `~/.kaizen/runs/` (user-level).

## Prerequisites

- **~~sequential-thinking** MCP connector must be configured. See the kaizen README for setup instructions.

## Invoke

Load and activate the `kaizen-engine` skill with the provided arguments.
