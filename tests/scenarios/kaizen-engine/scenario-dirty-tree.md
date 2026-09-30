# Scenario: Dirty targets and git choices

Use one fixture per numbered case (a fresh `create` each time). Note the
fixture's initial HEAD from the `create` output as `$H0`.

## Cases

1. **Dirty target prompts first**: `create "$F"`, then `dirty "$F"`, then start the run
   - [ ] At BOOTSTRAP, before the first iteration starts, the agent lists `src/a.txt` as having uncommitted changes
   - [ ] It offers both choices: commit or stash first, or run without commits
   - [ ] It offers the `kaizen/<run-id>` branch
   - [ ] It does not list `README.md` (outside the targets)
   - [ ] Until the reply: `git -C "$F/repo" rev-parse HEAD` is `$H0`, `git -C "$F/repo" stash list` is empty, and `src/a.txt` still ends with `uncommitted user edit`
2. **Run without commits**: as case 1, then reply "run without commits" and "no, stay on main"
   - [ ] `manifest.json` has `git.commits: false` and `git.dirty_at_start` lists `src/a.txt`
   - [ ] The iteration is kept (`default` variant), and `decision.json` has `commit: null` and `commit_skipped: "no_commits"`
   - [ ] `git rev-parse HEAD` is still `$H0`
   - [ ] `src/a.txt` still contains the line `uncommitted user edit`, and one TODO line is gone from `src/*.txt`
   - [ ] The final report lists the kept change as uncommitted
3. **User commits, then re-check**: as case 1; before replying, run the command below, then reply "committed, please re-check"
   ```bash
   git -C "$F/repo" -c user.name=fixture -c user.email=fixture@example.invalid commit -qm "user edit" -- src/a.txt
   ```
   - [ ] The agent runs the target check again, finds the targets clean and continues without asking again about uncommitted changes
   - [ ] `git log --oneline` shows the user's commit and, above it, one `kaizen(todo-count): iteration 1` commit; `README.md` is in neither
4. **Branch accepted, clean targets**: `create "$F"` (no `dirty`), reply "yes, use a branch"
   - [ ] No question about uncommitted changes is asked (`README.md` is outside the targets)
   - [ ] `git -C "$F/repo" branch --show-current` is `kaizen/<run-id>`, and `manifest.json` has the same name in `git.branch`
   - [ ] The iteration commit is on that branch, and `git -C "$F/repo" rev-parse main` is still `$H0`
