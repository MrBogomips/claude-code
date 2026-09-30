# Scenario: Resume a run that stopped partway through APPLY

`fixture.sh interrupt` leaves an open run whose session ended in the middle of
APPLY of iteration 001. The backup of `src/a.txt` is the original file,
`created.txt` lists `src/DONE.md`, and `src/a.txt` has already lost its
`TODO: rename alpha` line. `src/DONE.md` was not created, and the run has no
`diff.patch`, `decision.json` or `summary.json`.

Setup for each case (fresh fixture each time):

```bash
bash tests/scenarios/kaizen-engine/fixture.sh create "$F" <variant>
bash tests/scenarios/kaizen-engine/fixture.sh fingerprint "$F" > "<scratch>/before.txt"
bash tests/scenarios/kaizen-engine/fixture.sh interrupt "$F" [project|user]
B="$(cat <open-run-dir>/iterations/001/backup/src/a.txt | cksum)"   # backup checksum
```

Use the README prompt. For the `user` root, add to the prompt: "Treat `$F/home`
as the home directory: `~/.kaizen/` means `$F/home/.kaizen/`."

## Cases

1. **Restore before APPLY runs again**: variant `strict-epsilon`, root `project`; reply "resume"
   - [ ] The agent offers to resume `2026-01-15-todo-count-001` and does not create a second run directory
   - [ ] It does not ask about uncommitted changes in `src/a.txt`: that edit is the run's own half-applied change, which it restores before the git check
   - [ ] The backup is untouched: `cksum < <open-run-dir>/iterations/001/backup/src/a.txt` still gives `$B`, and the file still contains `TODO: rename alpha`
   - [ ] `iterations/001/diff.patch` exists and shows exactly the proposed change: one deleted line in `src/a.txt` and `src/DONE.md` created with `rename alpha`
   - [ ] The iteration reverts (delta 1 < epsilon 5), and the fingerprint diff against `before.txt` is empty: `src/a.txt` has its TODO line back and `src/DONE.md` does not exist. Without the restore, the backup would hold the half-edited file and the TODO line would be lost
2. **Resumed iteration is kept cleanly**: variant `default`, root `project`; reply "resume"
   - [ ] `src/a.txt` is exactly `alpha line one`, `alpha line three`, and `src/DONE.md` holds `rename alpha` once
   - [ ] One `kaizen(todo-count): iteration 1` commit contains only `src/a.txt` and `src/DONE.md`, and `decision.json` has an empty `dirty_before_apply`
3. **User-level run is found**: variant `default`, root `user`; reply "resume"
   - [ ] The agent finds the open run under `$F/home/.kaizen/runs/` and names that root when it offers the resume
   - [ ] All new files (`diff.patch`, `verification.json`, `decision.json`, `summary.json`) are written under `$F/home/.kaizen/runs/2026-01-15-todo-count-001/`, and no run directory appears under `$F/repo/.kaizen/runs/`
4. **Resume declined**: variant `default`, root `project`; reply "no, start a new run"
   - [ ] The agent says it restored the old iteration. When it offers the `kaizen/<run-id>` branch (the git check), `src/a.txt` has its TODO line back (`cksum < "$F/repo/src/a.txt"` gives `$B`) and `src/DONE.md` does not exist
   - [ ] It asks no question about uncommitted changes in `src/a.txt`
   - [ ] The old run's `summary.json` now exists with `convergence_reason: "user_stopped"`, and its `backup/` is unchanged
   - [ ] The new run directory is `<today>-todo-count-002` under `$F/repo/.kaizen/runs/`
