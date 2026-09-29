# Tasks

## 1. Skill and references

- [x] 1.1 In `context-hygiene/skills/context-hygiene/SKILL.md`, limit Classify step 4 to COMPRESS, POINTER, MERGE and REMOVE (D1); verify with `grep -n "rationale-risk" context-hygiene/skills/context-hygiene/SKILL.md context-hygiene/skills/context-hygiene/references/retention-recap.md` that both files name the same four verbs
- [x] 1.2 In the same file, reword the Authorization mixed-reply sentence so it fires only on vague approval of unnamed items (D2); verify the text still lets "yes, do 1 and 3" authorize exactly {1, 3}
- [x] 1.3 Add the mixed-reply rule to `references/safety.md` §Authorization and the moved/deleted check to §Apply safety (D3); verify every rule in `SKILL.md` §5 and §6 has a matching line in `safety.md`
- [x] 1.4 Add Layer 2 cases to `tests/scenarios/context-hygiene/scenario-authorization.md` (mixed reply with a vague rest, target deleted before apply) and a variant to `scenario-dry-run.md` (reference file missing, EDIT next to a rationale not tagged); verify each case has acceptance checkboxes and that existing case 5 is unchanged

## 2. Version and release

- [x] 2.1 Bump `context-hygiene` 0.1.0 → 0.2.0 in `plugin.json` and its `marketplace.json` entry, and `metadata.version` 3.2.0 → 3.2.1; verify with `bash tests/validate-versions.sh`
- [x] 2.2 Run `bash tests/ci/run-structural-tests.sh` and `claude plugin validate ./context-hygiene --strict`; verify both pass
- [ ] 2.3 Archive this change with `/opsx:archive` as the last commit before merge; verify `openspec/specs/context-hygiene/` holds the three capabilities
