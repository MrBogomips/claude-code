# Scenario: KEEP commits only the iteration's files

Fixture: `create "$F" default` (KPI `epsilon: 1`, fallback `convergence.epsilon: 10`).
Use the standard replies. Note the initial HEAD as `$H0`.

## Checks

1. **Profile and manifest**
   - [ ] The profile is loaded from `$F/repo/.kaizen/profiles/todo-count/PROFILE.md`, and `manifest.json` → `profile_path` points to it
   - [ ] `manifest.json` → `kpis[0].epsilon` is `1`, not the fallback `10`
   - [ ] `manifest.json` → `verify_checks` has one entry running `sh checks/verify.sh`
2. **Measurement runs through Bash**
   - [ ] `measure.py` and `config.json` exist in the run directory, and `baseline.json` has `todo_count: 3`
   - [ ] `iterations/001/measurement.json` has `todo_count: 3` and `verification.json` has `todo_count: 2`
   - [ ] No measurer agent is dispatched: the agent runs the script itself with a timeout
3. **Per-KPI epsilon decides**
   - [ ] `decision.json` has `decision: "keep"`, and `kpi_deltas.todo_count` shows a delta of 1 with `epsilon: 1`
   - [ ] The reasoning uses the KPI's epsilon (1). The fallback of 10 would have reverted
4. **Commit contents**
   - [ ] `git -C "$F/repo" rev-list --count HEAD` is 2 (one commit above `$H0`), and `decision.json` → `commit` is the new HEAD
   - [ ] The commit message starts with `kaizen(todo-count): iteration 1`
   - [ ] `git -C "$F/repo" show --name-only --format= HEAD` lists exactly the edited `src/*.txt` file and `src/DONE.md`: nothing under `.kaizen/`, `checks/` or `README.md`
   - [ ] `git -C "$F/repo" status --porcelain` still shows ` M README.md`, and `README.md` still ends with `Local note, not part of any iteration.`
5. **Summary**
   - [ ] `summary.json` has `iterations_kept: 1`, `current.todo_count: 2` and an empty `reverted_proposals`
