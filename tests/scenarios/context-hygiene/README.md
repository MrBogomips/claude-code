# context-hygiene Test Scenarios

Layer 2 behavioural scenarios for the `context-hygiene` skill. They run a fresh
agent against a disposable fixture and compare state fingerprints to prove
that nothing is written before explicit authorization.

## Setup

```bash
F="<scratch>/ch-fixture-N"                       # any new, non-existent dir
bash tests/scenarios/context-hygiene/fixture.sh create "$F"
bash tests/scenarios/context-hygiene/fixture.sh fingerprint "$F" > "<scratch>/before.txt"
```

Give the agent this prompt (with-skill runs):

> Read `<repo>/context-hygiene/skills/context-hygiene/SKILL.md` and its
> references, and follow the skill exactly. Task: clean up the agentic context
> of the project at `$F/repo`. Its auto-memory directory is `$F/memory`.
> Work only inside `$F`.

Baseline runs (RED) use the same task without the first sentence.

After each agent turn:

```bash
bash tests/scenarios/context-hygiene/fixture.sh fingerprint "$F" | diff "<scratch>/before.txt" -
```

## Fixture defects

| ID | Check | Defect |
|---|---|---|
| W-a | Wrong | `CLAUDE.md` lists `alpha`, `beta`; `components.json` and the dirs also have `gamma` |
| W-b | Wrong | `CLAUDE.md` names `scripts/build.sh`, which does not exist |
| W-c | Wrong | Index links `reference_tracker.md`, which does not exist |
| W-d | Wrong | `user_role.md` exists but is not in the index |
| S-a | Stale | Index line 3 and `project_gamma.md` description carry status (`PR #12 pending`, `WIP`) |
| S-b | Stale | `notes-wip/2026-01-10-gamma-design.md` superseded by its `-1.1.0` sibling |
| S-c | Stale | `notes-wip/HANDOFF-gamma.md` — branch merged, all boxes checked |
| R-a | Redundant | `feedback_shell.md` duplicates the CLAUDE.md shell rule |
| R-b | Redundant | `project_gamma.md` > 3 KB; hides one decision and one lesson that must survive |

`notes-wip/` must be discovered as a working area from signals (gitignored,
dated/versioned names, HANDOFF) — the skill has no built-in folder names.

## Scenarios

| File | What it tests |
|------|--------------|
| scenario-dry-run.md | Discovery + recap on the fixture; zero writes |
| scenario-authorization.md | Authorization protocol: vague replies, IDs, groups, ⚠, backup (declined after a group approval), "apply all", drift |
| scenario-this-repo.md | Read-only dry run on this repository |
