# Run State

Read at BOOTSTRAP. This file holds the rules for resuming a run, carrying state across runs and checking git, and the schema of every file the engine writes under `.kaizen/runs/{run-id}/`.

## Resume

Runs live under one of two storage roots: `.kaizen/` at the project root or `~/.kaizen/`. Both are searched for open runs, because a user-level run is invisible from the project root. A run is open when it has a `manifest.json` and its `summary.json` is missing (it stopped before its first LOG) or has `convergence_reason: null`. In each root, only the latest run of a profile is offered for resume, and a resumed run keeps its root.

When the user resumes:
1. Reuse the run directory and read `manifest.json` and, if present, `summary.json`. The manifest holds everything settled at BOOTSTRAP, so the profile's BOOTSTRAP section is not repeated.
2. If `git.branch` is set and is not the current branch, ask before switching to it.
3. Find where the run stopped: the highest iteration directory without a `decision.json`. If every iteration has one, start the next iteration and skip to step 5.
   - `backup/` exists but `diff.patch` does not: APPLY stopped partway, and the targets may be half-edited. Restore every file from `backup/` and delete each file listed in `backup/created.txt` that exists, so the targets are back to their pre-iteration state. Then continue at APPLY step 1, which keeps the existing backup copies. Re-running APPLY without this restore would copy the half-edited files over the real backup, and a later REVERT would restore the wrong content; with `git.commits: false` the backup is the only way back.
   - `diff.patch` exists but `verification.json` does not: continue at VERIFY (a process change waiting for new metrics).
   - `verification.json` exists: continue at DECIDE.
   - Only `proposal.md` exists: continue at the autonomy gate (present the proposal again if the run is supervised), then APPLY.
   - Otherwise: restart the iteration at MEASURE.
4. Run the git check below again, after the restore in step 3: the targets may have been edited since the last session. Files that an iteration paused at VERIFY or DECIDE changed are expected to differ from HEAD and are not flagged. If such a file no longer matches its `diff.patch`, it was edited after APPLY: tell the user and add it to that iteration's `dirty-before-apply.txt`, so KEEP does not commit it.
5. Continue with the patience counter from `summary.json` (0 if absent).

When the user starts a new run instead, first restore an iteration of the open run that stopped partway through APPLY (step 3, first case) and tell the user, so the new run does not start from half-edited targets. Then record `convergence_reason: "user_stopped"` in the open run's `summary.json`, creating the file if needed.

## Continuity Across Runs

- Every run measures its own baseline. The previous run's `current` KPIs are stored as `previous_final` in the new manifest, so reports can join the runs, but they are never used as this run's baseline: the target may have changed in between.
- The previous run's measure script is reused when all three hold: the profile `version` in its manifest equals the current one, its KPI names are the same, and its `adversarial_review` is not `flagged`. Record the source in `measure_script_reused_from`. Write a fresh `config.json` either way, since sources and scope can differ between runs.
- Bump the profile `version` whenever a KPI formula changes. A new version makes the next run generate a new script, and reports then show where the tool changed.

## Git Check

Run once at BOOTSTRAP, after the mutation targets are final, and again on resume.

1. If `git rev-parse --is-inside-work-tree` fails for the targets, set `git.repo: false` and `git.commits: false`. KEEP then leaves changes in place, and the backups are the only way back.
2. Run `git status --porcelain -- <each default target>`. An empty result means the targets are clean.
3. If files are listed, stop and ask:
   - **Commit or stash first:** wait, then run step 2 again.
   - **Run without commits:** set `git.commits: false`. Kept changes stay in the working tree, and REVERT still restores each file from its backup, including the user's own edits.
4. Offer the branch `kaizen/{run-id}`. If the user accepts, run `git switch -c kaizen/{run-id}` and record it in `git.branch`.

APPLY repeats a narrower check for each iteration and writes the result to `iterations/{NNN}/dirty-before-apply.txt`: a file that is dirty just before APPLY holds edits the iteration did not make (for example, the user edited it between sessions), so that iteration is never committed. The list is a file, not only a field of `decision.json`, so that it survives a session that ends between APPLY and DECIDE.

## manifest.json

```json
{
  "run_id": "{run-id}",
  "profile": "{profile-name}",
  "profile_version": "{version}",
  "profile_path": "{path of the PROFILE.md that was loaded}",
  "storage_root": "project|user",
  "started_at": "ISO-8601",
  "strategy": "greedy|multi-objective",
  "autonomy": "autonomous|supervised|hybrid(N)",
  "iteration_budget": 10,
  "convergence": {"epsilon": 0.02, "patience": 3},
  "kpis": [
    {
      "name": "kpi_name",
      "description": "...",
      "direction": "maximize|minimize",
      "unit": "ratio|percentage|count|seconds|custom",
      "epsilon": 0.02,
      "observational": false,
      "measurement_method": "automated|user-reported|hybrid",
      "formula": "..."
    }
  ],
  "mutation_targets": {"defaults": ["path or pattern"], "immutable": ["pattern"]},
  "verify_checks": [{"name": "build", "command": "npm run build"}],
  "git": {"repo": true, "commits": true, "branch": "kaizen/{run-id}", "dirty_at_start": []},
  "measure_script": "measure.py",
  "measure_script_reused_from": null,
  "scope_overrides": {},
  "previous_run": null,
  "previous_final": null
}
```

- `kpis[].epsilon` is the effective value: the KPI's own `epsilon`, else `convergence.epsilon`.
- `measure_script` is `null` when the profile measures inline.
- `git.branch` is `null` when the user kept the current branch.
- `storage_root` is `project` for `.kaizen/` at the project root, `user` for `~/.kaizen/`.

## measurement.json and verification.json

```json
{
  "iteration": 1,
  "timestamp": "ISO-8601",
  "kpis": {"kpi_name": 0.75},
  "source": "automated|user-reported|hybrid",
  "execution_time_ms": 1234,
  "warnings": []
}
```

## decision.json

```json
{
  "iteration": 1,
  "decision": "keep|revert",
  "strategy": "greedy|multi-objective",
  "summary": "one line: target and change",
  "kpi_deltas": {
    "kpi_name": {"before": 0.70, "after": 0.75, "delta": 0.05, "epsilon": 0.02,
                 "direction": "improved|regressed|unchanged", "observational": false}
  },
  "reasoning": "...",
  "apply_failed": false,
  "verify_failed": false,
  "failed_check": null,
  "no_proposal": false,
  "user_note": null,
  "escalated": false,
  "dirty_before_apply": [],
  "commit": null,
  "commit_skipped": null
}
```

- `direction` is `unchanged` when the absolute delta is below the KPI's epsilon.
- `failed_check` names the verify check that failed when `verify_failed` is `true`.
- `user_note` carries the user's reason when they rejected the proposal (`no_proposal: true`) or answered an escalation.
- `dirty_before_apply` is copied from the iteration's `dirty-before-apply.txt`.
- `commit` is the commit hash after a committed KEEP. `commit_skipped` is `"no_commits"`, `"dirty_before_apply"` or `"commit_failed"` when a KEEP was left in the working tree.

## summary.json

```json
{
  "profile": "{name}",
  "run_id": "{run-id}",
  "started_at": "ISO-8601",
  "updated_at": "ISO-8601",
  "iterations_completed": 3,
  "iterations_kept": 1,
  "iterations_reverted": 2,
  "baseline": {"kpi_name": 0.60},
  "current": {"kpi_name": 0.75},
  "improvement": {"kpi_name": "+25.0%"},
  "patience_counter": 1,
  "reverted_proposals": ["iteration 2: src/api/handler.py — extract parse_header()"],
  "convergence_reason": null
}
```

- `current` holds the KPIs of the state the run keeps: the verification values after a KEEP, the measurement values after a REVERT.
- `reverted_proposals` has one line per reverted or user-rejected proposal, in iteration order. It is passed to every later proposer.
- `convergence_reason` is `null` while the run is open, then one of `"patience_exceeded"`, `"budget_exhausted"`, `"user_stopped"` or `"adversarial_flag"`. Step 3 adds `"adversarial_review": "passed|flagged"`.
