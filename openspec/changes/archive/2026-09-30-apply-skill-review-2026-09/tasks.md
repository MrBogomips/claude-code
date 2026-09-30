# Tasks

## 0. Retirement

- [x] 0.1 Remove `developer-tools/`, its `marketplace.json` entry and its mentions in README, CONTRIBUTING and CLAUDE.md (D1); set `metadata.version` to 4.0.0; verify with `grep -rn 'developer-tools\|devcontainer' --exclude-dir=.git --exclude-dir=openspec .` returning only the README "Retired" note

## 1. plantuml

- [x] 1.1 Bundle plantuml-bootstrap/scripts/generate-config.sh (generate/verify/policy, a generated-sha256 header on each file, the primary target as the _base.puml fallback); verify with bash plantuml/tests/smoke/test-generate-config.sh
- [x] 1.2 Make every Policy value take effect: layout pragma, $direction + $apply_direction() (no global left-to-right), fonts after the theme, target font sizes from the base size, brand colors only for Theme custom (P-33), docx max width read from the Policy (P-34); verify with test-generate-config.sh and test-checkonly-nested.sh
- [x] 1.3 Write !include paths relative to the diagram's directory in plantuml-authoring and every diagrams/*.md snippet; add nested fixtures; verify with test-snippets.sh and test-checkonly-nested.sh
- [x] 1.4 Pass PLANTUML_TARGET explicitly at every -checkonly (authoring, review, bootstrap, migrate, validate, convert) and rewrite render-profiles.md (P-32); verify with test-review.sh, test-bootstrap.sh and test-checkonly-nested.sh
- [x] 1.5 Rebuild plantuml-migrate on the generator (temp-dir diff, header-hash hand-edit detection, one confirmation for header-less files, backup first); remove Step 6 and puml-migrator; route bootstrap regenerate to migrate; verify with test-migrate.sh and test-generate-config.sh
- [x] 1.6 Replace puml-renderer with plantuml-validate/scripts/validate-matrix.sh (renders from the file at every level, exit ≠ 0 = fail/error, no checkonly baselines, version-free SVG hash) and run the visual check before bless writes baselines (P-37); verify with test-validate-matrix.sh and test-validate.sh
- [x] 1.7 plantuml-lint: .iuml out of the default scope and exempt from R1/R3/R4/R5; add R6 (include targets exist); verify with test-lint.sh
- [x] 1.8 Remove skill model pins (advisor, review, convert); disallowed-tools Write, Edit on advisor and review; mutual "Not for" lines; quote convert compatibility; brew/apt text (P-36); drop "~10% perceptual" (P-35); verify with test-frontmatter.sh, test-advisor.sh and test-review.sh
- [x] 1.9 Generic usage: generate-variants.sh run root from PLANTUML_TEST_ROOT/TMPDIR, seed-variants.sh writes no absolute paths, delete the duplicate plantuml/docs/policy-schema.md; verify with grep -rnE '/Users/|HOME/temp' plantuml/
- [x] 1.10 Write the plantuml spec deltas; verify with openspec validate apply-skill-review-2026-09 --strict
- [x] 1.11 Visual check gets primary_color only for Theme custom (null otherwise), same wording in plantuml-validate and puml-visual-checker; verify with bash plantuml/tests/smoke/test-validate.sh
- [x] 1.12 generate-config.sh verify --against: after promote-to-policy a file whose body equals the newly generated body is ok and regenerated without asking again; plantuml-migrate uses it; verify with test-generate-config.sh and test-migrate.sh
- [x] 1.13 generate-config.sh reads a CLAUDE.md with CRLF line endings (same Policy, same bytes); verify with test-generate-config.sh

## 2. kaizen

- [x] 2.1 Git check at BOOTSTRAP (dirty targets → commit/stash or run without commits, stage nothing before the answer, offer `kaizen/<run-id>`) and pre-APPLY check so KEEP commits only the iteration's edits; verify with tests/scenarios/kaizen-engine/scenario-dirty-tree.md and scenario-keep.md
- [x] 2.2 VERIFY checks resolved at BOOTSTRAP (kept only if they pass on the baseline); a failed check forces REVERT with `verify_failed`; code-refactoring BOOTSTRAP section for build/test/lint; verify with tests/scenarios/kaizen-engine/scenario-verify-failed.md
- [x] 2.3 Per-KPI `epsilon` (own unit, fallback `convergence.epsilon`) and `observational` flag; greedy precedence fixed; template, checklist, ratchet-strategies.md and bundled profiles updated; verify with tests/scenarios/kaizen-engine/scenario-keep.md and scenario-revert.md
- [x] 2.4 Resolved kpis, mutation_targets, verify_checks and git choices persisted in manifest.json; context rebuilt from it; Step 1 reads the profile BOOTSTRAP section, Step 1e the MEASURE section and its profile-relative references; schemas in references/run-state.md; verify with `openspec validate apply-skill-review-2026-09 --strict`
- [x] 2.5 Custom profiles default to `.kaizen/profiles/<name>/`; engine search order `.kaizen/profiles/` → `~/.kaizen/profiles/` → bundled; designer checks for an existing name and uses the engine's five source types; verify with scenario-keep.md check 1
- [x] 2.6 K-25: kaizen-measurer removed; engine runs the measure script via Bash (60 s timeout) and validates the JSON; verify with `grep -rn kaizen-measurer kaizen tests` (no output)
- [x] 2.7 K-21: every reverted or rejected proposal (`summary.json` → `reverted_proposals`) and the user's rejection note go to the proposer; verify with `grep -n reverted_proposals kaizen/skills/kaizen-engine/references/subagent-dispatch.md`
- [x] 2.8 K-26/K-27/K-28/K-29: transcript KPIs observational; transcript and memory paths scoped to `~/.claude/projects/<project>/`; `permissions.allow`, `.mcp.json` / `claude mcp add`, `--dangerously-skip-permissions`; Grep/Glob default-toolset note; model-tier advice and named rule files removed (verified on code.claude.com); verify with `grep -rnE 'allowedTools"|sessions/|dangerouslySkip' kaizen/profiles` (no output)
- [x] 2.9 K-30: orphaned loop-protocol.md deleted, its two unique rows moved into SKILL.md §6; verify with `grep -rn loop-protocol kaizen` (no output)
- [x] 2.10 Mediums: fresh baseline with `previous_final` and measure-script reuse; rejected proposal → `no_proposal` + `user_note`; ESCALATE recorded as keep/revert; resume of an open run; final review gets the run directory and kept iterations; README compaction claim corrected; verify with `openspec validate apply-skill-review-2026-09 --strict`
- [x] 2.11 Connectors: unused `~~memory` removed; `~~sequential-thinking` kept (referenced); verify with `bash tests/validate-connectors.sh`
- [x] 2.12 Layer 2 scenarios in tests/scenarios/kaizen-engine/ (fixture.sh with default, strict-epsilon and failing-check variants plus `interrupt`; 5 scenarios); verify with `bash tests/scenarios/kaizen-engine/fixture.sh create <tmp> <variant>` for each variant and `fixture.sh interrupt <tmp> project|user`
- [x] 2.13 kaizen spec deltas (iteration-safety, kpi-ratchet, measurement, profile-storage, run-state); verify with `openspec validate apply-skill-review-2026-09 --strict`
- [x] 2.14 Resume of an iteration interrupted during APPLY restores `backup/` and deletes the `created.txt` files before APPLY runs again (also when the resume is declined); APPLY never overwrites an existing backup copy; the pre-APPLY dirty list is persisted in `dirty-before-apply.txt`; verify with tests/scenarios/kaizen-engine/scenario-resume.md cases 1, 2 and 4
- [x] 2.15 Storage root (`.kaizen/` or `~/.kaizen/`) settled in Step 1a before any run file is written and recorded as `storage_root`; open runs searched in both roots; process-improvement's BOOTSTRAP no longer picks the location; verify with tests/scenarios/kaizen-engine/scenario-resume.md case 3 and `openspec validate apply-skill-review-2026-09 --strict`

## 3. project-management

- [x] 3.1 Anonymize the examples and fixtures (scenario 2 client and contract ID, scenario 5 client, integration sample brief codename/client/places, sample contract parties/sites/people/contract ID); verify with a grep over project-management and tests/scenarios for the removed names returning nothing
- [x] 3.2 Bundle scripts/summarize.py (figures, input validation, static workbook checks, optional LibreOffice recalc) with tests written first; verify with `python3 -m pytest -q project-management/skills/pmo-pert-estimate/scripts`
- [x] 3.3 Take Phase 6 checks, final statistics and the sow-estimate backfill from summary.json; verify with tests/scenarios/sow-estimate/scenario-backfill-economics.md
- [x] 3.4 Document the full input schema in excel-schema.md, point SKILL.md to examples/sample-input.json, drop unread keys from the instructions and the examples; verify with scripts/tests/test_examples.py
- [x] 3.5 Make agents return drafts plus open questions, run checkpoints in the skill, dispatch the Level A WBS builder per project phase, limit the roles builder to roles/teams/billable; verify with a read of pmo-pert-estimate SKILL.md §5 and §7
- [x] 3.6 Add the sow-estimate entry branch to pmo-pert-estimate Phase 1 and fix the allocation/rate drift in extraction-rules.md; verify with tests/scenarios/sow-estimate/scenario-extract-and-bridge.md
- [x] 3.7 Use P×I ≥ 10 as the high-risk threshold everywhere, including the Risks-sheet red font; verify with test_wb_risks.py::TestFormatting::test_red_font_threshold_is_ten and a grep for ">= 12" returning nothing
- [x] 3.8 Check python3/openpyxl in Phase 0 and ask before installing (PM-27), declare it in the README; verify with a read of SKILL.md Phase 0b
- [x] 3.9 Cut workflow.md to Phase 2 (PM-26), rewrite the pmo-pert-estimate description (PM-30), version outputs and drop the validation-summary narrative (PM-31); verify with bash tests/validate-references.sh
- [x] 3.10 Restate the 8/80 rule in PD per activity, fix the sample, align the σ-rollup and band teaching with the workbook; verify with test_examples.py::test_sample_respects_8_80_rule
- [x] 3.11 Use one configuration section with OutputDir/WorkspaceDir, one estimate folder per estimate with backup on start over, versioned never-overwritten outputs, sow-write's input analysis in the working folder; verify with tests/scenarios/integration/test-pipeline.md
- [x] 3.12 Add the optional ~~document converter for DOCX inputs and remove the ~~category orphan; verify with bash tests/validate-connectors.sh
- [x] 3.13 Narrow the sow-write description, use half-open sow-review grade bands and the SOW's language in the report; verify with tests/scenarios/sow-write/scenario-triggering.md, sow-review/scenario-full-review.md and integration/test-language.md Test D
- [x] 3.14 Write the project-management spec deltas; verify with `openspec validate apply-skill-review-2026-09 --strict`
- [x] 3.15 Reject a null `management_reserve_pct` with exit 1 and a clear message; verify with test_summarize.py::TestCli::test_null_management_reserve_exits_1

## 4. human-resources

- [x] 4.1 Add compliance-check/references/legal-map.md as the single ground-to-statute map (215/2003, 216/2003, 198/2006, L. 300/1970 Art. 8/15, D.Lgs. 286/1998 Art. 43, L. 68/1999), fix the GOR citation to Art. 3(3) and the 196/2003 Art. 113 and 276/2003 Art. 10 descriptions, and point the other files to it; verify with `grep -rn '215/2003' human-resources | grep -iE 'relig|disab|\bage\b|orient'` returning nothing
- [x] 4.2 Add Directive 2023/970 (pay-history CRITICAL, missing pay range WARNING in the EU), the AI-screening note, the privacy-notice AI line and a "verify with counsel" note in every legal reference; verify with `grep -rln '2023/970' human-resources` and `grep -rl 'Not legal advice' human-resources/skills/compliance-check/references`
- [x] 4.3 Rewrite the three 4-level severity tables to CRITICAL/WARNING/INFO; verify with `grep -rnE '\| *(HIGH|MEDIUM|LOW) *\|' human-resources` returning nothing
- [x] 4.4 Make CV gaps never a screen-out criterion (pre-screening, interview-prep, star-method, prohibited-topics proxy); verify with `grep -rni 'screen out' human-resources` matching only the prohibitions and with tests/scenarios/hr-pre-screening/scenario-cv-gap.md
- [x] 4.5 Make evaluation-template.md §3 the canonical absolute 1–5 scale with Not assessed, renormalized weights, target-level recommendation rules and required computation tables, and point every other copy to it; verify with tests/scenarios/hr-interview-close/scenario-not-assessed.md
- [x] 4.6 Write one evaluation per interviewer with optional consolidation, collect the JD, save and reuse {role}-seniority-matrix.md, add the candidate-data header, folder-outside-git and no-memory rules; verify with tests/scenarios/hr-interview-close/scenario-panel.md
- [x] 4.7 Run compliance-check last in every caller via Skill args `embedded <document_type>`, adding position_assessment and other; verify with `grep -rn 'embedded ' human-resources/skills/*/SKILL.md`
- [x] 4.8 pre-screening: salary vs band maximum, availability vs timeline, CCNL never Red, no LinkedIn cross-check, role-level base set, separate recruiter guide, privacy line, human-oversight note; verify with tests/scenarios/hr-pre-screening/scenario-salary-band.md and scenario-base-set.md
- [x] 4.9 Add the Italian bias lexicon rows with severity, fix the Italian accents, drop the .md/.docx question, make the 8-requirement count a rule of thumb, route JD revision to compliance-check, and fix the hr-help triggers, exclusion and language rule; verify with tests/scenarios/hr-compliance-check/scenario-italian-jd-lexicon.md
- [x] 4.10 Front-load all six HR descriptions (≤600 chars, valid YAML), fix the orphan ~~category and add ~~document converter; verify with `bash tests/validate-connectors.sh` and a PyYAML parse of the frontmatter
- [x] 4.11 Anonymize star-method (Provider A/B/C) and the METHODOLOGY examples; verify with `grep -rniE 'stripe|adyen|paypal|rossi' human-resources` returning nothing
- [x] 4.12 Write the human-resources spec deltas; verify with `openspec validate apply-skill-review-2026-09 --strict`

## 5. tech-writing

- [x] 5.1 Leak scan: residual patterns in client-facing-doc/references/residual-patterns.md (14 REMOVE rows incl. MD/PD/gg/gg/uu/giornate/uomo, FTE, hours stated as effort, EUR/euro/USD/k€; 6 REVIEW rows incl. estimated durations) run with Grep on a working-docs draft, which is copied to the deliverables folder only when no REMOVE row matches; labels only, adjective and technical uses judged as REVIEW hits (REVIEW NEEDED); taxonomy and preserve-checklist reconciled; AI rule aligned with the taxonomy in Step 5, Self-Check 2 and the style guide; audit `<doc-name>-client-v<N>-redaction-audit.md`; duplicate `riservato` removed; verify with `bash tests/scenarios/client-facing-doc/check-deliverable.sh tests/scenarios/client-facing-doc/fixture-internal-assessment.md` (reports every planted marker) and tests/scenarios/client-facing-doc/scenario-leak-scan.md
- [x] 5.2 bid-delivery-summary: unapproved price in the source → verbatim Commercial Clarifications item without figures (en/it); Self-Check 1 accepts the language pack's notice; cost-authorized mode records the cost model and who authorized it; verify with tests/scenarios/bid-delivery-summary/scenario-unapproved-price.md
- [x] 5.3 Front-load both descriptions (575 and 610 chars); structure and style guide win over a personal writing-voice skill (descriptions, Step 5 bodies, style guide); CONNECTORS.md intro reworded so `~~category` is no longer parsed as an entry; verify with `bash tests/validate-connectors.sh` (no tech-writing warning) and a PyYAML parse of the frontmatter
- [x] 5.4 Add tests/scenarios/client-facing-doc/ (README, fixture, check-deliverable.sh, scenario-leak-scan.md) and tests/scenarios/bid-delivery-summary/ (README, 2 fixtures, scenario-unapproved-price.md), and the tech-writing spec deltas; verify with `bash -n tests/scenarios/client-facing-doc/check-deliverable.sh` and `openspec validate apply-skill-review-2026-09 --strict`

## 6. context-hygiene

- [x] 6.1 After an explicit "no" to BACKUP, apply only memory items named by number, the rest "Awaiting individual approval" (SKILL.md hard rule 3 and §6, safety.md, retention-recap.md, README); hard rule 1 names the literal "apply all"; scenario cases 4b and 11; verify with tests/scenarios/context-hygiene/scenario-authorization.md cases 4, 4b and 11
- [x] 6.2 references/checks.md uses Read/Glob/Grep and the pre-approved git/wc/ls commands only; CTR-10 row "Two signals, a CLAUDE.md declaration, or ask"; CTR-16 limits verified in the official memory docs on 2026-09-30 (MEMORY.md 200 lines or 25KB; CLAUDE.md up to 4 MiB; subdirectory CLAUDE.md and paths-scoped rules on demand) with a 20,000-byte MEMORY.md check; verify with `grep -nE '\bfind |test -e|test -d|\| *(grep|tr|sed)|\bsed ' context-hygiene/skills/context-hygiene/references/checks.md` (no output) and tests/scenarios/context-hygiene/scenario-dry-run.md
- [x] 6.3 ADDED deltas for context-hygiene/authorization ("apply all") and context-hygiene/apply-safety (no backup → only memory items named by number), new context-hygiene/discovery-checks; verify with `openspec validate apply-skill-review-2026-09 --strict`

## 7. personal-voice

- [x] 7.1 Project root from `git rev-parse --show-toplevel` (allowed-tools `Bash(git rev-parse:*)` in write, learn, maintain; same rule in store-format and recording.md); "a slug present in `content-types/`"; write defers to other skills' and templates' structure, register and terms; verify with tests/scenarios/personal-voice-learn/scenario-subdirectory.md and a PyYAML parse of the frontmatter
- [x] 7.2 learn: exemplars without client or project names, none when no passage qualifies; description states what the skill records and limits revisions to text for people; verify with tests/scenarios/personal-voice-learn/scenario-exemplar-privacy.md
- [x] 7.3 maintain: CONFLICT outcomes (keep A, keep B, rule vs rule, qualify) in apply.md; scope to project only when every source carries the current project root's absolute path and the observation reinforces nothing, otherwise a note; project tags only in the global store, dropped on a move into a project store; `reviewed:` date with the stale cutoff on max(reinforced, reviewed); "all" in hard rule 2; unset-store test worded once; exclude file from `git rev-parse --git-path info/exclude`; verify with tests/scenarios/personal-voice-maintain/scenario-conflict-keep-b.md, scenario-scope-to-project.md and scenario-stale-kept.md
- [x] 7.4 trigger.sh `--marketplace` / `PV_TRIGGER_MARKETPLACE=1` loads every plugin; scenario-triggering.md run counts fixed (2 per prompt) plus a collision table; personal-voice spec deltas; verify with `bash -n tests/scenarios/personal-voice-write/trigger.sh` and `openspec validate apply-skill-review-2026-09 --strict`

## 8. Repository

- [x] 8.1 `tests/validate-connectors.sh` scans skills, agents, commands and profiles, and matches hyphenated placeholders; verify with `bash tests/validate-connectors.sh`
- [x] 8.2 `tests/validate-references.sh` resolves `${CLAUDE_PLUGIN_ROOT}/…` paths against the plugin root; verify with `bash tests/validate-references.sh`
- [x] 8.3 CI runs the PERT pytest suite and the plantuml smoke tests (`.github/workflows/validate-marketplace.yml` jobs `pert-tests` and `plantuml-smoke`); verify with a YAML parse of the workflow and a local run of both commands
- [x] 8.4 CLAUDE.md records the skill frontmatter semantics (allowed-tools vs disallowed-tools, model pins, context: fork, disable-model-invocation, quoting, upload-compatible fields); verify with a read of CLAUDE.md "Plugin conventions"
- [x] 8.5 Bump plantuml 1.1.0, kaizen 1.2.0, project-management 1.1.0, human-resources 0.3.0 in plugin.json and marketplace.json; verify with `bash tests/validate-versions.sh`
- [x] 8.6 Bump tech-writing 0.3.0, context-hygiene 0.3.0 and personal-voice 0.2.0; verify with `bash tests/validate-versions.sh`
- [x] 8.7 Run `bash tests/ci/run-structural-tests.sh` and `claude plugin validate ./<plugin> --strict` for every plugin; verify both pass
- [x] 8.8 Archive this change with `/opsx:archive` as the last commit before merge; verify with `openspec validate --all --strict`
