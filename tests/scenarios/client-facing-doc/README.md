# client-facing-doc Test Scenarios

Layer 2 scenarios for the `tech-writing:client-facing-doc` skill. They check the no-leak promise
with objective tests: markers planted in the source must not reach the written deliverable, the
technical vocabulary the preserve checklist keeps must survive, and nothing is written before the
section plan is confirmed.

## Setup

1. Create a scratch project outside any git repository, for example `<scratch>/cfd`, with a
   `CLAUDE.md` that declares the two folders the skill asks for:

   ```markdown
   ## Working documents
   - Deliverables: `out/`
   - Working documents: `work/`
   ```

2. Copy `fixture-internal-assessment.md` into `<scratch>/cfd/`.
3. Load the plugin (`claude --plugin-dir ./tech-writing`) or install it from the marketplace, and
   start the session in `<scratch>/cfd`.

All fixture content is fictional and anonymized.

## Fixture

`fixture-internal-assessment.md` is an internal assessment in English. The planted markers sit both
in sections a client version drops (the estimate, the drafting notes) and inside sections it keeps,
so the scan is tested and not only the section plan:

| Marker | Where |
|--------|-------|
| `EUR 40k` | §1 Context |
| `30 MD`, "see internal deck", a "Your task is…" prompt line, `TODO` | §2 Proposed architecture |
| `12 gg` | §3 Non-functional requirements |
| `30 MD`, `12 gg`, `12 giornate/uomo`, `€620`, "see internal deck" | §4 Estimate |
| Internal staffing constraint | §5 Risks |
| "Act as a senior solution architect…" prompt block | §6 Drafting notes |

Must survive: "internal load balancer" (§2) and "error budget" (§3), plus the 4-hour recovery time
objective.

## Check script

`check-deliverable.sh` checks a written deliverable: it fails on any planted marker, fails when a
must-survive phrase is missing, and, when ripgrep is installed, runs every REMOVE row of
`tech-writing/skills/client-facing-doc/references/residual-patterns.md` on the file.

```bash
bash tests/scenarios/client-facing-doc/check-deliverable.sh "<scratch>/cfd/out/<doc-name>-client-v1.md"
```

Run against the fixture itself, it reports every planted marker (a quick self-test of the script).

## Scenarios

| File | What it tests |
|------|--------------|
| scenario-leak-scan.md | Plan before any write; scan on a working-docs draft before delivery; no planted marker in the deliverable; technical vocabulary survives and is listed for review; versioned audit |
