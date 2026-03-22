# Integration Test: Write → Estimate → Review Pipeline

## Objective
Verify that the three SOW skills work together as a pipeline, with outputs from one skill feeding correctly into the next.

## Input
`sample-brief.md` (HomeAI project brief)

## Test Steps

### Step 1: SOW Write
**Invoke**: `sow-write` in full mode with the sample brief

**Verify**:
- [ ] 15-section SOW produced
- [ ] Section 10 (Economics) has sow-estimate placeholder
- [ ] Section 6 (Phase Breakdown) has 3 phases matching the brief
- [ ] Section 8 (Collaboration Model) has team from brief
- [ ] Section 11 (Risk Management) includes data migration and GDPR risks
- [ ] Language: English (brief is in English)
- [ ] Saved to docs/outbox/homeai-sow-v0.1.0.md

### Step 2: SOW Estimate
**Invoke**: `sow-estimate` on the SOW from Step 1

**Verify**:
- [ ] WBS extracted: 3 Level-1 phases, decomposed into work packages
- [ ] Roles extracted: matches Section 8 team composition
- [ ] Risks extracted: matches Section 11 risk register
- [ ] PERT invoked with pre-populated structures
- [ ] PERT Excel generated at docs/outbox/pert-estimate.xlsx
- [ ] SOW Economics section (10) backfilled with PERT results
- [ ] SOW Schedule section (9) updated with PERT timeline
- [ ] Updated SOW saved as v0.2.0

### Step 3: SOW Review
**Invoke**: `sow-review` on the updated SOW from Step 2

**Verify**:
- [ ] Scorecard produced with 7 dimensions scored (Corporate Standards N/A)
- [ ] Completeness score >= 4 (all sections present after backfill)
- [ ] Consistency score checked (economics now match scope)
- [ ] Adversarial challenges generated
- [ ] Review report saved to docs/outbox/homeai-sow-review.md

### Step 4: Feedback Loop (optional)
**Invoke**: feed review recommendations back to `sow-write`

**Verify**:
- [ ] Issues from review are addressable
- [ ] Updated SOW resolves critical issues
- [ ] Review score improves on re-review

## Success Criteria
- Pipeline completes end-to-end without manual intervention (except user checkpoints)
- Data flows correctly between skills (no lost information)
- Version tracking works (v0.1.0 → v0.2.0)
- PERT Excel is consistent with final SOW economics
