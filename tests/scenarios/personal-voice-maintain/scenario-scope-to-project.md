# Scenario: Scope to project, only for the current project

## Setup
Fixture created. Append three observations to the global `observations.md` before taking the
`before` fingerprint. The fixture's project root is `$F/project`, so its tag is `project: project`.

```bash
cat >> "$F/store/observations.md" <<'MD'

### "Ordine di lavoro", not "ticket"
- kind: lexicon
- language: it
- topic: software-engineering
- audience: clients
- destination: topics/software-engineering.md › Glossary
- evidence: 2
- sources:
  - 2026-09-10 · revision · text: kickoff recap to the client · project: project · "il ticket" → "l'ordine di lavoro"
  - 2026-09-24 · revision · text: weekly update to the client · project: project · "i ticket aperti" → "gli ordini di lavoro aperti"

### "Pratica", not "richiesta"
- kind: lexicon
- language: it
- topic: software-engineering
- audience: clients
- destination: topics/software-engineering.md › Glossary
- evidence: 2
- sources:
  - 2026-09-11 · revision · text: status note to another client · project: other-portal · "la richiesta" → "la pratica"
  - 2026-09-23 · revision · text: meeting follow-up to that client · project: other-portal · "le richieste" → "le pratiche"

### "termine-01-scelto" in the client project
- kind: lexicon
- language: it
- topic: software-engineering
- audience: clients
- destination: topics/software-engineering.md › Glossary
- reinforces: topics/software-engineering.md › Glossary › "termine-01-scelto"
- evidence: 2
- sources:
  - 2026-09-12 · revision · text: release note to the client · project: project · "termine-01-evitato" → "termine-01-scelto"
  - 2026-09-26 · revision · text: go-live email to the client · project: project · "termine-01-evitato" → "termine-01-scelto"
MD
```

Working directory: `$F/project`.

## Invocation
Run the recap; then approve the scope item by its number.

## Expected Behavior
- "Ordine di lavoro": every source carries the current project's tag and it reinforces nothing, so
  it is proposed as a MOVE to the current project's store (`.personal-voice/glossary.md`)
- "Pratica": every source carries another project's tag, so no MOVE; the recap adds a one-line note
  that its evidence comes from `other-portal`, and the promotion is proposed as usual
- The reinforcing observation: no MOVE, because the rule's earlier evidence has no project
  provenance; a note, and a REINFORCE item as usual

## Acceptance Criteria
- [ ] One MOVE (scope to project) item for "Ordine di lavoro", with destination `project › glossary.md`
- [ ] No MOVE item names `other-portal` or any store other than `$F/project/.personal-voice/`
- [ ] The recap has a note for "Pratica" naming `other-portal`, and a note for the reinforcing observation
- [ ] The reinforcing observation is a REINFORCE item, not a MOVE
- [ ] After approving the MOVE: `.personal-voice/glossary.md` gains an `[it]` rule about "ordine di lavoro" with `evidence: 2`; the observation is gone from the global `observations.md`; no global rule file gains it
- [ ] No file is created outside `$F/store` and `$F/project/.personal-voice/`
