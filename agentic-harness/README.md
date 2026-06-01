# agentic-harness

Stand up, assess, and maintain an **agentic harness** inside an existing repository — the project-local agents, skills, and orchestrator that make a repo work well with Claude Code.

This plugin does not do your domain work. It builds and maintains the agents and skills that do.

## The two skills

- **`harness-setup`** — the writer. Analyzes the project, designs an agent team and the skills they use, generates them into `.claude/`, builds an orchestrator, and registers a pointer in `CLAUDE.md`. Also extends an existing harness, applies a review context, and records every change.
- **`harness-review`** — read-only. Inventories the harness, detects drift, and assesses how effectively the skills and agents are actually used (from project memory, the `CLAUDE.md` pointer, and the `.claude/` inventory), then produces a prioritized *review context* that `harness-setup` can act on.

The loop: **review → setup → review again.**

## Skills, not commands

Invoke a skill directly (`/agentic-harness:harness-setup`) or let Claude trigger it from context. This plugin ships no slash commands — Claude Code merged commands into skills.

## Execution modes

`harness-setup` defaults to an **agent team** and falls back to **subagents** when the experimental team tools are unavailable. See `shared/execution-modes.md`.

## Relationship to `kaizen`

`kaizen` optimizes assets against measured KPIs. `agentic-harness` builds, assesses, and maintains the harness those assets live in. They compose.

## Inspired by

The harness concept is inspired by prior work in the community; this is an independent implementation. Credit lives in the repository README.

## Changelog

- **0.3.0** — `harness-setup` adds a mandatory pre-write approval gate (Step 2b): it presents an explicit change manifest — every agent, skill, orchestrator, pointer, and tool it will create, update, remove, install, or uninstall — and writes nothing until the user formally approves the list, on every path.
- **0.2.0** — `harness-setup` now always offers tool research (and, on an existing harness, tool maintenance) as part of the plan it presents, and accepts an optional user-provided starting context. Running still requires explicit acceptance, and per-tool adoption is unchanged. `harness-review` flags a missing tools registry as a finding.
- **0.1.0** — Initial release: `harness-setup` and `harness-review`, shared concept docs, and the optional tool-discovery step.
