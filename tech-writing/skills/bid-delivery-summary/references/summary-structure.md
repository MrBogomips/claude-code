# Internal Summary Structure

The document opens with the language pack's verbatim confidentiality notice (`INTERNAL USE ONLY`, or
`SOLO PER USO INTERNO` in Italian), then the 13 sections below in order. Prefer structured sections, tables, bullet points, and action-oriented
language. Keep each section to what is useful for commercial and delivery decision-making; exclude
implementation detail that does not affect planning, staffing, effort, risk, schedule, or commerce.

## 1. Executive Summary

A concise overview for commercial and delivery leadership:
- Project objective
- Business value
- Scope boundaries
- Main delivery challenges
- Estimated implementation complexity
- Key success factors

## 2. Scope Summary

What is being delivered (not how it is implemented):
- Functional domains
- Major business capabilities
- Key features
- Integrations
- Infrastructure implications
- Significant non-functional requirements

## 3. Resource Requirements

All required roles and competencies. Present as a table. Draw roles from the source; typical roles
include Solution Architect, Enterprise Architect, Technical Lead, Senior/Front-End/Back-End/Full-Stack
Developer, DevOps Engineer, QA Engineer, Test Automation Engineer, Business Analyst, Project Manager,
Scrum Master, Data Engineer, Security Specialist, UX/UI Designer.

| Role | Primary Responsibilities | Estimated Effort (PD) | Involvement Level | Allocation Profile | Key Dependencies |
|------|--------------------------|-----------------------|-------------------|--------------------|------------------|

## 4. Effort Estimation Summary

- Total estimated effort
- Breakdown by workstream
- Breakdown by phase
- Breakdown by role
- Major effort drivers
- Areas of estimation uncertainty
- Confidence level of the estimate

Clearly distinguish **Confirmed**, **Estimated**, **Assumed**, and **Contingency** effort (when
identified). All values in PD/MD.

## 5. Resource Allocation Plan

A high-level staffing and allocation model to support planning:
- Recommended team composition
- Ramp-up and ramp-down activities
- Peak resource demand
- Critical resource constraints and bottlenecks
- Recommended sequencing of resource onboarding

## 6. High-Level Activities

Major activities (e.g., Discovery, Requirements Analysis, Architecture Definition, Solution Design,
Development, Integration, Data Migration, Testing, User Acceptance Testing, Deployment, Hypercare,
Knowledge Transfer). For each:
- Objective
- Estimated effort (PD)
- Main deliverables

## 7. Milestones

Major milestones (e.g., Project Kickoff, Requirements Baseline, Architecture Approval, Design
Sign-off, Development Completion, Integration Completion, Test Completion, UAT Completion, Go-Live,
Hypercare Completion). Where possible, indicate dependencies, entry criteria, and exit criteria.

## 8. Assumptions

Consolidate all relevant assumptions: scope, business, technical, infrastructure, data, customer
responsibilities, third-party responsibilities, governance, resource. Highlight assumptions that
materially impact cost, effort, schedule, or scope.

## 9. Risks

Categorize risks (Delivery, Technical, Integration, Resource, Schedule, Commercial, Dependency,
Organizational, Security). Present as a table using Low / Medium / High for probability and impact.

| Risk | Category | Probability | Impact | Mitigation |
|------|----------|-------------|--------|------------|

## 10. Dependencies

Summarize customer, third-party, platform, infrastructure, vendor, and internal organizational
dependencies. Clearly identify critical-path dependencies.

## 11. Commercial Considerations

**Cost-authorized mode** (an approved cost model was found and the user confirmed in Step 3) — open
with the **cost basis**: the cost model used (name, and version or date when it has one), where it was
found, and who authorized its use. Then include: estimated costs, cost breakdown, cost drivers,
commercial assumptions, optional scope items, areas impacting profitability, pricing sensitivities.

**Effort-only mode** (default) — include only this statement and no cost figures:

> Cost calculations have not been included because no approved internal costing model was provided or
> authorized.

## 12. Bid Review Checklist

A structured bid-readiness review.

**Scope Clarifications** — missing requirements, ambiguous requirements, scope boundaries requiring
confirmation, potential scope-creep areas.

**Commercial Clarifications** — cost-affecting assumptions, optional scope items, licensing
uncertainties, third-party costs requiring validation, commercial constraints. In effort-only mode,
when the source quotes cost figures, include the language pack's "unapproved cost figures" item and
where those figures appear, without the figures (`cost-model-verification.md`).

**Delivery Clarifications** — unconfirmed timelines, scheduling dependencies, customer-participation
requirements, approval-process assumptions, governance concerns.

**Technical Clarifications** — pending architecture decisions, missing integration details, data
migration uncertainties, security requirements requiring validation, infrastructure uncertainties,
performance and scalability assumptions.

**Risk Review** — risks to discuss explicitly before proposal submission, contract signature, or
delivery commitment. For each: description, potential impact, recommended clarification.

**Customer Questions** — a prioritized list of questions to resolve before finalizing scope,
estimates, schedule, staffing, and the commercial proposal. Classify each as **Critical**,
**Important**, or **Nice to Have**.

**Bid Readiness Conclusion** — exactly one of:
- **Ready for Proposal**
- **Ready for Proposal with Assumptions**
- **Clarifications Recommended Before Proposal**
- **Significant Unknowns – Proposal Risk Elevated**

Include a concise rationale.

## 13. Delivery Readiness Assessment

A final delivery-focused assessment:
- Overall delivery confidence level
- Main delivery strengths
- Main delivery concerns
- Key unknowns
- Staffing readiness
- Technical readiness
- Governance readiness
- Dependency readiness

**Confidence Level** — exactly one of: **High**, **Medium**, **Low**.

**Recommended Next Actions** — concrete actions for Sales, Delivery Management, Solution Architecture,
and Project Management.

**Executive Recommendation** — a final recommendation on proposal readiness, delivery feasibility, and
areas requiring further investigation.
