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
# 1. Install the Sequential Thinking MCP (optional)
claude mcp add sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking

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
│  ├── Load profile (or resume an open run)    │
│  ├── Collect data sources                    │
│  ├── Check targets for uncommitted edits     │
│  ├── Scaffold or reuse measurement tool      │
│  ├── Capture baseline KPIs, verify checks    │
│  └── Adversarial review of a new tool        │
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
| **Multi-objective** | Keep only if no KPI regresses AND at least one improves (Pareto dominance); trade-offs are escalated unless the run is autonomous | Multiple competing metrics |

Each KPI can set its own `epsilon`, in its own unit, with `convergence.epsilon` as the fallback. KPIs marked `observational` are tracked and reported but never decide an iteration. A failed verify check, such as a broken build, always reverts.

### Git Safety

KEEP commits only the files the iteration changed. At BOOTSTRAP the engine runs `git status` on the mutation targets: if any has uncommitted edits, it asks you to commit or stash them, or to run without commits. It also offers a `kaizen/<run-id>` branch for the run. A file edited outside the loop between iterations is never committed by KEEP.

### Autonomy Levels

| Level | Behavior | Best For |
|-------|----------|----------|
| `supervised` | Pause for approval at every proposal | First runs, sensitive targets |
| `autonomous` | Run until convergence or budget | Well-understood domains, overnight runs |
| `hybrid(N)` | Autonomous for N iterations, then checkpoint | Balanced confidence/control |

### Stopping Conditions

- **Convergence** — `patience` consecutive iterations without a kept change
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

### Sequential Thinking MCP (optional)

When connected, each iteration can be recorded as a Sequential Thinking chain with 8 thoughts (one per phase). The loop runs the same without it.

### Context Management

The engine keeps its context small between iterations to prevent window exhaustion:

1. After each iteration, detailed analysis is written to disk (audit trail)
2. The next iteration starts with **reconstructed minimal context**: the run's `manifest.json` (the resolved configuration) + current summary + previous decision
3. Full history is available on disk but not loaded unless needed

This allows the engine to run many iterations without degradation.

---

## Bundled Profiles

### claude-code-usage

Analyzes and improves how Claude Code tools and skills are used within a project.

| KPI | Direction | Description |
|-----|-----------|-------------|
| `tool_efficiency` | maximize | Ratio of dedicated tools vs bash fallbacks (observational) |
| `search_precision` | minimize | Average searches needed to find a target (observational) |
| `config_completeness` | maximize | Coverage of recommended configurations (decides keep/revert) |
| `skill_utilization` | maximize | Ratio of installed skills actually triggered (observational) |

The three observational KPIs are read from this project's past session transcripts (`~/.claude/projects/<project>/*.jsonl`), so a config change cannot move them within a run; compare them across runs.

**Data sources:** This project's session transcripts, `.claude/` config, git history, auto memory
**Mutates:** `CLAUDE.md` or `.claude/CLAUDE.md`, `.claude/settings.json`, `.claude/settings.local.json`, `.claude/rules/`
**Autonomy:** supervised

**Example improvement:** "`.claude/settings.json` has no permission rules and CLAUDE.md has no tool conventions. Adding a `permissions.allow` rule for the test command raises config_completeness from 47 to 59."

### code-refactoring

Recursively improves code quality metrics using safe, behavior-preserving refactorings.

| KPI | Direction | Description |
|-----|-----------|-------------|
| `cyclomatic_complexity` | minimize | Average complexity per function |
| `duplication_ratio` | minimize | Percentage of duplicated code |
| `file_size_compliance` | maximize | Percentage of files under 400 lines |

**Data sources:** Project root scan (language, framework, quality config), recent git history
**Mutates:** Source files in user-specified scope (tests are immutable)
**Autonomy:** hybrid(3)
**Verify checks:** the build, test and lint commands confirmed at BOOTSTRAP; a failing check reverts the refactoring

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

KPIs, epsilons and the process-document path are settled with you at BOOTSTRAP and stored in the run's manifest. Iterations can span weeks: running the profile again offers to resume the open run.

---

## Commands

### /kaizen

Run an improvement loop.

```
/kaizen [profile-name] [--scope <path>] [--budget <N>] [--autonomy <level>]
```

| Argument | Description |
|----------|-------------|
| `profile-name` | Profile name (custom in `.kaizen/profiles/` or `~/.kaizen/profiles/`, or bundled) or path to a PROFILE.md |
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

It guides you through KPI definition, data sources, mutation scope, and autonomy configuration, and saves the profile to `.kaizen/profiles/<name>/PROFILE.md` (or `~/.kaizen/profiles/<name>/` for all projects).

### Manual Creation

Copy the profile template from `skills/kaizen-engine/references/profile-template.md` to `.kaizen/profiles/<name>/PROFILE.md` and customize. Keep custom profiles out of the plugin directory: it is replaced when the plugin updates. `/kaizen <name>` looks in `.kaizen/profiles/`, then `~/.kaizen/profiles/`, then the bundled profiles.

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
    epsilon: 0.02          # optional, in this KPI's unit
    measurement_method: automated
    formula: "numerator / denominator"
mutation_targets:
  defaults:
    - path: "src/**"
      description: "Files to improve"
  immutable:
    - path: "tests/**"
connectors:
  optional:
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
3. Set epsilon per KPI, in the KPI's own unit, to filter noise
4. Use supervised autonomy for first runs
5. Define immutables carefully — err on the side of protection
6. Write detailed phase instructions — your domain knowledge lives here

---

## Agents

The engine dispatches 3 specialized agents with optimized model routing:

| Agent | Model | Purpose | Invoked During |
|-------|-------|---------|----------------|
| **kaizen-analyzer** | sonnet | Interpret data, find patterns, rank opportunities | ANALYZE |
| **kaizen-proposer** | sonnet | Generate minimal, targeted change proposals | PROPOSE |
| **kaizen-reviewer** | opus | Adversarial validation of tools and changes | BOOTSTRAP, Final Review |

MEASURE and VERIFY need no agent: the engine runs the measurement script through Bash with a 60-second timeout and checks its JSON output itself.

Each agent receives a **tailored, minimal context package** — only the information needed for its phase. This isolation ensures:
- Analysis can't be biased by proposals
- Review can't be influenced by having generated the changes
- Context stays lean across many iterations

---

## Audit Trail

Every run creates a structured audit trail:

```
.kaizen/
└── runs/
    └── 2026-03-23-claude-code-usage-001/
        ├── manifest.json          # Resolved configuration: KPIs, epsilons, targets, checks, git choices
        ├── baseline.json          # Initial KPI snapshot
        ├── measure.py             # Measurement tool (generated, or reused from the previous run)
        ├── config.json            # Measurement tool configuration
        ├── tool-review.md         # Review of a newly generated tool
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

The engine picks the storage root when a run starts: the project's `.kaizen/` when every mutation target is inside the project, otherwise it asks. It searches both roots for an unfinished run to resume.

### Cross-Run Continuity

When you run the same profile again, the engine measures a fresh baseline, because the target may have changed since, and stores the previous run's final KPIs (its `current` field) as `previous_final` in the new manifest. While the profile `version` is unchanged, it reuses the previous run's measurement script, so the numbers of both runs come from the same tool. This enables:
- **Trend tracking** across runs
- **Diminishing returns detection**

A run that stopped before converging stays open: running the profile again offers to resume it.

---

## Setup

### Optional: Sequential Thinking MCP

The kaizen engine can use the Sequential Thinking MCP server to record each iteration; it is not required.

MCP servers are not configured in `settings.json`.

**Option 1: `claude mcp add`**

```bash
claude mcp add sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
```

This adds the server for you in the current project. Add `--scope user` for all your projects, or `--scope project` to write it to `.mcp.json`.

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

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Measurement tool fails | Python/TS runtime missing | Install the required runtime |
| Measurement tool produces wrong values | Tool implementation bug | Review the tool source in `.kaizen/runs/{id}/measure.py`; check adversarial review findings |
| All iterations revert | A KPI's epsilon too high for its unit; a verify check failing; scope too narrow | Set `epsilon` per KPI; check `failed_check` in decision.json; expand mutation scope |
| KPIs don't improve after many runs | Diminishing returns | Run `/kaizen-history` to check trends; consider shifting focus |
| Context window exhaustion | Too many iterations in one session | Reduce the iteration budget. The engine writes each iteration to disk and reloads only the manifest, summary and last decision; it does not compact the conversation, so run `/compact` or resume the run in a new session |
| Adversarial review flags issues | Measurement artifacts detected | Review the flagged issues in `.kaizen/runs/{id}/adversarial-review.md`; fix measurement tool |
| Asked about uncommitted changes at start | Mutation targets have uncommitted edits | Commit or stash them, or choose to run without commits |
| A kept iteration was not committed | The file had edits from outside the loop before APPLY, or the commit failed | See `commit_skipped` in decision.json; review and commit the change yourself |

---

## Roadmap

### v1.0 (Current)
- Generic improvement engine with 8-phase loop
- 3 bundled profiles (claude-code-usage, code-refactoring, process-improvement)
- 3 specialized agents with model routing
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
| Agents | 3 | kaizen-analyzer, kaizen-proposer, kaizen-reviewer |
| Commands | 3 | /kaizen, /kaizen-help, /kaizen-history |

---

## License

MIT
