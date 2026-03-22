# SOW Best Practices

Synthesized from PMI/PMBOK, Agile contracting patterns, and government procurement frameworks (FAR, EU Directives). Use during dimensional analysis to evaluate best practice adherence.

---

## Structure Best Practices

### Rolling Wave Planning
- Phase 1 should be detailed with specific deliverables, acceptance criteria, and timeline
- Later phases should be marked "indicative" with high-level scope and estimated effort
- Each phase gate triggers detailed planning for the next phase
- **Why:** reduces risk of over-committing to uncertain scope; enables learning from early phases

### 100% Rule (WBS)
- The sum of work at child level must equal 100% of the work at the parent level
- No orphan activities (work not traced to a deliverable)
- No invisible work (deliverables without activities to produce them)

### 8/80 Rule (Work Packages)
- No work package should be estimated at less than 8 hours or more than 80 hours
- If < 8h: merge with related work package
- If > 80h: decompose further
- **Why:** packages under 8h create micromanagement overhead; over 80h hide complexity

### Explicit Exclusions
- Always state what is NOT in scope, especially for items that stakeholders commonly assume are included
- Good exclusions prevent the #1 SOW dispute: "I assumed that was included"
- Pattern: for each in-scope item, consider what adjacent work is excluded

---

## Content Best Practices

### Acceptance Criteria
- Every deliverable should have binary (pass/fail) acceptance criteria
- Criteria should be testable without subjective judgment
- Pattern: "The system shall [verb] [object] [measurable condition]"
- Anti-pattern: "The system shall be user-friendly" (not measurable)

### Measurable Requirements
- Replace qualitative with quantitative: "fast" → "response time < 200ms at P95"
- Specify measurement method alongside the target
- Include baseline (current state) when improving an existing system

### Assumption Management
- Number all assumptions (A1, A2, A3...)
- State the impact if each assumption proves invalid
- Reference assumptions from the sections they affect (e.g., "per Assumption A3")
- Review assumptions at each phase gate

### Dependency Tracking
- External dependencies need: owner, deadline, and impact-if-late
- Internal dependencies need: predecessor/successor relationships
- Critical path should be identifiable from dependency information

---

## Commercial Best Practices

### Payment Milestones
- Tie payments to deliverable acceptance, not calendar dates
- Include holdback (5-10%) until final acceptance
- Define invoice trigger and payment terms explicitly
- For time-and-materials: cap total spend, define approval for overruns

### Change Request Process
- Define impact categories (minor/major/critical) with thresholds
- Assign approval authority per category
- Set SLA for impact assessment (e.g., "within 5 business days")
- Require written approval before work begins on any change

### Penalty Proportionality
- Penalties should be proportionate to contract value (typically 0.5-2% per week for delays)
- Always cap total penalties (typically 10-15% of contract value)
- Distinguish between service credits (SLA violations) and delay penalties
- Include force majeure provisions

### Warranty Terms
- Define duration (typically 3-12 months from final acceptance)
- Define scope: defects only, or also performance issues?
- Define response times during warranty
- Clarify: does warranty extend if defects are found?

---

## Governance Best Practices

### RACI Discipline
- Exactly one A (Accountable) per activity — no shared accountability
- The person who is R (Responsible) should also have the authority and resources
- Don't make everyone C (Consulted) — it slows decisions
- I (Informed) is for transparency, not approval

### Escalation Paths
- Define at least 3 levels: project manager → steering committee → executive sponsor
- Include response time SLA per level
- Name individuals (not just roles) where possible
- Define what constitutes an escalation trigger

### Communication
- Define channels by purpose (not just tools)
- Distinguish: decision communication vs. status updates vs. ad-hoc questions
- Include frequency and owner for recurring communications
- Define the "source of truth" for project documentation

---

## Agile-Specific Patterns

When the SOW covers Agile delivery:

### Fixed Scope vs. Fixed Budget
- Agile SOWs should fix budget and timeline, flex scope
- Define a prioritized backlog with "must have" / "should have" / "could have"
- Payment tied to sprint completion (velocity-based) or milestone acceptance
- Include re-planning ceremony at each sprint boundary

### Definition of Done
- SOW-level DoD should be explicit and agreed
- Sprint-level DoD may evolve but SOW-level remains fixed
- Include non-functional requirements in DoD (performance, security, accessibility)

### Velocity and Capacity
- Don't commit to story points in a SOW (velocity is emergent)
- Commit to team capacity (N developers for M sprints)
- Define what happens if velocity is significantly below projection

---

## Government / Public Procurement Patterns

### EU Public Procurement (relevant for Italian context)
- Must reference applicable regulations (D.Lgs. 36/2023 for Italy)
- Require CIG and CUP codes where applicable
- DURC (regularity certificate) requirements for vendors
- Subcontracting limits and transparency requirements
- Specific evaluation criteria (OEPV — Offerta Economicamente Più Vantaggiosa)

### US Federal (FAR-based)
- Performance Work Statements (PWS) for outcome-based contracting
- Quality Assurance Surveillance Plans (QASP) for monitoring
- Section 508 accessibility requirements
- FISMA security requirements for IT systems
