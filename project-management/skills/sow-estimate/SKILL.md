---
name: sow-estimate
description: "Extract WBS, roles, and risks from a Statement of Work and bridge to PERT three-point estimation. Parses SOW sections into PERT-compatible structures, invokes the pmo-pert-estimate skill for economics and timeline, then backfills the SOW's Economics and Schedule sections with PERT results. Use this skill whenever the user wants to estimate a SOW, generate SOW economics, bridge a SOW to PERT, calculate project costs from a statement of work, or mentions 'stima SoW', 'SOW economics', 'cost estimation from SOW', or 'generate economics for proposal'."
---

# SOW Estimate — WBS Extraction & PERT Bridge

## 1. Overview

This skill bridges the gap between a Statement of Work and PERT three-point estimation. It reads a SOW document (produced by `sow-write` or provided manually), extracts the work breakdown structure, roles, and risks, transforms them into PERT-compatible input, and invokes the `pmo-pert-estimate` skill. After PERT completes, it backfills the SOW's Economics and Schedule sections with the estimation results.

**Input:** SOW document (markdown or docx) — must have at least: scope/phases, team/roles, and ideally risk sections
**Output:** Updated SOW with populated Economics and Schedule sections + PERT Excel workbook

---

## 2. Pipeline

### Step 1 — Read SOW

Parse the SOW document. Identify:
- **Mode**: full (15-section) or summary (9-section) from structure
- **Language**: detect for output consistency
- **Section map**: which sections are present and their locations

Verify minimum content for extraction:
- Phases or deliverables (required — cannot estimate without scope)
- Roles or team composition (required — cannot allocate resources)
- Risks (optional — will create minimal risk register if absent)

If the SOW lacks phases or roles, stop and advise the user to complete the SOW first (or run `sow-write`).

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

For each extracted activity, note:
- Name and description
- Owner (from RACI or deliverables table)
- Acceptance criteria (if present)
- Phase assignment
- Dependencies (if identifiable)

Present the extracted WBS to the user for validation before proceeding.

### Step 3 — Extract Roles

From the SOW's Collaboration Model (full mode section 8) or Team (summary mode section 6), extract:

| SOW Element | PERT Mapping |
|-------------|-------------|
| Role name | Role code |
| Organization | Team assignment |
| Allocation % | Availability |
| Billable flag | Billable metadata |
| Seniority/level (if stated) | Rate tier |

If the SOW includes a rate card (section 10), extract rates. Otherwise, note that rates will be determined during the PERT estimation phase.

### Step 4 — Extract Risks

From the SOW's Risk Management (full mode section 11) or any risk mentions in other sections:

| SOW Element | PERT Mapping |
|-------------|-------------|
| Risk description | Risk entry |
| Probability (if scored) | P value (1-5) |
| Impact (if scored) | I value (1-5) |
| Strategy | Response strategy |
| Mitigation | Mitigation action |
| Owner | Risk owner |

If the SOW has no risk section, create a minimal risk register with 3-5 standard risks derived from the project type and scope.

### Step 5 — Generate PERT Input

Produce a structured context document that the `pmo-pert-estimate` skill can consume. This document contains:

1. **Project context** — extracted from SOW sections 2-3 (executive summary, context & objectives)
2. **WBS draft** — hierarchical structure from step 2
3. **Role Breakdown Structure** — team composition from step 3
4. **Risk register** — risks from step 4
5. **Targets** — if the SOW has budget or timeline references, include them as PERT targets
6. **Configuration hints** — language, effort unit, duration unit (from SOW context)

Save to `docs/pert-workspace/sow-extraction.md`.

### Step 6 — Invoke PERT

Hand off to `pmo-pert-estimate` with the extracted structure. The PERT skill runs its full pipeline:
- Phase 2: context analysis (using the extraction document as input)
- Phase 3: WBS + RBS refinement (starting from the extracted draft, not from scratch)
- Phase 4: risk assessment + three-point estimation
- Phase 5: Excel generation
- Phase 6: validation

The user interacts with the PERT skill normally — the extraction just provides a head start rather than starting from raw documents.

### Step 7 — Backfill SOW

After PERT completes, read the estimation results and populate the SOW:

**Economics section (full mode section 10):**
- Effort summary per phase (from PERT WBS sheet rollups)
- CAPEX/OPEX breakdown (if rate information available)
- Rate card (from PERT resources sheet)
- Payment schedule (aligned with SOW milestones)
- Confidence intervals (from PERT summary sheet: 68% and 95% CI)
- Total estimate with management reserve

**Schedule section (full mode section 9):**
- PERT-derived timeline (from Timeline sheet)
- Updated milestone dates (based on PERT duration calculations)
- Critical path (from dependency analysis)

For summary mode: update Milestones & Billing (section 4) with amounts derived from PERT.

Present the backfilled sections to the user for review before writing.

### Step 8 — Output

Save the updated SOW (replacing the economics placeholder with actual content) to the same path, incrementing the version:
- `docs/outbox/<project-name>-sow-v0.1.0.md` → `docs/outbox/<project-name>-sow-v0.2.0.md`

Present a summary: extraction statistics (phases, activities, roles, risks extracted), PERT results (total effort, duration, CI ranges), and the updated SOW location.

---

## 3. Progressive Disclosure

| Step | Documents to Read |
|------|-------------------|
| Steps 1, 3-4 | (no references — direct SOW parsing) |
| Step 2 | `references/extraction-rules.md` |
| Steps 5-8 | (no references — PERT skill handles its own progressive disclosure) |

---

## 4. Error Handling

- **SOW lacks phases**: stop, advise user to complete scope section or run `sow-write`
- **SOW lacks roles**: stop, advise user to add collaboration model
- **Extraction ambiguity**: when a SOW element could map to multiple WBS levels, ask the user
- **PERT estimation diverges significantly from SOW targets**: the PERT skill's reconciliation protocol handles this (see pmo-pert-estimate Phase 4)
- **Backfill conflicts**: if the SOW's Economics section already has content (not placeholder), ask user whether to replace or merge
