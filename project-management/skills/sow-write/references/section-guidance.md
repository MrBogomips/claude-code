# Section Writing Guidance

Per-section advice for writing high-quality SOW content. Use this reference during Step 6 (Section Generation) to ensure each section meets quality criteria.

---

## General Principles

- **Be specific**: replace vague language ("user-friendly", "reasonable", "as needed") with measurable criteria
- **Be consistent**: deliverables in Scope must appear in the Deliverables table; milestones in Schedule must align with Phase Breakdown
- **Number everything**: assumptions (A1, A2...), constraints (C1, C2...), risks (R1, R2...), requirements (REQ-001...) — enables precise cross-referencing
- **Use active voice**: "The vendor delivers..." not "It is expected that delivery will..."
- **Avoid ambiguity**: "within 5 business days" not "promptly"; "99.5% uptime" not "high availability"

---

## Full Mode Sections

### Section 1: Document Control

**Quality criteria:**
- Version follows semver (0.1.0 for first draft)
- All signature rows have role and organization
- Distribution list includes all stakeholders from RACI

**Common mistakes:**
- Missing distribution list (leads to information gaps)
- No version history (makes change tracking impossible)

### Section 2: Executive Summary

**Quality criteria:**
- Maximum 2 paragraphs
- Answers: why, what, and expected business impact
- No technical jargon (this section is for executives)

**Common mistakes:**
- Too long (becomes a duplicate of Context & Objectives)
- Too technical (alienates business stakeholders)

### Section 3: Context & Objectives

**Quality criteria:**
- KPIs are SMART (Specific, Measurable, Achievable, Relevant, Time-bound)
- Baseline values provided for each KPI (current state)
- Vision statement connects to business strategy

**Common mistakes:**
- KPIs without baselines (impossible to measure improvement)
- Vision disconnected from stated pain points

### Section 4: Actors & Roles

**Quality criteria:**
- Every RACI row has exactly one A (Accountable)
- No role is R for more than 60% of activities (overload indicator)
- User roles include primary use cases (not just names)

**Common mistakes:**
- Multiple A's per activity (diffused accountability)
- Missing user roles (only project roles listed)

### Section 5: Scope

**Quality criteria:**
- In-scope items are testable/verifiable
- Out-of-scope items cover common misunderstandings for this domain
- Each assumption has potential impact if invalid
- Dependencies have owners and deadlines

**Common mistakes:**
- Scope items that are actually requirements (move to Annexes)
- Assumptions that are actually constraints (if non-negotiable, it's a constraint)

### Section 6: Multi-Phase Breakdown

**Quality criteria:**
- Phase 1 has detailed deliverables with acceptance criteria
- Later phases are explicitly marked as "indicative"
- Each deliverable has exactly one owner
- Acceptance criteria are binary (pass/fail, not subjective)

**Common mistakes:**
- All phases equally detailed (violates rolling wave planning)
- Acceptance criteria like "meets client expectations" (not measurable)

### Section 7: Technical Strategy

**Quality criteria:**
- Build/buy/integrate rationale is documented for each major component
- NFRs have numeric targets and measurement methods
- Integration points specify protocol, data format, and frequency

**Common mistakes:**
- Architecture described without rationale
- NFRs without measurement methods

### Section 8: Collaboration Model

**Quality criteria:**
- Team composition includes allocation percentages
- Ceremonies have clear purpose (not just "status meeting")
- Escalation path has specific names and response times

**Common mistakes:**
- Too many ceremonies (meeting fatigue)
- No escalation path (issues get stuck)

### Section 9: Schedule

**Quality criteria:**
- Milestones align with Phase 6 deliverables
- Critical path is identified
- Mutual obligations have deadlines and impact-if-late

**Common mistakes:**
- Timeline without dependencies (unrealistic)
- Client obligations without deadlines (schedule risk)

### Section 10: Economics

**Quality criteria:**
- Delegated to `sow-estimate` for PERT-based estimation
- If filled manually: rate card, effort per phase, payment schedule, CAPEX/OPEX split

**Common mistakes:**
- Fixed-price without scope freeze clause
- Payment schedule not tied to milestones

### Section 11: Risk Management

**Quality criteria:**
- P x I score for every risk
- High risks (P x I >= 12) have mitigation plans
- Each risk has a named owner
- Management reserve percentage stated

**Common mistakes:**
- Generic risks only ("scope creep", "delays") — need project-specific risks
- Mitigations that are actually contingencies (mitigation reduces probability; contingency is the plan B)

### Section 12: Quality & Acceptance

**Quality criteria:**
- Testing approach covers unit, integration, and UAT minimum
- Definition of Done is explicit and referenced in Phase 6
- Quality standards reference applicable frameworks (ISO, OWASP, WCAG)

**Common mistakes:**
- DoD too vague ("code reviewed" — by whom? what criteria?)
- No UAT process (client acceptance becomes subjective)

### Section 13: Change Management

**Quality criteria:**
- CR process has specific SLAs per impact category
- Approval authority is clear for each category
- Impact assessment includes scope, timeline, and budget

**Common mistakes:**
- No threshold for when steering committee is involved
- No SLA for assessment (CRs languish indefinitely)

### Section 14: Other Terms

**Quality criteria:**
- IP ownership is unambiguous (work-for-hire vs. licensed)
- Privacy terms reference applicable regulations (GDPR, CCPA)
- Warranty duration and scope are specific
- Termination conditions include notice period and transition obligations

**Common mistakes:**
- IP terms that conflict with open-source dependencies
- No termination clause (trapped in a bad engagement)

### Section 15: Annexes

**Quality criteria:**
- Requirements matrix has unique IDs and priority levels
- Glossary includes all domain-specific terms used in the SOW
- References include version numbers

**Common mistakes:**
- Requirements not traceable to scope items
- Glossary missing (reader must guess meanings)

---

## Summary Mode Sections

Summary mode sections follow the same quality principles but focus on extraction accuracy:

- **Section 1 (Contract References)**: every reference must be verifiable against the source contract
- **Section 3 (Deliverables)**: acceptance criteria extracted or derived, not invented
- **Section 4 (Milestones & Billing)**: amounts must reconcile with contract totals
- **Section 5 (SLAs)**: targets must match or improve on contract baselines
- **Section 7 (Governance)**: penalties must match contract terms exactly
- **Section 9 (Cross-references)**: every SOW section should trace to a contract clause
