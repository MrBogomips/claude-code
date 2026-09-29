# Design

## Context

The findings with file:line evidence are in the review notes kept outside the repository. This file
records the decisions taken where the findings left a choice. Motivation: see proposal.md, Why.

## Goals / Non-Goals

**Goals:**
- Every Critical, High and Medium finding is fixed, or its skip is recorded in tasks.md with a reason.
- SKILL.md and `references/` agree wherever both state a rule.
- Deterministic work that the model redid on every run moves into small bundled scripts, each with tests.

**Non-Goals:**
- No new plugins, hooks or state files beyond those named here.
- No eval or benchmark suites. Description optimization is a follow-up.
- Low findings stay out, except those that break a repository rule (generic usage, anonymization,
  SKILL.md↔references sync).

## Decisions

### D1. Retire developer-tools instead of hardening it

This is the owner's decision. The devcontainer skill needed a firewall redesign, and several of its
defaults (Docker socket, credential mounts, passwordless sudo) were unsafe. Git history keeps the plugin.

- Rejected: harden it (opt-in Docker-outside-of-Docker, sudoers-scoped firewall, credential opt-in).
  That is more work than the plugin's value to the marketplace justifies.

### D2. One absolute 1–5 scale for HR evaluation, with "Not assessed" (HR-05)

`interview-close/references/evaluation-template.md` §3 is the canonical scale. Its anchors are
absolute: 1 = no competence shown … 5 = sets direction for others. They match the seniority
matrix. Every other place that restated the scale now points to it.

A competency with no evidence is recorded as "Not assessed". It is left out of the weighted total,
the remaining weights are renormalized, and the confidence drops to Low.

- Rejected: keep the role-relative scale and make the matrix relative. That makes "seniority" a
  label that depends on the role being hired for.

### D3. Compliance severities are CRITICAL, WARNING and INFO (HR-06)

This is the three-level contract that compliance-check returns, and every caller uses it. The
4-level tables in the references are rewritten to match:

- CRITICAL: a direct breach of statute or GDPR. This includes a gendered title in an Italian ad and
  a candidate-facing form without a privacy notice.
- WARNING: a proxy, an indirect case, or one that depends on context.
- INFO: wording.

### D4. One ground-to-statute map (HR-10)

| Ground | Statute |
|---|---|
| Race and ethnic origin | D.Lgs. 215/2003 (Dir. 2000/43) |
| Religion or belief, disability, age, sexual orientation | D.Lgs. 216/2003 (Dir. 2000/78) |
| Sex and gender | D.Lgs. 198/2006 |
| Political opinion, trade-union membership | L. 300/1970 Art. 8 and Art. 15 |
| Nationality | D.Lgs. 286/1998 Art. 43 |
| Targeted disability hiring | L. 68/1999 |

EU Directive 2023/970 (pay transparency) is added with a note to check the current national
transposition. Legal content carries a "verify with counsel" note.

### D5. CV gaps are never a screen-out criterion

A gap may be raised only through one optional, open question. A protected reason the candidate
volunteers is not recorded. Salary is compared only with the band maximum, and availability only
with the hiring timeline (HR-21). The LinkedIn cross-check is removed (HR-22).

### D6. PlantUML generation is a bundled script; hand edits are detected with a header hash

- One script generates `.plantuml/` from the `## PlantUML Policy`. Bootstrap and migrate both call
  it, so migrate compares the files on disk with the script's output instead of with bytes the model
  regenerates.
- Each generated partial carries a `' generated-sha256: <hash-of-body>` header. A partial counts as
  hand-edited only when its body no longer matches its own header, so no extra state file is needed.
- The fallback target in `_base.puml` is the Policy's primary target.
- Every `-checkonly` passes `PLANTUML_TARGET` explicitly.
- Rejected: a separate state file of the last generated hashes. That adds state the lean-design
  preference avoids.

### D7. Skill-level model pins are removed

A `model:` pin without `context: fork` switches the main session model for the rest of the turn, so
a document skill that renders diagrams halfway through would finish on Haiku. Agents keep their pins,
because an agent pin affects only that agent. Where a skill is meant to be read-only, it uses
`disallowed-tools`, because `allowed-tools` pre-approves tools and never restricts them.

### D8. kaizen: safe commits, per-KPI epsilon, no measurer agent

- **Safe commits.** At BOOTSTRAP, `git status --porcelain -- <targets>` runs. If the tree is dirty,
  the engine asks the user to commit or stash, or to run without commits. It offers a
  `kaizen/<run-id>` branch.
- **VERIFY.** A failed profile check in VERIFY forces REVERT, recorded as `verify_failed`.
- **Epsilon.** `kpis[].epsilon` is optional, in the KPI's own units, and falls back to
  `convergence.epsilon`.
- **Persisted resolution.** The resolved `kpis` and `mutation_targets` are written to `manifest.json`,
  and context is rebuilt from the manifest.
- **Measurement.** The engine runs the measure script through Bash with a timeout and validates the
  JSON itself (K-25), which saves two dispatches per iteration.
- **Profile location.** Custom profiles default to `.kaizen/profiles/<name>/`, and the engine also
  searches `~/.kaizen/profiles/`.
- **Transcript KPIs** are observational: they are tracked but left out of DECIDE (K-26).

### D9. PERT figures come from a bundled summarizer, not from the workbook

openpyxl writes formula strings without cached values. `scripts/summarize.py` computes the same
figures from `excel-input.json`, using the helpers' formulas, and checks the formula patterns
statically. The Phase 6 checks, the final statistics and the sow-estimate backfill all use its
output.

- Rejected: recalculate the workbook with LibreOffice. It is not assumed to be installed. It can be
  used optionally when it is found at runtime.

### D10. Risk threshold P×I ≥ 10 everywhere (PM-29)

The workbook formula and the methodology already use 10, so the SOW files are aligned to them.

## Risks / Trade-offs

- **HR anchors and severity names change.** Evaluations written before the change are not comparable
  number for number. The change is noted in the plugin README.
- **Legal corrections.** These come from reviewer analysis, not from counsel, so the files say to
  verify them.
- **Existing PlantUML projects.** Their partials have no hash header. Migrate treats a partial
  without a header as needing one confirmation, then regenerates it with a header.
