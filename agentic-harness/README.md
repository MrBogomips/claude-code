# agentic-harness

Stand up, assess, and maintain an **agentic harness** inside an existing repository — the project-local agents, skills, and orchestrator that make a repo work well with Claude Code.

This plugin does not do your domain work. It builds and maintains the agents and skills that do.

## The three skills

- **`harness-setup`** — the writer. Analyzes the project, designs an agent team and the skills they use, generates them into `.claude/`, builds an orchestrator, and registers a pointer in `CLAUDE.md`. Also extends an existing harness, applies a review context, and records every change.
- **`harness-review`** — read-only. Inventories the harness, detects drift, and assesses how effectively the skills and agents are actually used (from project memory, the `CLAUDE.md` pointer, and the `.claude/` inventory), then produces a prioritized *review context* that `harness-setup` can act on.
- **`spec-advisor`** — detects whether a software project lacks a spec-driven development system and, if so, advises the best-fit option (GitHub Spec Kit, OpenSpec, BMAD-METHOD, Agent OS, Taskmaster, AWS Kiro, ADR tooling) and delegates setup to that system's own installer. Offline-first; scans first and stays out if a system is already present; never authors specs itself.

When a project **already has** a spec system, `harness-setup` makes the generated orchestrator coordinate with it rather than run beside it: the orchestrator activates the spec workflow with a contextual prompt, the spec system runs its owned segment, and the orchestrator resumes on a clean hand-back — one owner per phase, no duplicated artifacts. The detection signatures and the per-system coordination map are shared knowledge under `shared/` (`detection-signatures.md`, `sdd-coordination.md`).

The harness loop: **review → setup → review again.** `spec-advisor` is offered alongside it when a software project has no spec system yet.

## Skills, not commands

Invoke a skill directly (`/agentic-harness:harness-setup`) or let Claude trigger it from context. This plugin ships no slash commands — Claude Code merged commands into skills.

## Execution modes

`harness-setup` defaults to an **agent team** and falls back to **subagents** when the experimental team tools are unavailable. See `shared/execution-modes.md`.

## Inspired by

The harness concept is inspired by prior work in the community; this is an independent implementation. Credit lives in the repository README.
