# Scenario: SOW Economics Backfill

## Setup
1. A SOW with economics placeholder (output of sow-write)
2. A completed PERT estimation (output of pmo-pert-estimate invoked by sow-estimate)

## Invocation
Automatic — this is Step 7 of the sow-estimate pipeline, triggered after PERT completes.

## Expected Behavior
1. Reads PERT results (Excel workbook or workspace artifacts)
2. Populates SOW Section 10 (Economics) with:
   - Effort summary per phase
   - CAPEX/OPEX breakdown
   - Rate card
   - Payment schedule aligned with milestones
   - Confidence intervals (68% and 95%)
3. Updates SOW Section 9 (Schedule) with:
   - PERT-derived timeline
   - Updated milestone dates
   - Critical path
4. Saves updated SOW with version increment (v0.1.0 → v0.2.0)

## Acceptance Criteria
- [ ] Economics section fully populated (no placeholder remaining)
- [ ] Effort per phase matches PERT WBS rollups
- [ ] Payment milestones align with SOW Section 6 deliverables
- [ ] Confidence intervals present (68% and 95%)
- [ ] Schedule updated with PERT-derived dates
- [ ] Version incremented
- [ ] Original SOW preserved (new version created)

## Edge Cases
- SOW Section 10 already has partial content → ask user: replace or merge
- PERT results significantly exceed SOW budget hints → flag with reconciliation summary
