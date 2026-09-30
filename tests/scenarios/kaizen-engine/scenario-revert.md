# Scenario: REVERT is byte-identical

Fixture: `create "$F" strict-epsilon` (KPI `epsilon: 5`, fallback
`convergence.epsilon: 1`). Removing one TODO improves `todo_count` by 1, which is
below the KPI's own epsilon, so the iteration must revert. Use the standard
replies, and take the `before.txt` fingerprint right after `create` (or after
`dirty` in case 2).

## Cases

1. **Clean targets**
   - [ ] `iterations/001/diff.patch` exists and shows the applied change, and `iterations/001/backup/created.txt` lists `src/DONE.md`
   - [ ] `decision.json` has `decision: "revert"`, a `todo_count` delta of 1 and `epsilon: 5`. The fallback of 1 would have kept it
   - [ ] The fingerprint diff against `before.txt` is empty: every file is byte-identical, `src/DONE.md` does not exist, HEAD and branch are unchanged
   - [ ] `summary.json` → `reverted_proposals` has one line for iteration 1, and `iterations_reverted` is 1
   - [ ] No commit was made: `git -C "$F/repo" rev-list --count HEAD` is 1
2. **Revert keeps the user's uncommitted edits**: run `dirty "$F"` before taking `before.txt`, then reply "run without commits" to the uncommitted-changes question
   - [ ] The iteration reverts as in case 1
   - [ ] The fingerprint diff against `before.txt` is empty, so `src/a.txt` still ends with `uncommitted user edit`: REVERT restored the backup and did not run `git checkout` or `git restore` on the file
