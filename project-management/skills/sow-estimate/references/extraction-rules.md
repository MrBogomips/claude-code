# SOW → WBS Extraction Rules

Rules for mapping SOW document sections to PERT-compatible Work Breakdown Structure elements. Apply these during Step 2 of the sow-estimate pipeline.

---

## General Principles

- **Preserve hierarchy**: SOW phase → WBS Level 1, subsection → Level 2, deliverable → Level 3
- **Preserve names**: use the SOW's exact terminology for phases and deliverables (don't rename)
- **Preserve owners**: map RACI "R" (Responsible) to the activity owner
- **Flag gaps**: if a phase has no decomposition, flag it for user clarification
- **Respect 8/80**: extracted work packages should fall within 8-80 hours; flag violations

---

## Full Mode Extraction (15-section SOW)

### Source: Section 6 — Multi-Phase Breakdown

| SOW Pattern | WBS Mapping | Example |
|-------------|-------------|---------|
| `### Phase N: {Name}` heading | Level 1 item (ID: N) | `### Phase 1: Discovery` → WBS 1: Discovery |
| Subsection within phase | Level 2 work package (ID: N.M) | `#### 1.1 Requirements Gathering` → WBS 1.1 |
| Row in deliverables table | Level 3 leaf activity (ID: N.M.K) | Deliverable "User Stories" → WBS 1.1.1 |
| "Acceptance Criteria" column | Definition of Done for the activity | "All stories reviewed by PO" → DoD |
| "Owner" column | Activity owner (role code from RBS) | "Product Manager" → PM |
| "(indicative)" marker | Mark WBS items as estimated, not committed | Phase 2 (indicative) → low-confidence flag |

### Source: Section 5 — Scope

| SOW Pattern | WBS Mapping |
|-------------|-------------|
| In-scope items not covered by Phase Breakdown | Flag as potential missing WBS items |
| Assumptions (A1, A2...) | WBS metadata: constraints on estimation |
| Dependencies (D1, D2...) | WBS predecessor/successor relationships |
| Constraints (C1, C2...) | WBS metadata: hard limits on effort/duration |

### Source: Section 8 — Collaboration Model

| SOW Pattern | RBS Mapping |
|-------------|-------------|
| Team composition table: Role column | Role code |
| Team composition table: Organization column | Team assignment |
| Team composition table: Allocation % | Availability (affects effort calculation) |
| Team composition table: Billable column | Billable flag |
| RACI matrix: R assignments | Role-to-activity mapping |

### Source: Section 11 — Risk Management

| SOW Pattern | Risk Register Mapping |
|-------------|----------------------|
| Risk register table rows | Direct mapping to PERT risk entries |
| P (Probability) column | P value (1-5) |
| I (Impact) column | I value (1-5) |
| Strategy column | Response strategy |
| Mitigation column | Mitigation action |
| Owner column | Risk owner |
| Management reserve % (if stated) | PERT config: ManagementReservePct |

### Source: Section 9 — Schedule

| SOW Pattern | Timeline Mapping |
|-------------|-----------------|
| Milestone table: Date column | Target milestone dates |
| Critical path description | Dependency chain for PERT |
| Mutual obligations: Due Date | External dependency dates |

### Source: Section 10 — Economics (if partially populated)

| SOW Pattern | PERT Config Mapping |
|-------------|-------------------|
| Rate card table | PERT rate inputs |
| CAPEX/OPEX split | Cost categorization |
| Budget envelope (if stated) | PERT target for reconciliation |

---

## Summary Mode Extraction (9-section SOW)

### Source: Section 3 — Deliverables Table

| SOW Pattern | WBS Mapping |
|-------------|-------------|
| Each row in deliverables table | Level 2 work package (group by logical phase) |
| Deliverable description | Activity description |
| Acceptance criteria | Definition of Done |
| Owner | Activity owner |
| Due date | Target date |

Since summary mode has no explicit phase breakdown, infer phases by:
1. Grouping deliverables by logical theme (e.g., all "design" deliverables → Phase: Design)
2. Grouping by due date clusters
3. Asking the user if grouping is unclear

### Source: Section 6 — Team

| SOW Pattern | RBS Mapping |
|-------------|-------------|
| Team table rows | Direct mapping to roles |
| Allocation % | Availability |
| Billable flag | Billable metadata |

### Source: Section 4 — Milestones & Billing

| SOW Pattern | PERT Mapping |
|-------------|-------------|
| Milestone dates | Target dates |
| Payment amounts | Budget references for reconciliation |
| Payment terms | Cost categorization hints |

---

## Edge Cases

### Missing Decomposition
If a phase exists but has no sub-items (no deliverables table, no subsections):
- Create a single Level 2 placeholder: "{Phase Name} — Work Package (to be decomposed)"
- Flag for user review: "Phase {N} has no deliverables breakdown — should I decompose it during PERT estimation?"

### Overlapping Scope
If a deliverable appears in multiple phases (e.g., "documentation" in Phase 1 and Phase 3):
- Create separate WBS items for each occurrence
- Add a note: "This deliverable spans multiple phases — effort should be estimated per phase"

### Ambiguous Hierarchy
If the SOW structure doesn't clearly distinguish between work packages and activities:
- Default to Level 2 (work package) for all extracted items
- Let the PERT skill's WBS Builder (Phase 3) further decompose if needed

### No Risk Section
If the SOW has no Risk Management section:
- Create 3-5 standard risks based on project type:
  - Scope creep (P:3, I:4)
  - Key person dependency (P:3, I:3)
  - Integration complexity (P:2, I:4) — if integrations mentioned
  - Timeline pressure (P:3, I:3) — if timeline is tight
  - Requirement ambiguity (P:3, I:3) — if clarity score is low
- Mark as "auto-generated — review recommended"

### Rate Information
- If the SOW includes a rate card: pass rates to PERT for cost calculations
- If the SOW mentions a budget envelope but no rates: pass as PERT target
- If neither: PERT skill will use its configured AvgRate or ask the user
