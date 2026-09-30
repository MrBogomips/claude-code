# Retention and recap

## Retention rule

Keep exactly four kinds of content: **decisions**, **current policies**,
**open items**, **steering lessons**. Everything else becomes a one-line
pointer or is removed.

- **Steering lesson** — all three must hold: it happened; the natural default
  leads back to it; the code does not make the correction obvious. Format:
  `DON'T <tempting default> → DO <correction>. Why: <incident, date>.`
- Lessons live only in CLAUDE.md or memory — never in working folders, which
  do not steer the model.
- **Before proposing COMPRESS, POINTER, MERGE or REMOVE**, extract every
  decision and lesson from the text, show them in the after-text, and say
  where each one now lives (the surviving file, or a line added by this item).
- **Pointer format**: `<one-line durable fact> — see <commit SHA | PR | issue | URL>`.
- Keep provenance annotations ("per user, 2026-05-19").
- Tag `⚠ rationale-risk` on every COMPRESS, POINTER, MERGE or REMOVE whose
  source text contains a decision, lesson or rationale ("why") — **even when
  your after-text preserves it**. The tag asks the user to check your
  extraction; your confidence in it is not a reason to drop the tag.

## Recap format

Header:

```
Context hygiene — <n> findings (Wrong <a> · Stale <b> · Redundant <c>)
Always-loaded: <x> tok → ~<y> tok · On-demand: <p> KB → ~<q> KB
Working area discovered: <folders + signals, or "none">
Grouped by <relevance|area|extension> because <one reason>.
```

Grouping:

| Dimension | Choose when |
|---|---|
| relevance (Wrong → Stale → Redundant) | findings span several checks |
| area (CLAUDE.md · rules · memory index · memory files · working area) | findings concentrate in a few files |
| extension (tokens freed, files touched) | findings are mostly size |

The user may ask to regroup; re-present with the same item numbers.

Actions — lettered groups, globally numbered items:

```
A. <group title> (<k> actions, <±tok>)
  1. <VERB>  <target>[:line | §section]
     before: <schematic>        after: <schematic>
     why: <rationale, check>    benefit: <correctness ✔ | −N tok>    risk: <low|medium> [⚠ rationale-risk] [irreversible (not tracked)] [needs: BACKUP]
```

Verbs: `EDIT` `COMPRESS` `POINTER` `MERGE` `REMOVE` `BACKUP` `POLICY`.
- **One item per memory fact.** A change to a fact file's content or
  `description` and the change to its `MEMORY.md` line are always the same
  item — never split them, so no apply can leave the index and the file
  disagreeing.
- Include `BACKUP` whenever any item touches memory; mark those items `needs: BACKUP`.
- `BACKUP` and `POLICY` are numbered items like every other action.
- Include `POLICY` when no equivalent write-time rule exists in CLAUDE.md.
  If the project has no CLAUDE.md, POLICY creates it — the only file this
  skill may create besides the backup.

Close the recap with exactly:

> Nothing has been changed. Reply with item numbers or group letters to apply (e.g. "apply A, 3"). ⚠ and irreversible items must be named individually.

## Write-time rule

Proposed via `POLICY` into the project CLAUDE.md:

> Memory holds decisions, current policies, open items and one-line lessons — never status narrative. Status lives in git, PRs and issues; memory points to them.

## Final report

After apply:

```
Applied: <ids>        Skipped (not authorized): <ids>
Awaiting individual approval (⚠, irreversible, or memory without BACKUP): <ids or "none">
Always-loaded: <before> → projected <y> → actual <z> tok
Checks re-run: <remaining findings or "clean">
Kept items verified: <n>/<n> found (<file> for each)
Undo: memory → <backup path | "no backup (declined)">; tracked files → git (`git diff` / `git checkout -- <file>`); not recoverable → <ids of irreversible items, or "none">
```
