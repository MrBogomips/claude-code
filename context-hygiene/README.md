# context-hygiene

Agentic projects accumulate context: memory files fill with status narrative,
CLAUDE.md drifts from what the repository contains, and working docs pile up
as version chains and consumed handoffs. The model then starts every session
with wrong facts and a larger load.

`context-hygiene` audits that context and proposes how to squeeze it. It keeps
decisions, current policies, open items and one-line lessons, and turns the
rest into pointers or removes it — **only after you authorize each change**.

## What it looks at

| Tier | Items |
|---|---|
| Always-loaded | Project `CLAUDE.md` files, `.claude/CLAUDE.md`, `CLAUDE.local.md`, `@imports`, `.claude/rules/*.md`, the memory index |
| On-demand | Auto-memory fact files |
| Working area | Scratch/working folders, discovered from signals (no assumed names) |

## Checks

- **Wrong** — statements that contradict the repository; memory index out of sync
- **Stale** — status narrative, superseded versions, finished plans and handoffs
- **Redundant / bloated** — duplicated or derivable content, oversized files

## How it works

1. Discovery and checks run read-only.
2. You get a schematic recap in chat: numbered actions with rationale,
   expected benefit and risk.
3. You name what to apply (`apply A, 3`). Anything not named is left alone.
   Items marked ⚠ (they might remove a rationale) must be named individually.
4. Before any memory change, a single backup copy of the memory folder is made
   (if you authorize it). Tracked files rely on git.

## Usage

```
/context-hygiene
```

or ask: "clean up this project's memory and CLAUDE.md".

## Installation

```bash
claude plugin install context-hygiene@mrbogomips-tools
```

## License

MIT
