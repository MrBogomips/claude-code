# Proposal

## Why

kaizen 1.2.0 is a generic KPI loop engine of about 3,800 lines (8-phase iterations, generated measurement
scripts, ratchet strategies, 3 profiles, 3 agents, 3 skills, 3 commands). Only one profile touches agent
context, and Claude Code now ships most of what that profile measured or proposed (`/doctor`,
`/doctor prompt-audit`, `/skill-doctor`, `/insights`, `/fewer-permission-prompts`, auto memory). What
nothing covers is a retrospective of one session: which skills, agents, MCP tools, rules, memory and
settings the harness activated, which of them caused the errors, reworks and ambiguities met in that
session, and a safe way to fix the project-owned ones without growing the local skill and agent set.

## What Changes

- **BREAKING**: remove the KPI loop engine and everything built on it: skills `kaizen-engine`,
  `kaizen-report`, `kaizen-profile-designer`; agents `kaizen-analyzer`, `kaizen-proposer`; commands
  `/kaizen`, `/kaizen-help`, `/kaizen-history`; the 3 bundled profiles; `CONNECTORS.md`; the `.kaizen/`
  run audit trail.
- Add a `Stop` command hook that checks mechanical session signals (files edited, lines changed,
  sensitive paths, tool errors, user interruptions) and, at most once per session, asks the model to
  judge the full gate and offer kaizen in one line. It never calls a model itself and never blocks.
- Add one skill, `kaizen`, run only at the user's request. It attributes each incident of the session to
  the asset responsible, classifies each asset by origin, proposes edits with options for tracked project
  assets, gives advice only for external ones (user, plugin, managed, bundled, generated, untracked), and
  points at the harness feature or tool that owns anything else.
- Rewrite the `kaizen-reviewer` agent as a read-only reviewer of proposed after-text: contradictions,
  duplicates, length, growth, trigger and frontmatter issues.
- Apply only the items the user names, one by one; no reports, state files or commits.
- Plugin: kaizen 1.2.0 → 2.0.0 in `kaizen/.claude-plugin/plugin.json` and its
  `.claude-plugin/marketplace.json` entry (major: breaking removal). Marketplace `metadata.version`
  4.0.0 → 4.0.1.

## Capabilities

### New Capabilities

- `kaizen/session-gate`: when and how the Stop hook offers kaizen, its signals, thresholds and
  fail-silent behavior.
- `kaizen/asset-attribution`: how the skill inventories the session's assets, classifies their origin,
  links incidents to them and routes each finding (proposal, advice, pointer, memory promotion).
- `kaizen/proposal-apply`: review of proposed edits, the anti-growth rules, the recap, item-level
  authorization and safe application.

### Modified Capabilities

- `kaizen/iteration-safety`: retired, every requirement removed with the KPI engine.
- `kaizen/kpi-ratchet`: retired, every requirement removed with the KPI engine.
- `kaizen/measurement`: retired, every requirement removed with the KPI engine.
- `kaizen/profile-storage`: retired, every requirement removed with the profiles.
- `kaizen/run-state`: retired, every requirement removed with the run audit trail.

## Impact

- `kaizen/`: almost every file deleted or rewritten; new `hooks/hooks.json`, `hooks/stop-gate.sh`,
  `skills/kaizen/` (SKILL.md and 2 references). Target size about 365 lines.
- `tests/`: new `test-kaizen-stop-gate.sh` registered in `tests/ci/run-structural-tests.sh`; Layer 2
  `scenarios/kaizen-engine/` replaced by `scenarios/kaizen/`; PROFILE.md checks removed from
  `validate-plugin.sh` and `validate-references.sh` (kaizen was their only user).
- Docs: root `README.md` (plugin row, `npx skills` example), `CLAUDE.md` plugin list, `kaizen/README.md`.
- Users of 1.2.0: existing `.kaizen/runs/` folders are no longer read; 1.2.0 stays available from git
  history. First plugin in the marketplace to ship a hook.
