# Tasks

## 1. Scaffold and registration

- [x] 1.1 Create `personal-voice/.claude-plugin/plugin.json` (name, version 0.1.0, description, author, license, keywords) with a required `userConfig` field `store_dir` of type `directory`; verify with `claude plugin validate ./personal-voice --strict`
- [x] 1.2 Add the `personal-voice` entry to `.claude-plugin/marketplace.json` (category `documentation`, tags) and bump `metadata.version` 3.1.1 → 3.2.0; verify with `bash tests/validate-versions.sh`
- [x] 1.3 Create `personal-voice/README.md` with purpose, skills overview, the store directory setting and a privacy note (what the stores hold, personal material never in a project store); verify it names all three skills and the `store_dir` setting
- [x] 1.4 Add `personal-voice` to the root `README.md` plugin table, the `CONTRIBUTING.md` categories table and the `CLAUDE.md` repository-structure list; verify with `grep -n personal-voice README.md CONTRIBUTING.md CLAUDE.md`

## 2. Spike on Claude Code behavior

- [x] 2.1 In a scratch project with the plugin loaded through `--plugin-dir`, check that `${user_config.store_dir}` is substituted in skill content; record the result under Risks in `design.md`
- [x] 2.2 In the same setup, measure permission prompts when a skill writes to the store directory and to `.claude/voice/`, find the allow rule that removes them, and add it to the README; verify a second write in a new turn raises no prompt with the rule in place
- [x] 2.3 Check whether Claude is told about an external edit to a file it wrote in the session; record the result in `design.md` and adjust D2 and the file-edit risk if the notice is absent

## 3. Shared store format

- [x] 3.1 Write `personal-voice/shared/store-format.md`: global and project layouts, frontmatter of each file, rule and observation entry formats (language code, audience qualifier, evidence count, last-reinforced date, provenance), the ordered routing table, and anonymized examples; verify each voice-store scenario can be resolved from the file alone
- [x] 3.2 Add to the same file the project-store initialization text explaining the implications of versioning and the default local exclusion; verify it covers readers, history, git status noise, merge conflicts and client-name exposure

## 4. Write skill

- [x] 4.1 Write `personal-voice/skills/write/SKILL.md`: an intent-first description with examples in several languages and the exclusions, the sentinel (revisions and session end) within the first lines of the body, loading order and precedence, topic and audience resolution with one question when uncertain, exemplar language matching, promoted rules only, empty and unconfigured store behavior; verify with `bash tests/validate-plugin.sh` and `bash tests/validate-references.sh`, and that the body stays short enough to sit well inside the 5,000 tokens re-attached after compaction
- [x] 4.2 Add Layer 2 scenarios in `tests/scenarios/personal-voice-write/`: email draft applies the profile, commit message does not, uncertain topic asks, project glossary overrides a topic term, a revision after a draft starts learning, a session-end phrase starts the wrap-up; verify each scenario has setup, invocation, expected behavior and acceptance criteria
- [x] 4.3 Add the write skill's section to the plugin README (what it loads, how to invoke it, what it never touches); verify the section matches the SKILL.md behavior

## 5. Learn skill

- [x] 5.1 Write `personal-voice/skills/learn/SKILL.md` with `references/` for the revision procedure (draft required, authorship of each version, style separated from content), own-text learning with exemplar tagging, recording with evidence merging and the one-line notice, the maintenance suggestion thresholds, project-store initialization, and the session wrap-up; verify with `bash tests/validate-plugin.sh` and `bash tests/validate-references.sh`
- [x] 5.2 Add Layer 2 scenarios in `tests/scenarios/personal-voice-learn/`: spoken correction, edited file, final without a draft, proofreading the author's text records nothing, mixed content and style revision, bootstrap from own texts, repeated trait adds evidence, project-store initialization with the default and with a decline, wrap-up with pending work and with a missed revision; verify each scenario has acceptance criteria
- [x] 5.3 Add the learn skill's section to the plugin README (sources it learns from, what it never records, the notice); verify the section matches the SKILL.md behavior

## 6. Maintain skill

- [x] 6.1 Write `personal-voice/skills/maintain/SKILL.md` with `references/` for the numbered recap and per-item authorization, promotion, merging, conflicts, removal of generic rules, decay and expiry, size limits, scope moves, switching the project store's git choice, and recording the run date; verify with `bash tests/validate-plugin.sh` and `bash tests/validate-references.sh`
- [x] 6.2 Add Layer 2 scenarios in `tests/scenarios/personal-voice-maintain/` with a fixture store: recap before change, vague reply, promotion at two pieces of evidence, contradiction, generic rule, stale rule, promotion over the 50-rule limit, project rule that proves general, personal to versioned; verify each scenario has acceptance criteria and that the fixture uses only anonymized content
- [x] 6.3 Add the maintain skill's section to the plugin README (when it is suggested, what it proposes, that nothing changes without per-item approval); verify the section matches the SKILL.md behavior

## 7. Integration and close

- [x] 7.1 Run an end-to-end loop in a scratch project: draft with the write skill, revise, record observations, repeat the trait in a second text, wrap up, run maintenance and promote; verify the promoted rule appears in the right file and changes the next draft
- [x] 7.2 Run `claude plugin validate ./personal-voice --strict` and verify it passes
- [x] 7.3 Run `bash tests/ci/run-structural-tests.sh` and verify all suites pass
- [x] 7.4 Archive the change with `/opsx:archive` as the last commit before merge, and verify `openspec/specs/personal-voice/` holds the four capabilities
