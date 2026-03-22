# Scenario: WBS Extraction and PERT Bridge

## Setup
Provide a complete 15-section SOW with:
- 3 phases in Multi-Phase Breakdown
- 8-10 deliverables across phases
- Team of 5 roles with allocation percentages
- Risk register with 6 entries

## Invocation
"Estimate this SOW"

## Expected Behavior
1. Parses SOW, identifies full mode
2. Extracts WBS: 3 Level-1 items, decomposed into Level-2/3
3. Extracts roles: 5 roles with allocation and billable flags
4. Extracts risks: 6 entries with P×I scores
5. Generates PERT input document at docs/pert-workspace/sow-extraction.md
6. Invokes pmo-pert-estimate with extracted structure
7. PERT starts from extraction (not blank slate)

## Acceptance Criteria
- [ ] WBS Level-1 items match SOW phase names exactly
- [ ] All deliverables mapped to WBS leaf activities
- [ ] Role codes match SOW team composition
- [ ] Risk entries preserve P×I scores from SOW
- [ ] sow-extraction.md contains all 5 required sections
- [ ] PERT skill receives pre-populated WBS (Phase 3 starts from draft, not empty)
- [ ] 8/80 rule violations flagged if present

## Edge Cases
- SOW with no risk section → auto-generates 3-5 standard risks
- Deliverable appearing in multiple phases → creates separate WBS entries
- Phase with no decomposition → creates placeholder, flags for user
