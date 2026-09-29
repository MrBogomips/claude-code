# Design

## Context

The skill is instructions only: `SKILL.md` gives the workflow and hard rules, and
`references/` holds the full protocol (`safety.md`, `retention-recap.md`, `checks.md`). An
uncommitted edit to `SKILL.md` added the stop-on-missing-reference rule, the mixed-reply rule
and the moved/deleted check, and rewrote Classify as a checklist. Two of its lines disagree
with the references. Motivation: see proposal.md, Why.

## Goals / Non-Goals

**Goals:**
- `SKILL.md` and `references/` state the same rule wherever both cover it.
- The existing Layer 2 scenarios keep their expected outcomes.

**Non-Goals:**
- No new verbs, recap fields or report sections.
- No change to the retention rule itself.

## Decisions

### D1. `⚠ rationale-risk` stays limited to COMPRESS, POINTER, MERGE and REMOVE (CTR-09)

The checklist line in the pending edit tagged any item whose source holds a rationale, EDIT
included. It is restored to the scope in `retention-recap.md` and the pre-edit `SKILL.md`.

- Why: the tag exists because shrinking actions can drop a rationale while extracting it. An
  EDIT corrects a wrong fact and leaves the surrounding text in place. The tag also removes an
  item from group approval (`safety.md` §Authorization), so tagging EDITs would make most
  corrections to CLAUDE.md need individual naming, for little protection.
- Rejected: widen the tag to EDIT and update `retention-recap.md` to match. More friction on
  the most common, lowest-risk item type.

### D2. The mixed-reply rule is triggered by vague approval of unnamed items, not by any vague word

The pending wording ("mixes explicit IDs with vague approval") also matches "yes, do 1 and 3",
which `safety.md` and Layer 2 authorization case 5 treat as authorizing exactly {1, 3}. The
rule now fires only when the vague part reaches items the reply does not name ("and the rest
looks fine"). A leading "yes" stays harmless.

- Rejected: re-prompt on any vague word. Breaks case 5 and adds a turn when the reply is
  already unambiguous.

### D3. The full rules live in `references/safety.md`; `SKILL.md` keeps the short form

`SKILL.md` points to `safety.md` as the full protocol, so the mixed-reply rule and the
moved/deleted check are added there too. The unreadable-reference rule stays in `SKILL.md`
only: it has to work when the references are missing.

## Risks / Trade-offs

- [The agent might read "report which of these happened" as requiring it to tell a move from a
  delete] → The scenario only requires reporting that the file is no longer at the recap path;
  telling the two apart is best effort.
- [The references check adds reads before discovery] → Discovery reads these files anyway;
  the check only moves the failure earlier.
