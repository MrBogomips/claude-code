# kaizen-engine Test Scenarios

Layer 2 behavioural scenarios for the `kaizen-engine` skill. They run a fresh
agent against a disposable git repository with a trivial greedy profile
(`todo-count`: minimize the TODO lines under `src/`), and compare state
fingerprints to prove that REVERT restores files byte for byte and that KEEP
commits only what the iteration changed.

Requires `git` (2.28 or later) and `python3`, which the generated measurement
script runs on.

## Setup

```bash
F="<scratch>/kz-fixture-N"                                  # any new, non-existent dir
bash tests/scenarios/kaizen-engine/fixture.sh create "$F" [variant]
bash tests/scenarios/kaizen-engine/fixture.sh fingerprint "$F" > "<scratch>/before.txt"
```

Give the agent this prompt:

> Read `<repo>/kaizen/skills/kaizen-engine/SKILL.md` and its references, and
> follow the skill exactly. Task: run the kaizen profile `todo-count` on the
> project whose root is `$F/repo`. Work only inside `$F`.

If the kaizen plugin is not installed, its agents cannot be dispatched and the
engine runs ANALYZE, PROPOSE and the reviews inline (SKILL.md §6). That is
expected here; the scenarios check the loop's file and git effects, not agent
dispatch.

**Standard replies** at BOOTSTRAP, unless a case says otherwise:

| Question | Reply |
|---|---|
| Scope overrides | "none" |
| Branch `kaizen/<run-id>` | "no, stay on main" |
| Verify checks (`sh checks/verify.sh`) | "yes, use it" |

After the run:

```bash
bash tests/scenarios/kaizen-engine/fixture.sh fingerprint "$F" | diff "<scratch>/before.txt" -
R=$(ls -d "$F"/repo/.kaizen/runs/*/ | tail -n 1)            # the run directory
cat "$R/manifest.json" "$R/iterations/001/decision.json"
```

## Fixture

| Item | Content |
|---|---|
| `src/a.txt`, `src/b.txt` | 7 lines, 3 of them contain `TODO` (baseline `todo_count` = 3) |
| `README.md` | Tracked, with an uncommitted edit: outside the targets, must never be committed or prompt |
| `checks/verify.sh` | The profile's VERIFY check; immutable |
| `.kaizen/profiles/todo-count/PROFILE.md` | Custom profile, found by name in `.kaizen/profiles/`. Greedy, autonomous, budget 1, patience 1 |

| Variant | KPI `epsilon` | `convergence.epsilon` (fallback) | `checks/verify.sh` | Expected decision |
|---|---|---|---|---|
| `default` | 1 | 10 | always passes | KEEP (delta 1 ≥ 1; the fallback would have reverted) |
| `strict-epsilon` | 5 | 1 | always passes | REVERT (delta 1 < 5; the fallback would have kept) |
| `failing-check` | 1 | 10 | fails once any `src/*.txt` line is deleted | REVERT with `verify_failed` |

`fixture.sh dirty "$F"` appends an uncommitted line to `src/a.txt`, inside the
mutation targets.

`fixture.sh interrupt "$F" [project|user]` adds an open run
(`2026-01-15-todo-count-001`) whose session ended partway through APPLY of
iteration 001: backup and `created.txt` written, `src/a.txt` already edited,
`src/DONE.md` not yet created. `project` puts it in `$F/repo/.kaizen/runs/`,
`user` in `$F/home/.kaizen/runs/`, with the prompt telling the agent that `~` is
`$F/home`.

## Scenarios

| File | What it tests |
|------|--------------|
| scenario-dirty-tree.md | Dirty targets prompt before any commit; run without commits; the `kaizen/<run-id>` branch |
| scenario-keep.md | KEEP commits only the iteration's files; per-KPI epsilon beats a stricter fallback |
| scenario-revert.md | REVERT restores files byte-identically, deletes created files, keeps the user's uncommitted edits; per-KPI epsilon beats a looser fallback |
| scenario-verify-failed.md | A failed verify check reverts despite a KPI gain; a check that fails on the baseline is not recorded |
| scenario-resume.md | A run stopped mid-APPLY is restored from its backup before APPLY runs again; open runs are found in both storage roots; declining a resume restores and closes the old run |
