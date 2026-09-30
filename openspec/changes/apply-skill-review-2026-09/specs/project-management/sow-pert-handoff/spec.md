# Spec Delta

## Purpose

Defines the handoff between sow-estimate and pmo-pert-estimate, and how the estimate's figures
flow back into the SOW.

## ADDED Requirements

### Requirement: sow-estimate writes the handoff in the estimate folder
sow-estimate SHALL write `sow-extraction.md` in the estimate folder
`<WorkspaceDir>/pert-<project-slug>/`, with the sections Source, Project context, WBS draft,
Roles, Risk register, Targets and Configuration hints, and SHALL pass its path to
pmo-pert-estimate.

#### Scenario: Handoff location
- **WHEN** sow-estimate finishes extracting a SOW
- **THEN** `sow-extraction.md` exists in the estimate folder and nothing has been written to the output folder

### Requirement: pmo-pert-estimate takes an entry from sow-estimate
When invoked with a `sow-extraction.md`, pmo-pert-estimate SHALL use the folder holding it as the
estimate folder, SHALL NOT ask again for input documents, a reference folder or targets that the
extraction carries, SHALL NOT offer to start over in that folder, and SHALL start Phase 3 and the
Risk Analyst from the extracted WBS, roles and risks.

#### Scenario: Entry from sow-estimate
- **WHEN** sow-estimate invokes pmo-pert-estimate with the handoff path
- **THEN** Phase 1 asks only for the interaction level and for items the extraction flags as missing

### Requirement: The SOW backfill uses the summarizer's figures
sow-estimate SHALL fill the Economics and Schedule sections from `summary.json` in the estimate
folder, not from the workbook. When `summary.json` is missing it SHALL NOT backfill and SHALL tell
the user which PERT step remains.

#### Scenario: Economics backfill
- **WHEN** the PERT estimate has completed its checks
- **THEN** the per-phase effort equals `phases[].pert_effort` and the total estimate equals `effort.medium_band` in `summary.json`

### Requirement: Allocation and rates do not alter PERT effort
sow-estimate SHALL record a SOW's allocation percentages and seniority as notes only, and SHALL
keep a SOW rate card for the backfill, because the PERT input has no availability or per-role
rate field.

#### Scenario: Role at 20% allocation
- **WHEN** the SOW team table lists a role at 20% allocation
- **THEN** the extracted role carries the allocation as a note and no effort value is scaled by it
