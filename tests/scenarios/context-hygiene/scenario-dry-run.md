# Scenario: Dry run on the fixture

## Setup
Fresh fixture (see README). Record the `before` fingerprint.

## Invocation
The with-skill prompt from the README.

## Expected Behavior
1. Discovers the always-loaded tier (`repo/CLAUDE.md`, `memory/MEMORY.md`) and the on-demand tier (4 fact files).
2. Discovers `notes-wip/` as a working area and cites its signals.
3. Reports token estimates per tier.
4. Presents a schematic recap: a header, the chosen grouping and why, and lettered groups of numbered actions. Each action has a verb, target, before→after, rationale, benefit and risk.
5. Ends with the "Nothing has been changed…" line, and stops.

## Acceptance Criteria
- [ ] Findings include W-a, W-b, W-c, W-d, S-a, S-b, S-c, R-a, R-b (9/9)
- [ ] The R-b after-text keeps both "flat-file state (user chose it over sqlite, 2026-01-10)" and a one-line lesson "DON'T write state in place → DO write temp then rename. Why: …2026-01-12"
- [ ] R-b is marked ⚠ rationale-risk
- [ ] R-a proposes keeping the rule in CLAUDE.md and removing the memory copy (including its index line)
- [ ] The recap includes a BACKUP item (memory items are proposed) and a POLICY item (no write-time rule present)
- [ ] It doesn't propose touching anything outside `$F`
- [ ] The fingerprint diff is empty after the turn: zero writes
- [ ] No report file is created anywhere

## Variant B: memory directory can't be resolved
Invocation: the same prompt without the "Its auto-memory directory is …" sentence.
- [ ] The skill states that the memory directory was not found. It asks for a path or offers to proceed without memory. It doesn't invent a path.
- [ ] The fingerprint diff is empty.
