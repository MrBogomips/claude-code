# Tasks

## 1. Remove the plugins and their tests

- [x] 1.1 `git rm -r kaizen/ personal-voice/` and verify neither folder exists
- [x] 1.2 `git rm -r tests/test-kaizen-stop-gate.sh tests/scenarios/kaizen/ tests/scenarios/personal-voice-*/ tests/scenarios/integration/test-personal-voice-loop.md` and verify none of them exists
- [x] 1.3 Remove the kaizen Stop hook line from `tests/ci/run-structural-tests.sh`, its row from `tests/README.md` and the personal-voice row and intro mention from `tests/scenarios/integration/README.md`; verify `grep -n 'kaizen\|personal-voice'` on the three files prints nothing

## 2. Update the marketplace and the docs

- [x] 2.1 In `.claude-plugin/marketplace.json`, drop the `kaizen` and `personal-voice` entries and bump `metadata.version` 4.0.1 → 5.0.0 by editing the line in place; verify `jq -e .` parses the file and lists 5 plugins
- [x] 2.2 In `README.md`, drop the two plugin rows and the kaizen install and `npx skills` examples, and add a short "Moved" note with `/plugin marketplace add MrBogomips/claude-plugins` and `/plugin install kaizen@mrbogomips` or `personal-voice@mrbogomips`; verify the note is the only mention of either plugin
- [x] 2.3 Remove `kaizen/` and `personal-voice/` from the category table in `CONTRIBUTING.md` and from the plugin list in `CLAUDE.md`; verify with grep
- [x] 2.4 Run `grep -rn 'kaizen\|personal-voice'` outside `.git/` and `openspec/changes/archive/`, and verify every hit is this change, the README "Moved" note, or a generic mention that stays true

## 3. Verify

- [x] 3.1 Run `bash tests/ci/run-structural-tests.sh` and verify it passes
- [x] 3.2 Run the pre-PR Kaizen retrospective gate (more than 200 lines removed), propose its diffs to the user one by one, and commit only the accepted ones as `chore(kaizen): ...`; verify each diff got an explicit answer
- [x] 3.3 Archive this change with `/opsx:archive` as the last commit before merge; verify `openspec/specs/kaizen/` and `openspec/specs/personal-voice/` are gone and `openspec validate --all --strict` passes

## Workflow follow-up

- Merge only after the `MrBogomips/skills` and `MrBogomips/claude-plugins` PRs are merged.
