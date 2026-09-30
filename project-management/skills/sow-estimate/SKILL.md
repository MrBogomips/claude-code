---
name: sow-estimate
description: "Extract WBS, roles, and risks from a Statement of Work and bridge to PERT three-point estimation. Parses SOW sections into PERT-compatible structures, invokes the pmo-pert-estimate skill for economics and timeline, then backfills the SOW's Economics and Schedule sections with PERT results in a new SOW version. Use this skill whenever the user wants to estimate a SOW, generate SOW economics, bridge a SOW to PERT, calculate project costs from a statement of work, or mentions 'stima SoW', 'SOW economics', 'cost estimation from SOW', or 'generate economics for proposal'."
---

# SOW Estimate — WBS Extraction & PERT Bridge

## 1. Overview

This skill bridges a Statement of Work and a PERT three-point estimate. It reads a SOW (produced by `sow-write` or provided by the user), extracts the work breakdown, roles and risks into a handoff file, and invokes `pmo-pert-estimate`, which starts from that file instead of from raw documents. When the estimate is done, it writes a new version of the SOW with the Economics and Schedule sections filled from the estimate's figures.

**Input:** a SOW in Markdown, PDF or DOCX, with at least scope/phases and team/roles, and ideally a risk section. The input file is never modified.
**Output:** a new SOW version with populated Economics and Schedule sections, plus the versioned PERT workbook written by `pmo-pert-estimate`.

**Folders.** This skill uses the same configuration section as `pmo-pert-estimate` (`## project-management Configuration` in the project's `CLAUDE.md`):

- **Output folder:** `OutputDir`. If it is not set, ask the user (suggest `docs/outbox/`) and record it.
- **Estimate folder:** `<WorkspaceDir>/pert-<project-slug>/`, resolved as in `pmo-pert-estimate` Section 2 (configured `WorkspaceDir`, else the project's working-documents location, else ask). The handoff file and all PERT drafts live there, never in the output folder.

**Connector support:** if **~~document converter** is connected, use it to turn a PDF or DOCX SOW into Markdown (see `CONNECTORS.md`).

---

## 2. Pipeline

### Step 1 — Read SOW

Read the SOW. A Markdown file is read directly, and a PDF with the Read tool. A DOCX cannot be read directly: convert it with a **~~document converter** if one is connected; otherwise look for a converter on the system (`command -v markitdown pandoc`) and, if one is found, ask before running it (`markitdown <file>` or `pandoc -t gfm <file>`); if none is available, ask the user for a Markdown or PDF export.

Identify:
- **Mode**: full (15-section) or summary (9-section) from the structure
- **Language**: for output consistency
- **Section map**: which sections are present and where
- **Version**: the `-v<semver>` in the file name, if any

Verify the minimum content for extraction:
- Phases or deliverables (required: no scope, no estimate)
- Roles or team composition (required: no roles, no resource allocation)
- Risks (optional: a minimal register is created if absent)

If the SOW lacks phases or roles, stop and advise the user to complete it first (or run `sow-write`).

### Step 2 — Extract WBS

`Read references/extraction-rules.md` for the mapping rules.

From the SOW's Multi-Phase Breakdown (full mode section 6) or Deliverables Table (summary mode section 3), extract:

| SOW Element | PERT Mapping | WBS Level |
|-------------|-------------|-----------|
| Phase headings | Level 1 WBS items | 1 (e.g., 1, 2, 3) |
| Subsections within phases | Level 2 work packages | 1.1, 1.2, 2.1 |
| Individual deliverables | Level 3 leaf activities | 1.1.1, 1.1.2 |
| Acceptance criteria | Definition of Done per activity | Metadata |
| Dependencies between phases | Predecessor/successor relationships | Relationships |

For each extracted activity, note its name and description, owner (from the RACI or deliverables table), acceptance criteria, phase and dependencies.

Present the extracted WBS to the user for validation before proceeding.

### Step 3 — Extract Roles

From the SOW's Collaboration Model (full mode section 8) or Team (summary mode section 6), extract:

| SOW Element | PERT Mapping |
|-------------|-------------|
| Role name | Role code and name |
| Organization | Team |
| Billable flag | Billable flag |
| Allocation % | Note only: the PERT input has no availability field, so it does not change effort |
| Seniority/level (if stated) | Note only: the workbook has no rate tiers |

If the SOW includes a rate card (section 10), keep it for the backfill in Step 7. The PERT workbook carries no per-role rates: its only rate is the configured `AvgRate`, which prices the risk contingency.

### Step 4 — Extract Risks

From the SOW's Risk Management (full mode section 11) or risk mentions in other sections:

| SOW Element | PERT Mapping |
|-------------|-------------|
| Risk description | Risk entry |
| Probability (if scored) | P value (1-5) |
| Impact (if scored) | I value (1-5) |
| Strategy | Response strategy |
| Mitigation | Mitigation action |
| Owner | Risk owner |

A risk with P×I ≥ 10 is high, the same threshold PERT uses; flag high risks that have no mitigation. If the SOW has no risk section, create a minimal register with 3-5 standard risks derived from the project type and scope.

### Step 5 — Write the handoff file

Create the estimate folder. If it already exists, ask whether to reuse it or start over; to start over, first rename it to `pert-<project-slug>.bak-<YYYYMMDD-HHMM>/`, so nothing is lost.

Write `<estimate>/sow-extraction.md` with these sections:

1. **Source** — the SOW path and version, mode and language
2. **Project context** — from SOW sections 2-3 (executive summary, context & objectives)
3. **WBS draft** — the hierarchy from Step 2
4. **Roles** — the role list from Step 3, with teams and billable flags
5. **Risk register** — the risks from Step 4
6. **Targets** — budget or timeline references in the SOW, as PERT targets
7. **Configuration hints** — language, effort unit, duration unit; management reserve % if the SOW states one

### Step 6 — Invoke PERT

Invoke `pmo-pert-estimate` and give it the path of `sow-extraction.md`. It takes its "entry from sow-estimate" branch: it reuses the estimate folder, does not ask again for the inputs the extraction carries, and refines the extracted WBS, roles and risks instead of starting from scratch. The user works through its checkpoints as usual.

When it finishes, the estimate folder holds `excel-input.json` and `summary.json`, and the versioned workbook is in the output folder.

### Step 7 — Backfill SOW

Take every figure from `<estimate>/summary.json` (written by `pmo-pert-estimate` Phase 6), never from the workbook: the workbook stores formulas without computed values, so it cannot be read back for numbers.

**Economics section (full mode section 10):**
- Effort summary per phase: `phases[].pert_effort`
- Effort bands: `effort.low_band`, `effort.medium_band`, `effort.high_band`, with `effort.contingency` and `effort.management_reserve`
- Total estimate: the Medium Band (it includes contingency and management reserve)
- Rate card: the SOW's own rate card, or the configured `AvgRate`
- CAPEX/OPEX breakdown and cost figures, when rate information exists: PD × rate
- Payment schedule aligned with the SOW milestones

**Schedule section (full mode section 9):**
- Timeline: `calendar_weeks`, and the phase weeks (`start_week`, `end_week`) in `excel-input.json`
- Updated milestone dates, from the phase weeks and the project start date
- Critical path, from the dependencies in the WBS

For summary mode: update Milestones & Billing (section 4) with amounts derived from the same figures.

If the Economics section already has content (not the placeholder), ask the user whether to replace or merge. Present the backfilled sections for review before writing.

### Step 8 — Output

Write the updated SOW as a **new file**; the input SOW stays as it is:

- Name: `<OutputDir>/<project-name>-sow-v<next>.md`, where `<next>` is the next minor version of the input (`v0.1.0` → `v0.2.0`; an input with no version counts as `v0.1.0`).
- If that name is taken, use the next free minor version. Never overwrite an existing file.

Present a summary: extraction statistics (phases, activities, roles, risks, high risks), the PERT figures from `summary.json` (Tech PERT effort, Low / Medium / High Band, Calendar Duration in weeks), and the paths of the new SOW version and of the workbook.

---

## 3. Progressive Disclosure

| Step | Documents to Read |
|------|-------------------|
| Steps 1, 3-4 | (no references — direct SOW parsing) |
| Step 2 | `references/extraction-rules.md` |
| Steps 5-6 | (no references — PERT skill handles its own progressive disclosure) |
| Steps 7-8 | `<estimate>/summary.json` and `<estimate>/excel-input.json` |

---

## 4. Error Handling

- **SOW lacks phases**: stop, advise the user to complete the scope section or run `sow-write`
- **SOW lacks roles**: stop, advise the user to add the collaboration model
- **DOCX with no converter**: ask for a Markdown or PDF export
- **Extraction ambiguity**: when a SOW element could map to several WBS levels, ask the user
- **PERT estimate diverges significantly from SOW targets**: the PERT skill's reconciliation handles it (pmo-pert-estimate Phase 4)
- **`summary.json` missing** (PERT stopped before Phase 6, e.g. without openpyxl): do not backfill from guesses; tell the user which PERT step remains
- **Backfill conflicts**: if the Economics section already has content, ask whether to replace or merge
