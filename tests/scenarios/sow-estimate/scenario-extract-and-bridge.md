# Scenario: WBS Extraction and PERT Bridge

## Setup
Provide a complete 15-section SOW with:
- 3 phases in Multi-Phase Breakdown
- 8-10 deliverables across phases
- Team of 5 roles with allocation percentages
- Risk register with 6 entries, one of them scored P×I = 10 without a mitigation
- `## project-management Configuration` in the project's CLAUDE.md with `OutputDir` set and no `WorkspaceDir`; the project's CLAUDE.md declares a gitignored working-documents folder

## Invocation
"Estimate this SOW"

## Expected Behavior
1. Parses SOW, identifies full mode
2. Extracts WBS: 3 Level-1 items, decomposed into Level-2/3
3. Extracts roles: 5 roles with teams and billable flags; allocation % kept as a note only
4. Extracts risks: 6 entries with P×I scores; flags the P×I = 10 risk as high and without mitigation
5. Writes the handoff at `<working-documents folder>/pert-<project-slug>/sow-extraction.md`, not in the output folder
6. Invokes pmo-pert-estimate with the path of `sow-extraction.md`
7. pmo-pert-estimate takes its "entry from sow-estimate" branch: reuses that folder, asks only for the interaction level, and its Phase 3 starts from the extracted WBS and roles

## Acceptance Criteria
- [ ] WBS Level-1 items match SOW phase names exactly
- [ ] All deliverables mapped to WBS leaf activities
- [ ] Role codes match SOW team composition
- [ ] Allocation % does not change any effort figure
- [ ] Risk entries preserve P×I scores from SOW; the P×I = 10 risk is reported as high
- [ ] `sow-extraction.md` has the 7 sections: Source, Project context, WBS draft, Roles, Risk register, Targets, Configuration hints
- [ ] Nothing is written to `OutputDir` during extraction
- [ ] pmo-pert-estimate does not ask again for input documents, a reference folder or targets
- [ ] pmo-pert-estimate does not offer to start over in the handoff folder
- [ ] Phase 3 starts from the extracted draft, not from an empty WBS
- [ ] Deliverables that are clearly larger than 10 PD are flagged for splitting (8/80 rule)

## Edge Cases
- SOW with no risk section → auto-generates 3-5 standard risks
- Deliverable appearing in multiple phases → creates separate WBS entries
- Phase with no decomposition → creates placeholder, flags for user
- Estimate folder already exists → asks reuse or start over; starting over first renames the old folder to `pert-<project-slug>.bak-<timestamp>/`
- SOW given as DOCX with no converter connected or installed → asks for a Markdown or PDF export instead of guessing the content
- No working-documents location declared and no `WorkspaceDir` → asks where drafts should go and records `WorkspaceDir`
