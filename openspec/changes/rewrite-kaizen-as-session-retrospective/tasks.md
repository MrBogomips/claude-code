# Tasks

## 1. Remove the 1.2.0 engine

- [x] 1.1 `git rm` `kaizen/commands/`, `kaizen/profiles/`, `kaizen/CONNECTORS.md`, skills `kaizen-engine`, `kaizen-profile-designer`, `kaizen-report`, agents `kaizen-analyzer`, `kaizen-proposer`, and `tests/scenarios/kaizen-engine/`; verify `find kaizen -type f` lists only `plugin.json`, `README.md` and `agents/kaizen-reviewer/AGENT.md`
- [x] 1.2 Remove the PROFILE.md checks from `tests/validate-plugin.sh` and `tests/validate-references.sh`, and `profiles` from the component list of `tests/validate-connectors.sh` (kaizen was their only user); verify `grep -n -i profile tests/validate-*.sh` returns nothing and `bash tests/validate-plugin.sh` passes for the other plugins

## 2. Session gate hook (`kaizen/session-gate`)

- [x] 2.1 Write `tests/test-kaizen-stop-gate.sh` with temp-dir fixtures covering every scenario of `specs/kaizen/session-gate/spec.md` plus decoy keys, `session_id` path traversal, marker pruning and a missing `CLAUDE_PLUGIN_DATA`; verify it fails because the hook is missing
- [x] 2.2 Write `kaizen/hooks/stop-gate.sh` (bash 3.2/BSD, grep only, always exit 0, D8, D9) and `kaizen/hooks/hooks.json` (Stop → `bash "${CLAUDE_PLUGIN_ROOT}/hooks/stop-gate.sh"`, timeout 10); verify `bash tests/test-kaizen-stop-gate.sh` passes
- [x] 2.3 Register the hook test in `tests/ci/run-structural-tests.sh` and list it in `tests/README.md`; verify `bash tests/ci/run-structural-tests.sh` runs it

## 3. Retrospective skill and reviewer (`kaizen/asset-attribution`, `kaizen/proposal-apply`)

- [x] 3.1 Write `kaizen/skills/kaizen/references/assets.md` (origin table with owner routes, evidence patterns, incident → asset table, owned-elsewhere pointers) and `references/proposals.md` (item format, reviewer checklist and output, recap, authorization, apply, report); verify every requirement of both specs maps to a line in one of them or in SKILL.md
- [x] 3.2 Write `kaizen/skills/kaizen/SKILL.md` (about 100 lines: hard rules D1–D6, steps 1–8, red flags); verify `bash tests/validate-references.sh` resolves its references and the description quotes values containing `: `
- [x] 3.3 Rewrite `kaizen/agents/kaizen-reviewer/AGENT.md` (about 15 lines, `tools: Read, Grep, Glob`, no model pin, judges only after-text); verify `bash tests/validate-plugin.sh` passes
- [x] 3.4 Write Layer 2 `tests/scenarios/kaizen/` (README, `fixture.sh create|fingerprint`, `scenario-recap.md`, `scenario-authorization.md`, `scenario-review.md`, `scenario-zero-findings.md`) in the context-hygiene format; verify each scenario has acceptance checkboxes tied to a spec scenario and run the recap and authorization scenarios once by hand

## 4. Version and documentation

- [x] 4.1 Rewrite `kaizen/README.md` (about 50 lines: what it does and does not do, hook signals and thresholds, `KAIZEN_STOP_HOOK=0`, install without the plugin); verify `bash tests/validate-references.sh` reports no broken links
- [x] 4.2 Bump kaizen 1.2.0 → 2.0.0 in `plugin.json` (description, keywords) and its `marketplace.json` entry (description, tags), and `metadata.version` 4.0.0 → 4.0.1; verify with `bash tests/validate-versions.sh`
- [x] 4.3 Update the kaizen row and the `npx skills` example (`--skill kaizen`) in the root `README.md`, and the `kaizen/` line in `CLAUDE.md`; verify `grep -rn "kaizen-engine" README.md CLAUDE.md` returns nothing

## 5. Integration

- [x] 5.1 Review the diff with a code-review subagent (contradictions, minimization, repository conventions) and fix CRITICAL and HIGH findings; verify the re-review reports none
- [x] 5.2 Run `bash tests/ci/run-structural-tests.sh` and `claude plugin validate ./kaizen --strict`; verify both pass
- [ ] 5.3 Archive this change with `/opsx:archive` as the last commit before merge; verify `openspec/specs/kaizen/` holds only `session-gate`, `asset-attribution` and `proposal-apply`
