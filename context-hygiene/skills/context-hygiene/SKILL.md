---
name: context-hygiene
description: Audit a project's agentic context (CLAUDE.md files, .claude/rules, Claude Code auto-memory and MEMORY.md, working-doc folders) for wrong, stale or redundant content, and prune it only with per-item authorization after a schematic recap. Use when asked to clean up, prune, dedupe, squeeze or de-bloat memory or CLAUDE.md, remove outdated or stale memory, or check context hygiene. Not for adding to or improving CLAUDE.md content, /init, or compacting the live session (/compact).
allowed-tools: Read, Glob, Grep, Bash(git rev-parse:*), Bash(git ls-files:*), Bash(git log:*), Bash(git status:*), Bash(git branch:*), Bash(git check-ignore:*), Bash(wc:*), Bash(ls:*)
---

# Context Hygiene

Find what in a project's context is **wrong**, **stale** or **redundant**,
propose how to fix it, and apply only what the user authorizes.

## Hard rules — they override everything below

1. **Nothing changes without explicit authorization in this run.** Discovery,
   checks and recap are read-only. Until the user names item numbers or group
   letters, do not write, edit, move, rename, delete, back up or create
   anything — in the project, the memory directory or anywhere else.
2. **Vague replies are not authorization** ("ok", "sounds good", "go ahead",
   "yes"). Re-prompt with the valid IDs.
3. **Group approval never covers ⚠ rationale-risk or irreversible (not
   tracked) items.** They must be named individually.
4. **Chat only.** No report files, no state files, no hooks.
5. **Never touch** secrets, `settings*.json` (read-only), other projects'
   memory, final/published docs, or global user configuration (unless the
   user explicitly asks in this run and names the item).
6. **Assume nothing about the local setup.** Discover locations; when
   unsure, ask.

Full protocol: `references/safety.md`.

## Workflow

### 1. Discover (read-only)

1. Repo root: `git rev-parse --show-toplevel` (outside git: the current directory).
2. List the always-loaded and on-demand tiers — `references/checks.md` §Scope.
3. Resolve the memory directory — `references/checks.md` §Memory location.
   Not found → say so and ask; never guess.
4. Discover working-area candidates from signals —
   `references/checks.md` §Working area. One signal only → ask.
5. Measure bytes and tokens (≈ bytes/4) per file and per tier.

### 2. Check (read-only)

Run the three checks in `references/checks.md` — Wrong, Stale, Redundant —
mechanical commands first. Record each finding as check, `file:line`,
evidence.

### 3. Classify

Apply the retention rule in `references/retention-recap.md`: keep decisions,
current policies, open items and steering lessons. Before proposing to
compress, point away, merge or remove any text, extract its decisions and
lessons into the after-text and say where each now lives. Tag `⚠ rationale-risk` on every compress, pointer, merge or
remove of text that holds a decision, lesson or rationale — even when the
after-text keeps it. A memory fact file and its index line are one item.

### 4. Recap — then stop

Present the recap exactly as in `references/retention-recap.md` §Recap format:
header with totals, chosen grouping and why, lettered groups of numbered
actions (verb, target, before→after, why, benefit, risk). Add `BACKUP` when
memory is touched and `POLICY` when the write-time rule is missing.

End with the closing line from that section and **end your turn**. Do not
start applying in the same turn.

### 5. Authorization

Parse the reply into an explicit set of IDs (`references/safety.md`
§Authorization). Regroup requests or questions → answer and wait. Anything
ambiguous → re-prompt. Echo the authorized set before applying.

### 6. Apply — authorized items only

Order: `BACKUP` → edits → `POLICY`. Per item, re-read the target first. If it
changed since the recap, stop that item and re-ask. Tracked file with
uncommitted changes → ask to commit or stash. Update memory fact files and
index lines together. Details: `references/safety.md` §Apply safety and
§Backup.

### 7. Verify and report

Re-run the mechanical checks on the touched files. Grep that every kept
decision, policy and lesson is still findable. Print the final report from
`references/retention-recap.md` §Final report: applied and skipped IDs,
projected vs actual tokens, remaining findings, undo path.

If a CLAUDE.md-quality skill such as `claude-md-improver` appears among the
available skills, suggest it for enrichment — this skill shrinks, that one
enriches. Do not assume it is installed.

## Red flags

| Thought | Reality |
|---|---|
| "I'll fix the obvious ones while presenting the recap" | Recap and stop. Every change is an item. |
| "They said go ahead" | Not an ID. Re-prompt. |
| "A backup is harmless" | BACKUP is an item. It needs authorization. |
| "This old text is obviously dead" | Extract decisions and lessons, tag ⚠, let the user decide. |
| "This folder is obviously scratch" | Two signals or ask. |
| "I kept the lesson, so the compress is low risk" | It still holds a lesson. Tag ⚠; the user checks the extraction. |
| "The index line is a separate fix" | Fact file + index line = one item. |

More in `references/safety.md` §Red flags.
