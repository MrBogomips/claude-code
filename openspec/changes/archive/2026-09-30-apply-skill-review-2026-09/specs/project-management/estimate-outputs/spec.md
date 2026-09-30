# Spec Delta

## Purpose

Defines where the project-management skills put working documents and deliverables, and how
they avoid overwriting them.

## ADDED Requirements

### Requirement: One configuration section and one output key for the plugin
All skills of the plugin SHALL read the output folder from `OutputDir` in the
`## project-management Configuration` section of the project's `CLAUDE.md`, SHALL read a
`## pmo-pert-estimate Configuration` section the same way, and SHALL ask the user and record the
value when it is missing.

#### Scenario: Output folder not configured
- **WHEN** sow-review runs in a project whose `CLAUDE.md` has no `OutputDir`
- **THEN** it asks for the output folder, suggests `docs/outbox/`, and records it as `OutputDir`

### Requirement: Working documents stay out of the output folder
Drafts and intermediate files (PERT drafts, `excel-input.json`, `summary.json`, the handoff,
sow-write's `input-analysis.md`) SHALL be written under `WorkspaceDir`, resolved from the
configuration, else from the project's declared working-documents location, else by asking the
user; each PERT estimate SHALL have its own folder `pert-<estimate-slug>/`.

#### Scenario: Project declares a working-documents folder
- **WHEN** `WorkspaceDir` is unset and the project's `CLAUDE.md` declares a gitignored working-documents folder
- **THEN** the estimate folder is created inside that folder and no draft is written to `OutputDir`

### Requirement: Starting over keeps a backup
When the user chooses to start over in an existing estimate folder, the skill SHALL first rename
it to `pert-<estimate-slug>.bak-<YYYYMMDD-HHMM>/` and only then create a new folder.

#### Scenario: Start over
- **WHEN** the estimate folder exists and the user chooses to start over
- **THEN** the previous drafts remain in the `.bak-` folder

### Requirement: Outputs are versioned and never overwritten
The skills SHALL write each deliverable under a new name when the target exists: the PERT
workbook as `<estimate-slug>-pert-v<N>.xlsx` with the next N, an updated or re-written SOW as the
next free minor version, and a repeated review with a numeric suffix. They SHALL NOT modify input
documents.

#### Scenario: Second PERT run
- **WHEN** `acme-pert-v1.xlsx` exists in the output folder and the estimate is generated again
- **THEN** the new workbook is `acme-pert-v2.xlsx` and `acme-pert-v1.xlsx` is unchanged

#### Scenario: SOW backfill
- **WHEN** sow-estimate backfills `acme-sow-v0.1.0.md`
- **THEN** it writes `acme-sow-v0.2.0.md` and leaves `acme-sow-v0.1.0.md` byte-identical
