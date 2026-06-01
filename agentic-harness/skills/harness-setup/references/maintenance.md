# Maintaining a harness

A harness is a system that keeps changing, not a one-time build. This covers the four ways it
changes after the first build: extending it, applying a review context, syncing drift, and
folding in feedback. Every one of them ends by recording the change in history.

## Table of contents

1. [The extension matrix](#1-the-extension-matrix)
2. [Applying a review context](#2-applying-a-review-context)
3. [Syncing drift](#3-syncing-drift)
4. [Feedback routing](#4-feedback-routing)
5. [Evolution triggers](#5-evolution-triggers)
6. [The operations workflow](#6-the-operations-workflow)

---

## 1. The extension matrix

When extending an existing harness, do not re-run the full build. Run only the steps the
change needs (step numbers are from the `harness-setup` SKILL.md):

| Change | Domain analysis (1) | Mode/pattern (2) | Agents (3) | Skills (4) | Orchestrator (5) | History (6) |
|--------|---------------------|------------------|------------|------------|------------------|-------------|
| Add an agent | reuse Step 0 | placement only | yes | only if it needs a new skill | update composition + triggers | yes |
| Add / change a skill | skip | skip | skip | yes | only if wiring changes | yes |
| Architecture change | skip | yes | only affected agents | only affected skills | yes | yes |

When adding an agent, modify the existing orchestrator — do not spawn a second one. Reflect
the new agent in the team composition, task assignment, data flow, and trigger keywords.

## 2. Applying a review context

`harness-review` hands off a prioritized list: what works well (leave it), and what to
improve (act on it). Treat it as an interactive improvement pass, not a batch rewrite:

1. Read the review context and confirm the priority order with the user.
2. Take items one at a time, highest priority first.
3. For each, identify the right target with the routing table below, make the smallest change
   that addresses it, and record it in history.
4. After each change, re-check the specific concern the item raised before moving on.

Working one item at a time keeps each change attributable and easy to roll back.

## 3. Syncing drift

Drift is when the files and the `CLAUDE.md` record disagree — an agent or skill exists that
the record doesn't mention, or the record names something no longer present.

1. List `.claude/agents/` and `.claude/skills/`; compare against the orchestrator's
   composition and the `CLAUDE.md` pointer.
2. For each discrepancy, decide with the user which side is correct — the files or the
   record.
3. Reconcile toward the correct side, then record the correction in history.

The files are usually the truth; the record is what falls behind. But confirm rather than
assume — a missing file can mean a deletion that was never recorded *or* an accidental loss.

## 4. Feedback routing

Different feedback lands in different places. Route by type:

| Feedback | Fix where | Example |
|----------|-----------|---------|
| Output quality | the agent's skill | "the analysis is too shallow" → add depth criteria to the skill |
| Missing role | a new agent definition | "we also need a security pass" → add an agent |
| Wrong order | the orchestrator | "validation should come first" → reorder the phases |
| Team composition | orchestrator + agents | "merge these two" → combine the agents |
| Missing trigger | the skill description | "it doesn't fire when I phrase it this way" → widen the description |

The reason this table exists is the separation in the harness model: who, how, and when each
have one home, so each kind of fault has one place to fix it.

## 5. Evolution triggers

Propose a change not only when the user asks, but when the signals say it is due:

- The same kind of feedback recurs two or more times.
- An agent fails the same way repeatedly.
- The user is working around the orchestrator by hand — a sign it does not fit the real task.

When you see these, raise it; don't wait to be told.

## 6. The operations workflow

For an audit-fix-sync request on an existing harness:

1. **Audit.** Compare `.claude/agents/` and `.claude/skills/` against the orchestrator's
   composition; produce a discrepancy list; report it to the user. (Read-only inventory and
   usage assessment are `harness-review`'s job — call it for the deeper read.)
2. **Change incrementally.** Add, modify, or remove one agent or skill at a time. Sync after
   each change rather than batching.
3. **Record history.** Append the date, change, target, and reason to the `CLAUDE.md` table.
4. **Validate.** Re-check the changed agents and skills structurally; if the change affects
   triggering, re-check the descriptions; for large changes (an architecture change, or
   adding/removing several agents), re-run the relevant tests. Finally, confirm the
   `CLAUDE.md` record matches the actual files.
