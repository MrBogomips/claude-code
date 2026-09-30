# Integration Test: Write → Estimate → Review Pipeline

## Objective
Verify that the three SOW skills work together as a pipeline, with outputs from one skill feeding correctly into the next.

## Input
`sample-brief.md` (fictional Acme property management platform brief)

## Setup
The project's CLAUDE.md has `## project-management Configuration` with `OutputDir` set (e.g. `docs/outbox/`) and either `WorkspaceDir` or a declared working-documents folder. Python 3 and openpyxl are installed.

## Test Steps

### Step 1: SOW Write
**Invoke**: `sow-write` in full mode with the sample brief

**Verify**:
- [ ] 15-section SOW produced
- [ ] Section 10 (Economics) has sow-estimate placeholder
- [ ] Section 6 (Phase Breakdown) has 3 phases matching the brief
- [ ] Section 8 (Collaboration Model) has team from brief
- [ ] Section 11 (Risk Management) includes data migration and GDPR risks; every risk with P×I ≥ 10 has a mitigation
- [ ] Language: English (brief is in English)
- [ ] Saved to `<OutputDir>/acme-property-sow-v0.1.0.md`; `input-analysis.md` is in the working folder, not in `OutputDir`

### Step 2: SOW Estimate
**Invoke**: `sow-estimate` on the SOW from Step 1

**Verify**:
- [ ] WBS extracted: 3 Level-1 phases, decomposed into work packages
- [ ] Roles extracted: matches Section 8 team composition
- [ ] Risks extracted: matches Section 11 risk register
- [ ] Handoff written to `<WorkspaceDir>/pert-acme-property/sow-extraction.md`
- [ ] pmo-pert-estimate starts from the handoff: it asks only for the interaction level, not for the input documents or targets again, and does not offer to start over in that folder
- [ ] pmo-pert-estimate Phase 0 checked for openpyxl before Phase 1
- [ ] `summarize.py --workbook` exits 0; `summary.json` is in the estimate folder
- [ ] PERT workbook written to `<OutputDir>/acme-property-pert-v1.xlsx`
- [ ] SOW Economics section (10) backfilled with the figures in `summary.json` (per-phase PERT effort, Low / Medium / High Band)
- [ ] SOW Schedule section (9) uses `calendar_weeks`
- [ ] Updated SOW saved as a new file `acme-property-sow-v0.2.0.md`; `-v0.1.0.md` unchanged

### Step 3: SOW Review
**Invoke**: `sow-review` on the updated SOW from Step 2

**Verify**:
- [ ] Scorecard produced with 7 dimensions scored (Corporate Standards N/A)
- [ ] Completeness score >= 4 (all sections present after backfill)
- [ ] Consistency score checked (economics now match scope)
- [ ] Overall grade follows the half-open bands (≥ 4.5, ≥ 3.5, ≥ 2.5, ≥ 1.5)
- [ ] Adversarial challenges generated
- [ ] Review report saved to `<OutputDir>/acme-property-sow-v0.2.0-review.md`

### Step 4: Feedback Loop (optional)
**Invoke**: feed review recommendations back to `sow-write`

**Verify**:
- [ ] Issues from review are addressable
- [ ] Updated SOW resolves critical issues, saved as the next version (`-v0.3.0.md`) without overwriting earlier ones
- [ ] Review score improves on re-review

## Success Criteria
- Pipeline completes end-to-end without manual intervention (except user checkpoints)
- Data flows correctly between skills (no lost information)
- Version tracking works (v0.1.0 → v0.2.0), and no run overwrites an earlier file
- The SOW economics quote the same figures as `summary.json`, which match the workbook's formulas
- One high-risk threshold (P×I ≥ 10) is used by sow-write, sow-estimate, pmo-pert-estimate and sow-review
