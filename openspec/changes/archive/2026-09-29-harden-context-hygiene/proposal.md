# Proposal

## Why

An audit of the `context-hygiene` skill found gaps where the agent has to guess: a missing
reference file, a reply that names some items and waves at the rest, a target that disappeared
between recap and apply. A pending edit to the skill also widened the `⚠ rationale-risk` tag to
EDIT items, which contradicts `references/retention-recap.md` (audit finding CTR-09). Both need
settling before the pending edit ships.

## What Changes

- The skill stops before discovery when a file under `references/` cannot be read, and names
  the file.
- A reply that combines explicit item IDs with vague approval of further items authorizes
  nothing yet: the agent echoes the explicit IDs and re-prompts for the rest. A reply whose
  only vague part is a leading "yes" still authorizes exactly the IDs it names.
- At apply time, a target that was moved or deleted since the recap is handled like a changed
  one: that item stops, the agent reports the state, and asks again.
- `⚠ rationale-risk` applies only to COMPRESS, POINTER, MERGE and REMOVE items whose source
  holds a decision, lesson or rationale; EDIT items are not tagged (resolves CTR-09 in favor
  of the existing reference).
- Behavior-neutral: the Discover step lists the working-area signals inline, and the Classify
  step becomes a numbered sub-checklist.

## Capabilities

### New Capabilities
- `context-hygiene/authorization`: what counts as authorization to apply recap items, including
  mixed replies.
- `context-hygiene/apply-safety`: guards at run start and before each authorized item is
  applied (unreadable references, changed, moved or deleted targets).
- `context-hygiene/recap-classification`: which recap items carry the `⚠ rationale-risk` tag.

### Modified Capabilities
None. context-hygiene has no specs yet; these capabilities specify only the behavior this
change touches.

## Impact

- **Plugins**: `context-hygiene` 0.1.0 → 0.2.0 (minor: new stop condition and stricter
  authorization parsing), in `plugin.json` and its `marketplace.json` entry.
- **Marketplace**: `metadata.version` patch bump, 3.2.0 → 3.2.1, as for previous plugin
  updates.
- **Files**: `context-hygiene/skills/context-hygiene/SKILL.md`, `references/safety.md`.
- **Tests**: new cases in `tests/scenarios/context-hygiene/scenario-authorization.md` and
  `scenario-dry-run.md`; existing case 5 ("yes, do …") must keep passing.
- **Users**: runs that stop on a missing reference or re-prompt on a mixed reply need one more
  turn; nothing that was applied before is applied without authorization now.
