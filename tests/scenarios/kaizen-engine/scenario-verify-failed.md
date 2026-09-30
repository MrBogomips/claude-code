# Scenario: A failed verify check forces REVERT

Fixture: `create "$F" failing-check`. `checks/verify.sh` passes on the baseline
(7 lines in `src/*.txt`) and fails as soon as a line is deleted, which every
proposal allowed by the profile does. Take `before.txt` right after `create`.

## Cases

1. **KPI gain, failed check**: use the standard replies
   - [ ] At BOOTSTRAP the agent proposes `sh checks/verify.sh` as a verify check, runs it once, and records it in `manifest.json` → `verify_checks`
   - [ ] `iterations/001/verification.json` has `todo_count: 2`, an improvement of at least the KPI's epsilon (1)
   - [ ] `decision.json` has `decision: "revert"`, `verify_failed: true` and `failed_check` naming the `checks/verify.sh` check. The reasoning says the check failed, not that the KPI did not improve
   - [ ] The fingerprint diff against `before.txt` is empty: files restored byte for byte, `src/DONE.md` deleted, no commit
2. **Check that fails on the baseline**: before starting the run, make the check fail everywhere
   ```bash
   printf '#!/bin/sh\nexit 1\n' > "$F/repo/checks/verify.sh"
   ```
   - [ ] No question about uncommitted changes is asked (`checks/` is outside the mutation targets)
   - [ ] At BOOTSTRAP the agent reports that the check already fails and leaves it out: `manifest.json` → `verify_checks` is empty
   - [ ] The iteration is then decided on the KPI alone: `decision.json` has `decision: "keep"` and `verify_failed: false`
