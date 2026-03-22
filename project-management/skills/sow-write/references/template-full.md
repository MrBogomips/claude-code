# Full Mode Template — 15 Sections

Use this template when generating a full enterprise SOW. Each section includes placeholders (in `{braces}`) and writing guidance (in `<!-- comments -->`).

---

## 1. Document Control

| Field | Value |
|-------|-------|
| Document ID | {PROJECT-ID}-SOW-{VERSION} |
| Version | {VERSION} |
| Date | {DATE} |
| Status | Draft / Under Review / Approved / Signed |
| Author | {AUTHOR} |

### Approval Signatures

| Role | Name | Signature | Date |
|------|------|-----------|------|
| {CLIENT_ROLE} | {CLIENT_NAME} | | |
| {VENDOR_ROLE} | {VENDOR_NAME} | | |

### Distribution List

| Name | Role | Organization | Access Level |
|------|------|-------------|-------------|
| | | | Full / Read-only / Summary |

<!-- Keep the distribution list current. Include all stakeholders who need to review or be informed. -->

---

## 2. Executive Summary

<!-- 1-2 paragraphs maximum. Answer: Why are we doing this? What will be delivered? What's the business impact? -->

{EXECUTIVE_SUMMARY}

---

## 3. Context & Objectives

### 3.1 Business Context

<!-- Describe the current situation, pain points, and market drivers. Reference any existing systems being replaced or augmented. -->

{BUSINESS_CONTEXT}

### 3.2 Vision & Value Proposition

<!-- What does success look like? How does this create value for the client? -->

{VISION}

### 3.3 Key Performance Indicators

| KPI | Baseline | Target | Measurement Method |
|-----|----------|--------|-------------------|
| {KPI_1} | {BASELINE} | {TARGET} | {METHOD} |

---

## 4. Actors & Roles

### 4.1 User Roles

| Role | Description | Primary Use Cases |
|------|-------------|-------------------|
| {ROLE} | {DESCRIPTION} | {USE_CASES} |

### 4.2 RACI Matrix

| Activity | {ROLE_1} | {ROLE_2} | {ROLE_3} | {ROLE_4} |
|----------|----------|----------|----------|----------|
| {ACTIVITY} | R/A/C/I | R/A/C/I | R/A/C/I | R/A/C/I |

<!-- R = Responsible (does the work), A = Accountable (final decision), C = Consulted (provides input), I = Informed (kept in the loop) -->

---

## 5. Scope

### 5.1 In Scope

<!-- Numbered list of what IS included. Be specific and measurable. -->

1. {IN_SCOPE_ITEM}

### 5.2 Out of Scope

<!-- Numbered list of what is explicitly EXCLUDED. Prevents scope creep disputes. -->

1. {OUT_SCOPE_ITEM}

### 5.3 Assumptions

<!-- Numbered so they can be referenced from other sections (e.g., "per Assumption A3"). -->

- **A1**: {ASSUMPTION}

### 5.4 Constraints

<!-- Hard limits: budget ceiling, regulatory deadlines, technology mandates. -->

- **C1**: {CONSTRAINT}

### 5.5 Dependencies

<!-- External factors the project depends on that are outside the team's control. -->

- **D1**: {DEPENDENCY}

---

## 6. Multi-Phase Breakdown

<!-- Phase 1 is detailed with deliverables and acceptance criteria. Later phases are indicative — they will be detailed as Phase 1 completes (rolling wave planning). -->

### Phase 1: {PHASE_NAME}

**Duration:** {DURATION}
**Objective:** {OBJECTIVE}

| Deliverable | Description | Acceptance Criteria | Owner |
|-------------|-------------|-------------------|-------|
| {DELIVERABLE} | {DESCRIPTION} | {CRITERIA} | {OWNER} |

### Phase 2: {PHASE_NAME} (indicative)

**Duration:** {DURATION} (estimated)
**Objective:** {OBJECTIVE}

| Deliverable | Description | Acceptance Criteria | Owner |
|-------------|-------------|-------------------|-------|
| {DELIVERABLE} | {DESCRIPTION} | {CRITERIA} | {OWNER} |

<!-- Repeat for additional phases. Mark all non-Phase-1 as "(indicative)". -->

---

## 7. Technical Strategy

### 7.1 Architecture Overview

<!-- High-level architecture diagram description. Reference annexes for detailed diagrams. -->

{ARCHITECTURE_OVERVIEW}

### 7.2 Build / Buy / Integrate Decisions

| Component | Decision | Rationale |
|-----------|----------|-----------|
| {COMPONENT} | Build / Buy / Integrate | {RATIONALE} |

### 7.3 Integrations

| System | Direction | Protocol | Data | Frequency |
|--------|-----------|----------|------|-----------|
| {SYSTEM} | Inbound / Outbound / Bidirectional | {PROTOCOL} | {DATA} | {FREQUENCY} |

### 7.4 Non-Functional Requirements

| Category | Requirement | Target | Measurement |
|----------|-------------|--------|-------------|
| Performance | {NFR} | {TARGET} | {METHOD} |
| Security | {NFR} | {TARGET} | {METHOD} |
| Availability | {NFR} | {TARGET} | {METHOD} |
| Scalability | {NFR} | {TARGET} | {METHOD} |

---

## 8. Collaboration Model

### 8.1 Team Composition

| Role | Name | Organization | Allocation % | Billable |
|------|------|-------------|-------------|----------|
| {ROLE} | {NAME} | {ORG} | {PCT}% | Yes/No |

### 8.2 Ceremonies

| Ceremony | Frequency | Duration | Participants | Purpose |
|----------|-----------|----------|-------------|---------|
| {CEREMONY} | {FREQ} | {DUR} | {PARTICIPANTS} | {PURPOSE} |

### 8.3 Governance

<!-- Decision-making authority, escalation paths, steering committee composition. -->

{GOVERNANCE}

### 8.4 Communication

| Channel | Purpose | Frequency | Participants |
|---------|---------|-----------|-------------|
| {CHANNEL} | {PURPOSE} | {FREQ} | {PARTICIPANTS} |

---

## 9. Schedule

### 9.1 Timeline

<!-- Gantt-style overview. Use milestone markers (M1, M2...) that align with Phase 6 deliverables. -->

| Milestone | Description | Target Date | Dependencies |
|-----------|-------------|-------------|-------------|
| M1 | {MILESTONE} | {DATE} | {DEPS} |

### 9.2 Critical Path

<!-- Identify the sequence of activities that determines the minimum project duration. -->

{CRITICAL_PATH}

### 9.3 Mutual Obligations

<!-- What the client must provide and by when. Late delivery of obligations extends the timeline. -->

| Obligation | Owner | Due Date | Impact if Late |
|-----------|-------|----------|---------------|
| {OBLIGATION} | Client / Vendor | {DATE} | {IMPACT} |

---

## 10. Economics

> **[Placeholder]** Run `sow-estimate` on this SOW to generate economics from WBS extraction
> and PERT three-point estimation. This section will be populated with:
> - Effort summary per phase (CAPEX/OPEX breakdown)
> - Rate card and resource allocation
> - Payment schedule aligned with milestones
> - Confidence intervals from PERT analysis

### Template Structure (for manual completion)

### 10.1 Rate Card

| Role | Daily Rate | Currency |
|------|-----------|----------|
| {ROLE} | {RATE} | {CURRENCY} |

### 10.2 Effort Summary

| Phase | Effort (pd) | CAPEX | OPEX |
|-------|------------|-------|------|
| {PHASE} | {EFFORT} | {CAPEX} | {OPEX} |

### 10.3 Payment Schedule

| Milestone | Amount | Cumulative % | Due Date |
|-----------|--------|-------------|----------|
| {MILESTONE} | {AMOUNT} | {PCT}% | {DATE} |

---

## 11. Risk Management

### Risk Register

| ID | Risk | Probability (1-5) | Impact (1-5) | P x I | Strategy | Mitigation | Contingency | Owner |
|----|------|--------------------|-------------|-------|----------|-----------|------------|-------|
| R1 | {RISK} | {P} | {I} | {PxI} | Mitigate/Transfer/Accept/Avoid | {MITIGATION} | {CONTINGENCY} | {OWNER} |

<!-- Risks scoring P x I >= 12 require a mitigation plan. Management reserve covers residual risk. -->

---

## 12. Quality & Acceptance

### 12.1 Quality Standards

<!-- Reference applicable standards: ISO, OWASP, WCAG, internal quality gates. -->

{QUALITY_STANDARDS}

### 12.2 Testing Approach

| Test Type | Scope | Responsibility | Tools |
|-----------|-------|---------------|-------|
| Unit | {SCOPE} | Vendor | {TOOLS} |
| Integration | {SCOPE} | Vendor | {TOOLS} |
| UAT | {SCOPE} | Client | {TOOLS} |

### 12.3 Definition of Done

A deliverable is considered "done" when:
1. All acceptance criteria from Section 6 are met
2. {DOD_CRITERIA}

---

## 13. Change Management

### 13.1 Change Request Process

1. **Submit** — requester fills CR form with description, justification, priority
2. **Assess** — vendor analyzes impact on scope, timeline, budget (within {N} business days)
3. **Approve** — steering committee approves/rejects (for CRs above {THRESHOLD})
4. **Implement** — approved CRs enter the backlog with updated timeline and budget

### 13.2 Impact Categories

| Category | Approval Authority | SLA |
|----------|--------------------|-----|
| Minor (< {THRESHOLD}) | Project Manager | {N} days |
| Major (>= {THRESHOLD}) | Steering Committee | {N} days |
| Critical (scope change) | C-level / Contract Amendment | {N} days |

---

## 14. Other Terms

### 14.1 Intellectual Property
{IP_TERMS}

### 14.2 Privacy & Data Protection
{PRIVACY_TERMS}

### 14.3 Confidentiality
{CONFIDENTIALITY_TERMS}

### 14.4 Warranty
{WARRANTY_TERMS}

### 14.5 Termination
{TERMINATION_TERMS}

---

## 15. Annexes

### Annex A: Requirements Matrix

| ID | Requirement | Priority | Section Ref | Status |
|----|-------------|----------|------------|--------|
| REQ-001 | {REQUIREMENT} | Must/Should/Could | {SECTION} | Open |

### Annex B: Glossary

| Term | Definition |
|------|------------|
| {TERM} | {DEFINITION} |

### Annex C: References

| Document | Version | Location |
|----------|---------|----------|
| {DOCUMENT} | {VERSION} | {LOCATION} |
