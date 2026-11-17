# Proposal

## Why

The `kaizen` and `personal-voice` plugins now live in the `MrBogomips/skills` repository as top-level
plugin folders `kaizen/` and `personal-voice/`, and are listed as two separate plugins in the
`mrbogomips` marketplace hosted in `MrBogomips/claude-plugins`. Keeping a second copy in this
marketplace would split their history and let the two copies drift.

## What Changes

- **BREAKING**: remove the `kaizen` plugin (skill `kaizen`, agent `kaizen-reviewer`, `Stop` hook) and the
  `personal-voice` plugin (skills `write`, `learn`, `maintain`, `userConfig.store_dir`) from the
  `mrbogomips-tools` marketplace, together with their tests (`tests/test-kaizen-stop-gate.sh`,
  `tests/scenarios/kaizen/`, `tests/scenarios/personal-voice-*/`,
  `tests/scenarios/integration/test-personal-voice-loop.md`).
- In their new home, personal-voice's skills are renamed `voice-write`, `voice-learn` and
  `voice-maintain` (personal-voice 1.0.0). kaizen keeps its name and behavior.
- Point users to the new install: `/plugin marketplace add MrBogomips/claude-plugins`, then
  `/plugin install kaizen@mrbogomips` or `/plugin install personal-voice@mrbogomips`.
- Retire the seven capability specs of the two plugins; they stay readable in this repository's history
  (see design.md).
- Marketplace: drop both entries from `.claude-plugin/marketplace.json` and bump `metadata.version`
  4.0.1 → 5.0.0 (major: two plugins removed). No remaining plugin changes version.
- Update `README.md`, `CONTRIBUTING.md`, `CLAUDE.md`, `tests/README.md`,
  `tests/scenarios/integration/README.md` and `tests/ci/run-structural-tests.sh` so nothing points at the
  removed folders.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

Every requirement of these capabilities is REMOVED; the capabilities are retired:

- `kaizen/asset-attribution`
- `kaizen/proposal-apply`
- `kaizen/session-gate`
- `personal-voice/voice-learning`
- `personal-voice/voice-maintenance`
- `personal-voice/voice-store`
- `personal-voice/voice-writing`

## Impact

- Users who installed `kaizen@mrbogomips-tools` or `personal-voice@mrbogomips-tools` stop receiving
  updates from this marketplace and must reinstall from `mrbogomips`. The personal-voice store
  (`store_dir` and any `.personal-voice/` project store) is user data outside the plugin and is not
  touched by this change.
- Repository files: `kaizen/`, `personal-voice/`, the tests listed above, `.claude-plugin/marketplace.json`,
  `README.md`, `CONTRIBUTING.md`, `CLAUDE.md`, `tests/README.md`, `tests/scenarios/integration/README.md`,
  `tests/ci/run-structural-tests.sh`, and `openspec/specs/kaizen/`, `openspec/specs/personal-voice/`
  through archive.
- Merge order across repositories: `MrBogomips/skills` first, then `MrBogomips/claude-plugins`, then this
  change, so the new install works before the old one disappears.
