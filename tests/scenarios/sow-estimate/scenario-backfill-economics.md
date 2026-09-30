# Scenario: SOW Economics Backfill

## Setup
1. A SOW `<OutputDir>/<project-name>-sow-v0.1.0.md` with the economics placeholder (output of sow-write)
2. A completed PERT estimation started by sow-estimate: the estimate folder holds `excel-input.json` and `summary.json`, and `<OutputDir>/<project-name>-pert-v1.xlsx` exists

## Invocation
Automatic — this is Step 7 of the sow-estimate pipeline, triggered after PERT completes.

## Expected Behavior
1. Reads the figures from `summary.json`, not from the workbook
2. Populates SOW Section 10 (Economics) with:
   - Effort summary per phase (`phases[].pert_effort`)
   - CAPEX/OPEX breakdown (when rates are available)
   - Rate card (the SOW's own, or `AvgRate`)
   - Payment schedule aligned with milestones
   - Effort bands (Low / Medium / High) with contingency and management reserve
3. Updates SOW Section 9 (Schedule) with:
   - Timeline from `calendar_weeks` and the phase weeks in `excel-input.json`
   - Updated milestone dates
   - Critical path
4. Writes the result to a new file `<OutputDir>/<project-name>-sow-v0.2.0.md`

## Acceptance Criteria
- [ ] Economics section fully populated (no placeholder remaining)
- [ ] Effort per phase equals `phases[].pert_effort` in `summary.json`
- [ ] Total estimate equals `effort.medium_band`; Low and High bands equal `effort.low_band` and `effort.high_band`
- [ ] Schedule duration equals `calendar_weeks`
- [ ] Payment milestones align with SOW Section 6 deliverables
- [ ] The new file is `-sow-v0.2.0.md`; `-sow-v0.1.0.md` is byte-identical to before the run
- [ ] The summary shown to the user quotes the same figures and both output paths

## Edge Cases
- SOW Section 10 already has partial content → ask user: replace or merge
- PERT results significantly exceed SOW budget hints → flag with reconciliation summary
- `-sow-v0.2.0.md` already exists → writes `-sow-v0.3.0.md`, overwrites nothing
- Input SOW has no version in its name → writes `-sow-v0.2.0.md`
- `summary.json` missing (PERT stopped before its checks, e.g. openpyxl not installed) → no backfill; tells the user which PERT step remains
