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
Analyzes Claude Code tool and skill usage patterns. Detects anti-patterns like `cat` instead of the Read tool, missing CLAUDE.md sections, missing permission rules. Suggests configuration improvements.

**KPIs:** config_completeness decides; tool_efficiency, search_precision and skill_utilization are read from past session transcripts and tracked as observational
**Mutates:** `CLAUDE.md` or `.claude/CLAUDE.md`, `.claude/settings.json`, `.claude/settings.local.json`, `.claude/rules/`
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
Create your own with `/kaizen-profile-designer` or by copying the profile template. Custom profiles live in `.kaizen/profiles/<name>/` (this project) or `~/.kaizen/profiles/<name>/` (all projects), and `/kaizen <name>` finds them there.

## Strategies

- **Greedy** — single KPI, pure hill-climbing. Keep if improved, revert if not.
- **Multi-objective** — Pareto dominance. Keep only if no KPI regressed AND at least one improved; a trade-off is escalated to you unless the run is autonomous.

Each KPI can set its own `epsilon`, in its own unit, as the smallest change that counts. KPIs marked `observational` are tracked and reported but never decide keep or revert. A failed verify check (for example, the build) always reverts.

## Autonomy Levels

- **supervised** — pause for human approval at every proposal
- **autonomous** — run until convergence or budget (no human intervention)
- **hybrid(N)** — autonomous for N iterations, then checkpoint

## Audit Trail

Every run creates a structured audit trail in `.kaizen/runs/{run-id}/`:

```
manifest.json     — resolved run configuration (KPIs, epsilons, targets, verify checks, git choices)
baseline.json     — initial KPI values
measure.py        — measurement tool, generated or reused from the previous run
tool-review.md    — adversarial review of a newly generated tool
iterations/NNN/   — per-iteration data (measurement, analysis, proposal, diff, decision)
adversarial-review.md — final review
summary.json      — aggregate results and KPI improvement
```

Use `/kaizen-history` to browse the audit trail.

## Setup

### Optional: Sequential Thinking MCP

The kaizen engine can record each iteration as a Sequential Thinking chain when this MCP server is connected; it runs without it.

**Installation:** MCP servers are configured with `claude mcp add` or in a `.mcp.json` file at the project root, not in `settings.json`:

```bash
claude mcp add sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Measurement tool fails | Check Python/TS runtime is installed; read the error in the audit trail |
| All iterations revert | A KPI's epsilon may be too high for its unit; a verify check may be failing; the scope may be too narrow |
| Asked about uncommitted changes | The mutation targets have uncommitted edits. Commit or stash them, or run without commits |
| Context window exhaustion | Reduce the iteration budget; the engine writes each iteration to disk and reloads only the summary and last decision |
| KPIs don't improve | Check if the measurement tool is correct; review the adversarial review output |
