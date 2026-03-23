---
description: "Show kaizen usage guide, available profiles, examples, and configuration tips"
---

# /kaizen-help

Display comprehensive help for the kaizen plugin — commands, profiles, architecture, and troubleshooting.

## Commands

| Command | Purpose |
|---------|---------|
| `/kaizen [profile]` | Run an improvement loop |
| `/kaizen-help` | Show this help guide |
| `/kaizen-history [profile]` | View improvement history and KPI trends |

## How It Works

The kaizen engine runs recursive improvement loops inspired by [karpathy/autoresearch](https://github.com/karpathy/autoresearch). Each loop:

1. Loads a **profile** that defines what to improve and how to measure
2. Captures a **baseline** snapshot of current KPI values
3. Runs **iterations** of the MEASURE → ANALYZE → HYPOTHESIZE → PROPOSE → APPLY → VERIFY → DECIDE → LOG cycle
4. Each iteration either **keeps** the improvement (ratchets forward) or **reverts** (tries again)
5. Stops when KPIs converge, budget is exhausted, or the user intervenes
6. Runs a **final adversarial review** to validate improvements are genuine

## Profiles

Profiles define the improvement domain. Three are bundled:

### claude-code-usage
Analyzes Claude Code tool and skill usage patterns. Detects anti-patterns like bash grep instead of Grep tool, missing CLAUDE.md sections, unconfigured permissions. Suggests configuration improvements.

**KPIs:** tool_efficiency, search_precision, config_completeness, skill_utilization
**Mutates:** `.claude/CLAUDE.md`, `.claude/settings.json`
**Best for:** Optimizing your Claude Code workflow

### code-refactoring
Recursively improves code quality metrics. Applies safe, behavior-preserving refactorings one at a time — extract functions, reduce complexity, eliminate duplication, split large files.

**KPIs:** cyclomatic_complexity, duplication_ratio, file_size_compliance
**Mutates:** Source files in scope (tests are immutable)
**Best for:** Cleaning up a codebase area

### process-improvement
Guides you through designing and running kaizen improvement loops for business processes. Uses PDCA, 5 Whys, value stream mapping, and other lean methodologies.

**KPIs:** User-defined (guided during setup)
**Mutates:** Process documents, SOPs, checklists
**Best for:** Operational and workflow improvements

### Custom Profiles
Create your own with `/kaizen-profile-designer` or by copying the profile template.

## Strategies

- **Greedy** — single KPI, pure hill-climbing. Keep if improved, revert if not.
- **Multi-objective** — Pareto dominance. Keep only if no KPI regressed AND at least one improved.

## Autonomy Levels

- **supervised** — pause for human approval at every proposal
- **autonomous** — run until convergence or budget (no human intervention)
- **hybrid(N)** — autonomous for N iterations, then checkpoint

## Audit Trail

Every run creates a structured audit trail in `.kaizen/runs/{run-id}/`:

```
manifest.json     — run configuration
baseline.json     — initial KPI values
measure.py        — auto-generated measurement tool
iterations/NNN/   — per-iteration data (measurement, analysis, proposal, diff, decision)
adversarial-review.md — final review
summary.json      — aggregate results and KPI improvement
```

Use `/kaizen-history` to browse the audit trail.

## Setup

### Required: Sequential Thinking MCP

The kaizen engine requires Sequential Thinking MCP for loop orchestration.

**Installation:**

Add to your `.claude/settings.json` or MCP configuration:

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Sequential Thinking MCP not found" | Install the MCP server (see Setup above) |
| Measurement tool fails | Check Python/TS runtime is installed; read the error in the audit trail |
| All iterations revert | The epsilon may be too high; the scope may be too narrow; try a different approach |
| Context window exhaustion | The engine compacts between iterations; reduce iteration budget if needed |
| KPIs don't improve | Check if the measurement tool is correct; review the adversarial review output |
