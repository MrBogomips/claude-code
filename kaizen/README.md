# Kaizen — Continuous Improvement Loops for Claude Code

A recursive optimization engine inspired by [karpathy/autoresearch](https://github.com/karpathy/autoresearch). Define what to improve, how to measure, and what to mutate — the engine handles the rest.

---

## Table of Contents

- [Quick Start](#quick-start)
- [How It Works](#how-it-works)
- [Architecture](#architecture)
- [Bundled Profiles](#bundled-profiles)
- [Commands](#commands)
- [Creating Custom Profiles](#creating-custom-profiles)
- [Agents](#agents)
- [Audit Trail](#audit-trail)
- [Setup](#setup)
- [Troubleshooting](#troubleshooting)
- [Roadmap](#roadmap)

---

## Quick Start

```bash
# 1. Install the Sequential Thinking MCP (required)
# Add to your Claude Code MCP configuration:
# {
#   "mcpServers": {
#     "sequential-thinking": {
#       "command": "npx",
#       "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
#     }
#   }
# }

# 2. Run an improvement loop
/kaizen claude-code-usage

# 3. View results
/kaizen-history claude-code-usage
```

---

## How It Works

Kaizen runs **recursive improvement loops** against measurable KPIs. Each loop follows a ratcheting mechanism: every iteration either locks in an improvement or reverts to the previous best state.

```
┌─────────────────────────────────────────────┐
│         KAIZEN IMPROVEMENT LOOP              │
│                                              │
│  BOOTSTRAP                                   │
│  ├── Load profile                            │
│  ├── Collect data sources                    │
│  ├── Scaffold measurement tool               │
│  ├── Capture baseline KPIs                   │
│  └── Adversarial review of measurement tool  │
│                                              │
│  ITERATION LOOP (repeat until convergence)   │
│  ├── MEASURE    → collect current KPIs       │
│  ├── ANALYZE    → compare to baseline        │
│  ├── HYPOTHESIZE→ identify root causes       │
│  ├── PROPOSE    → generate change plan       │
│  ├── APPLY      → mutate target assets       │
│  ├── VERIFY     → re-measure KPIs            │
│  ├── DECIDE     → keep (commit) or revert    │
│  └── LOG        → write audit record         │
│                                              │
│  FINAL REVIEW                                │
│  └── Adversarial validation of all changes   │
└─────────────────────────────────────────────┘
```

### Ratcheting Strategies

| Strategy | Logic | Use When |
|----------|-------|----------|
| **Greedy** | Keep if single KPI improves by >= epsilon; revert otherwise | Single optimization target |
| **Multi-objective** | Keep only if no KPI regresses AND at least one improves (Pareto dominance) | Multiple competing metrics |

### Autonomy Levels

| Level | Behavior | Best For |
|-------|----------|----------|
| `supervised` | Pause for approval at every proposal | First runs, sensitive targets |
| `autonomous` | Run until convergence or budget | Well-understood domains, overnight runs |
| `hybrid(N)` | Autonomous for N iterations, then checkpoint | Balanced confidence/control |

### Stopping Conditions

- **Convergence** — KPI delta < epsilon for `patience` consecutive iterations
- **Budget** — iteration count exceeded
- **User interrupt** — manual stop
- **Adversarial flag** — reviewer detects measurement integrity issues

---

## Architecture

### Engine + Profiles

The plugin follows an **engine + profiles** architecture:

- **Engine** (`kaizen-engine` skill) — generic loop orchestrator. Handles iteration control, context management, subagent dispatch, ratcheting, and audit logging.
- **Profiles** (`profiles/{name}/PROFILE.md`) — domain-specific specs. Define KPIs, data sources, mutation targets, and improvement instructions.
- **Agents** — specialized subagents dispatched by the engine for specific phases.

### Sequential Thinking MCP Integration

Each iteration is orchestrated as a **Sequential Thinking chain** with 8 thoughts (one per phase). This provides structured reasoning throughout the loop and enables the engine to track its progress through the iteration.

### Context Management

The engine compacts context between iterations to prevent window exhaustion:

1. After each iteration, detailed analysis is written to disk (audit trail)
2. The next iteration starts with **reconstructed minimal context**: profile config + current summary + previous decision
3. Full history is available on disk but not loaded unless needed

This allows the engine to run many iterations without degradation.

---

## Bundled Profiles

### claude-code-usage

Analyzes and improves how Claude Code tools and skills are used within a project.

| KPI | Direction | Description |
|-----|-----------|-------------|
| `tool_efficiency` | maximize | Ratio of dedicated tools vs bash fallbacks |
| `search_precision` | minimize | Average searches needed to find a target |
| `config_completeness` | maximize | Coverage of recommended configurations |
| `skill_utilization` | maximize | Ratio of installed skills actually triggered |

**Data sources:** Session transcripts, `.claude/` config, git history, agent memory
**Mutates:** `.claude/CLAUDE.md`, `.claude/settings.json`, `.claude/settings.local.json`
**Autonomy:** supervised

**Example improvement:** "You used `bash grep` 47 times last week but `Grep` tool only 12 times. Adding this convention to CLAUDE.md would improve tool_efficiency from 0.20 to 0.65."

### code-refactoring

Recursively improves code quality metrics using safe, behavior-preserving refactorings.

| KPI | Direction | Description |
|-----|-----------|-------------|
| `cyclomatic_complexity` | minimize | Average complexity per function |
| `duplication_ratio` | minimize | Percentage of duplicated code |
| `file_size_compliance` | maximize | Percentage of files under 400 lines |

**Data sources:** Source files in scope, linter output, test results
**Mutates:** Source files in user-specified scope (tests are immutable)
**Autonomy:** hybrid(3)

### process-improvement

Guides you through designing and running kaizen loops for business and operational processes.

| KPI | Direction | Description |
|-----|-----------|-------------|
| `primary_metric` | user-defined | Main process KPI (e.g., cycle time) |
| `secondary_metric` | user-defined | Trade-off tracker (e.g., quality) |

**Data sources:** User-provided process documentation, metrics
**Mutates:** Process documents, SOPs, checklists
**Autonomy:** supervised (always)
**Methodology:** PDCA, 5S, 5 Whys, Ishikawa, value stream mapping

---

## Commands

### /kaizen

Run an improvement loop.

```
/kaizen [profile-name] [--scope <path>] [--budget <N>] [--autonomy <level>]
```

| Argument | Description |
|----------|-------------|
| `profile-name` | Bundled profile name or path to custom PROFILE.md |
| `--scope` | Override mutation targets |
| `--budget` | Override iteration budget |
| `--autonomy` | Override autonomy level |

### /kaizen-help

Display comprehensive help — commands, profiles, architecture, setup, troubleshooting.

```
/kaizen-help
```

### /kaizen-history

View improvement run history and KPI trends.

```
/kaizen-history [profile-name] [--run <run-id>]
```

---

## Creating Custom Profiles

### Interactive Designer

Use the profile designer skill:

```
/kaizen-profile-designer
```

It guides you through KPI definition, data sources, mutation scope, and autonomy configuration.

### Manual Creation

Copy the profile template from `skills/kaizen-engine/references/profile-template.md` and customize.

A profile is a Markdown file with YAML frontmatter:

```yaml
---
name: my-profile
description: "What this profile improves"
version: 0.1.0
strategy: multi-objective
autonomy: supervised
iteration_budget: 10
convergence:
  epsilon: 0.02
  patience: 3
kpis:
  - name: my_metric
    description: "What this measures"
    direction: maximize
    unit: ratio
    measurement_method: automated
    formula: "numerator / denominator"
mutation_targets:
  defaults:
    - path: "src/**"
      description: "Files to improve"
  immutable:
    - path: "tests/**"
connectors:
  required:
    - "~~sequential-thinking"
---

# Improvement Instructions

## MEASURE Phase
[How to collect KPI data]

## ANALYZE Phase
[How to interpret measurements]

## HYPOTHESIZE Phase
[Root causes to consider]

## PROPOSE Phase
[Types of changes to make]

## APPLY Phase
[Special considerations]

## VERIFY Phase
[Additional verification]
```

### Profile Guidelines

1. Start with 1-2 KPIs — add more only if needed
2. Keep formulas concrete and unambiguous
3. Set conservative epsilon to filter noise
4. Use supervised autonomy for first runs
5. Define immutables carefully — err on the side of protection
6. Write detailed phase instructions — your domain knowledge lives here

---

## Agents

The engine dispatches 4 specialized agents with optimized model routing:

| Agent | Model | Purpose | Invoked During |
|-------|-------|---------|----------------|
| **kaizen-measurer** | haiku | Run measurement tools, collect KPIs | MEASURE, VERIFY |
| **kaizen-analyzer** | sonnet | Interpret data, find patterns, rank opportunities | ANALYZE |
| **kaizen-proposer** | sonnet | Generate minimal, targeted change proposals | PROPOSE |
| **kaizen-reviewer** | opus | Adversarial validation of tools and changes | BOOTSTRAP, Final Review |

Each agent receives a **tailored, minimal context package** — only the information needed for its phase. This isolation ensures:
- Measurement can't be biased by proposals
- Review can't be influenced by having generated the changes
- Context stays lean across many iterations

---

## Audit Trail

Every run creates a structured audit trail:

```
.kaizen/
└── runs/
    └── 2026-03-23-claude-code-usage-001/
        ├── manifest.json          # Run configuration and overrides
        ├── baseline.json          # Initial KPI snapshot
        ├── measure.py             # Auto-generated measurement tool
        ├── config.json            # Measurement tool configuration
        ├── iterations/
        │   ├── 001/
        │   │   ├── measurement.json   # KPIs before iteration
        │   │   ├── analysis.md        # Analysis and hypotheses
        │   │   ├── proposal.md        # Proposed change
        │   │   ├── backup/            # Pre-change file backups
        │   │   ├── diff.patch         # Applied changes
        │   │   ├── verification.json  # KPIs after change
        │   │   └── decision.json      # Keep/revert + reasoning
        │   └── 002/ ...
        ├── adversarial-review.md  # Final review gate
        └── summary.json           # Aggregate results
```

### Storage Location

| Scope | Location |
|-------|----------|
| Project-level | `.kaizen/` at project root |
| User-level | `~/.kaizen/` |

### Cross-Run Continuity

When you run the same profile again, the engine reads the previous run's `summary.json` and uses its final KPIs as the new baseline. This enables:
- **Trend tracking** across runs
- **Diminishing returns detection**
- **No duplicate baseline capture** on subsequent runs

---

## Setup

### Required: Sequential Thinking MCP

The kaizen engine requires the Sequential Thinking MCP server for loop orchestration.

**Option 1: Claude Code MCP settings**

Add to `.claude/settings.json` or `~/.claude/settings.json`:

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

**Option 2: Project-level .mcp.json**

Create `.mcp.json` at your project root:

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

### Optional: Python or TypeScript Runtime

For profiles with `tool_generation: true`, the engine scaffolds measurement scripts:
- **Python**: requires `python3` on PATH
- **TypeScript**: requires `npx tsx` (install via `npm install -g tsx`)

### Optional: Memory Connector

For enhanced cross-session continuity, configure a memory-capable MCP server or use Claude Code's built-in file-based memory.

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| "Sequential Thinking MCP not found" | MCP server not configured | Follow Setup instructions above |
| Measurement tool fails | Python/TS runtime missing | Install the required runtime |
| Measurement tool produces wrong values | Tool implementation bug | Review the tool source in `.kaizen/runs/{id}/measure.py`; check adversarial review findings |
| All iterations revert | Epsilon too high; scope too narrow; wrong approach | Lower epsilon; expand mutation scope; try different profile |
| KPIs don't improve after many runs | Diminishing returns | Run `/kaizen-history` to check trends; consider shifting focus |
| Context window exhaustion | Too many iterations without compaction | Reduce iteration budget; the engine should compact automatically |
| Adversarial review flags issues | Measurement artifacts detected | Review the flagged issues in `.kaizen/runs/{id}/adversarial-review.md`; fix measurement tool |
| Git commit errors during DECIDE | Git state conflicts | Ensure working tree is clean before running kaizen |

---

## Roadmap

### v1.0 (Current)
- Generic improvement engine with 8-phase loop
- 3 bundled profiles (claude-code-usage, code-refactoring, process-improvement)
- 4 specialized agents with model routing
- Profile validation in CI
- Audit trail with cross-run continuity
- Adversarial review gates

### v2.0 (Planned)
- **Scheduling** — recurring improvement loops via cron (daily, weekly, biweekly, monthly)
- **Auto-run mode** — fully autonomous scheduled loops
- **Additional profiles** — performance optimization, security hardening, test coverage improvement
- **Dashboard** — web-based visualization of KPI trends across profiles
- **Profile marketplace** — community-contributed improvement profiles

---

## Component Inventory

| Type | Count | Components |
|------|-------|------------|
| Skills | 3 | kaizen-engine, kaizen-report, kaizen-profile-designer |
| Profiles | 3 | claude-code-usage, code-refactoring, process-improvement |
| Agents | 4 | kaizen-measurer, kaizen-analyzer, kaizen-proposer, kaizen-reviewer |
| Commands | 3 | /kaizen, /kaizen-help, /kaizen-history |

---

## License

MIT
