# Proposal

## Why

A skill review on 2026-09-29 covered all 28 skills of the marketplace. It complements the 2026-09-28
prompt audit, whose fixes were merged in PR #19. The review found one Critical issue and 26 High
issues in what the skills do. None of them shows up in the structural suite, which passes:

- **Safety, legal and privacy.** Among the findings:
  - a devcontainer firewall that can be bypassed;
  - HR skills that screen out candidates on CV gaps, cite the wrong statutes and miss the EU Pay
    Transparency Directive;
  - a real public body in an example;
  - kaizen commits that pick up the user's uncommitted edits;
  - a client-facing leak scan that misses `MD` and `EUR`.
- **Core behavior that cannot work as written:**
  - PlantUML diagrams outside the project root, or in projects without a `web` target, fail to
    validate, and migrate treats every Policy change as a manual edit.
  - The PERT checks read computed values that openpyxl never writes.
  - kaizen applies one epsilon to KPIs in different units.
  - interview-close mixes a role-relative scale with an absolute seniority matrix.
- **Frontmatter semantics:**
  - A skill-level `model:` pin switches the main session model for the rest of the turn.
  - A backgrounded `context: fork` skill cannot ask the user anything.
  - `allowed-tools` pre-approves tools; it never restricts them.

The owner also decided to retire the developer-tools plugin rather than harden it.

## What Changes

- **Retire developer-tools.** Remove the plugin directory, its marketplace entry and its mentions
  in `README.md`, `CONTRIBUTING.md` and `CLAUDE.md`. **BREAKING** for installs of `developer-tools`
  from this marketplace.
- **plantuml:**
  - Include paths are written relative to each diagram's own directory.
  - Every `-checkonly` passes an explicit `PLANTUML_TARGET`, and the fallback target is the
    Policy's primary target.
  - One bundled generator produces `.plantuml/` from the Policy, and both bootstrap and migrate
    use it.
  - Each generated partial carries its own content hash in a header, which is how hand edits are
    detected.
  - The renderer resolves includes the same way at every level, and a failing file never becomes
    a passing baseline.
  - Policy values that were collected but never applied (layout engine, base font size, max
    width) now take effect.
  - Brand colors are required only for a custom theme.
  - The skill-level model pins are removed.
- **kaizen:**
  - A run on a dirty tree asks before any commit, and a failed profile check in VERIFY forces
    REVERT.
  - Each KPI may set its own epsilon, in the KPI's own units.
  - Resolved KPIs and mutation targets are persisted in the manifest.
  - Custom profiles live in `.kaizen/profiles/`.
  - The measurer agent is dropped: the engine runs the measure script itself.
  - Transcript KPIs are observational.
  - Every reverted proposal is passed to the proposer.
- **project-management:**
  - A bundled `summarize.py` computes the workbook figures and runs the checks.
  - The input schema is documented in full.
  - Subagents return drafts and questions instead of holding a dialogue.
  - pmo-pert-estimate accepts the handoff from sow-estimate.
  - High risk means P×I ≥ 10 everywhere.
  - `openpyxl` is checked before use.
  - Outputs are versioned, never overwritten.
  - Examples are anonymized.
- **human-resources:**
  - CV gaps are never a screen-out criterion.
  - One absolute 1–5 scale is used everywhere, with a "Not assessed" status.
  - Severity levels are CRITICAL/WARNING/INFO everywhere.
  - Statute citations follow one ground-to-statute map, and pay transparency is covered.
  - Each interviewer writes their own evaluation.
  - Compliance runs last.
  - Candidate files carry a confidentiality and retention header.
- **tech-writing:**
  - The leak scan uses a pattern file covering `MD`, `giornate/uomo`, `EUR` and FTE, and matches
    labels rather than adjectives.
  - The AI rule matches the taxonomy.
  - Audit files are versioned.
- **context-hygiene:**
  - After a "no" to BACKUP, only memory items named individually are applied.
  - "apply all" is part of the hard rule.
  - The mechanical checks use Glob and Grep.
- **personal-voice:**
  - The project root is found with `git rev-parse`.
  - Exemplars never carry client or project names.
  - maintain specifies the CONFLICT and scope-to-project outcomes and remembers kept stale rules.
  - write defers to other skills' structure and templates.
- **Repository:**
  - `validate-connectors.sh` also scans `profiles/` and `commands/`.
  - CI runs the PERT pytest suite and the executable PlantUML smoke tests.
  - `CLAUDE.md` records the frontmatter semantics above.

## Capabilities

### New Capabilities

- `plantuml/policy-generation`, `plantuml/policy-migration`, `plantuml/diagram-authoring`,
  `plantuml/diagram-validation`, `plantuml/diagram-lint`, `plantuml/skill-invocation`
- `kaizen/iteration-safety`, `kaizen/kpi-ratchet`, `kaizen/measurement`, `kaizen/profile-storage`,
  `kaizen/run-state`
- `project-management/pert-workbook-verification`, `project-management/pert-interaction`,
  `project-management/sow-pert-handoff`, `project-management/risk-classification`,
  `project-management/estimate-outputs`, `project-management/sow-review-report`,
  `project-management/document-input`
- `human-resources/candidate-screening`, `human-resources/evaluation-scoring`,
  `human-resources/compliance-contract`, `human-resources/legal-references`,
  `human-resources/candidate-data-handling`, `human-resources/skill-routing`
- `tech-writing/confidential-leak-scan`, `tech-writing/bid-commercial-clarifications`,
  `tech-writing/skill-routing`
- `context-hygiene/discovery-checks`

### Modified Capabilities

- `context-hygiene/authorization` and `context-hygiene/apply-safety`: new requirements for "apply all" and
  for memory items when BACKUP is declined (ADDED; no existing requirement text changes).
- `personal-voice/voice-learning`, `personal-voice/voice-maintenance`, `personal-voice/voice-store`,
  `personal-voice/voice-writing`: requirements changed for exemplars, conflicts, decay, scope moves, the
  project root and precedence of other skills (MODIFIED, plus ADDED where new).

## Impact

- **Plugins** (bump in `plugin.json` and the `marketplace.json` entry):

  | Plugin | Bump |
  |---|---|
  | context-hygiene | 0.2.0 → 0.3.0 |
  | human-resources | 0.2.1 → 0.3.0 |
  | kaizen | 1.1.0 → 1.2.0 |
  | personal-voice | 0.1.0 → 0.2.0 |
  | plantuml | 1.0.1 → 1.1.0 |
  | project-management | 1.0.1 → 1.1.0 |
  | tech-writing | 0.2.1 → 0.3.0 |

  All are minor bumps: behavior changes compatible with existing inputs.
- **Marketplace:** `metadata.version` 3.2.1 → 4.0.0, because a plugin is removed.
- **Users:**
  - HR outputs change their scale anchors and severity names.
  - kaizen custom profiles saved inside the plugin directory must be moved to
    `.kaizen/profiles/`, where they now survive plugin updates.
  - PlantUML projects regenerate `.plantuml/` once through migrate to get the hash headers.
- **Legal:** the HR legal content is corrected from reviewer analysis. It still needs a review by
  counsel before it is relied on.
