# The CLAUDE.md pointer

A target project's `CLAUDE.md` is loaded into context at the start of every session. That
makes it the right place to record that a harness exists and when it should fire — and the
wrong place for anything the file system already holds.

## Register a minimal pointer

After a harness is built or changed, write (or update) one short section in the target
project's `CLAUDE.md`. It carries three things and nothing more:

1. The harness's **goal**, in one line.
2. The **trigger rule** — which orchestrator skill to use, and for which kind of request.
3. A **change-history** table.

This is enough for a fresh session: the trigger rule routes domain requests to the
orchestrator, and the orchestrator handles the rest from the files under `.claude/`.

### Template

````markdown
## Harness: {domain}

**Goal:** {one line on what this harness produces}

**Trigger:** For {domain} work, use the `{orchestrator-skill-name}` skill. Answer simple
questions directly.

**Change history:**
| Date | Change | Target | Reason |
|------|--------|--------|--------|
| {YYYY-MM-DD} | Initial setup | All | — |
````

## What not to put here

Leave these out of `CLAUDE.md`:

- The agent list or the skill list — they live in `.claude/agents/` and `.claude/skills/`,
  and the orchestrator already knows them. Copying them here creates a second source of
  truth that drifts.
- The directory structure — readable straight from the file system.
- Detailed execution rules — they belong in the skills and the orchestrator.

The pointer is a signpost, not a manifest. Keep it small enough that it stays correct.

## The change-history table

Every write to the harness appends a row. The columns are fixed:

| Date | Change | Target | Reason |
|------|--------|--------|--------|
| 2026-04-05 | Initial setup | All | — |
| 2026-04-07 | Added QA agent | `agents/qa.md` | deliverable-quality gaps reported |
| 2026-04-10 | Added tone guidance | `skills/content-writer` | output read as too stiff |

The table earns its place: it shows how the harness has evolved and why, which makes
regressions visible and gives the next reviewer a starting point. Recording history is a
required step of every harness write — not an optional courtesy.
