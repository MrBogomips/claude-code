---
description: "Show improvement run history and KPI trends for a kaizen profile"
---

# /kaizen-history

View improvement history, KPI trends, and run details from past kaizen loops.

## Usage

```
/kaizen-history [profile-name] [--run <run-id>]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `profile-name` | No | Filter history to a specific profile. If omitted, shows all profiles. |
| `--run <run-id>` | No | Drill into a specific run for detailed iteration-by-iteration data. |

## Examples

```
/kaizen-history                           # Overview of all profiles
/kaizen-history claude-code-usage         # History for a specific profile
/kaizen-history --run 2026-03-23-claude-code-usage-001  # Detailed run view
```

## What It Shows

### Overview (no arguments)
- All profiles with run counts
- Last run date and best KPI improvement per profile
- Active vs converged status

### Profile History (with profile name)
- KPI trajectory table across all runs
- Cumulative improvement from first baseline to latest
- Trend analysis (accelerating, steady, diminishing returns)
- Adversarial review status per run

### Run Detail (with --run)
- Iteration-by-iteration decision log
- KPI deltas per iteration
- Proposals that were kept
- Adversarial review findings

## Invoke

Load and activate the `kaizen-report` skill with the provided arguments.
