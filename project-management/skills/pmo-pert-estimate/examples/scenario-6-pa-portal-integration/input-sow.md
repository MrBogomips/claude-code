# Scenario 6 — Public-Sector Portal Integration (Anonymized)

## Project Overview

The agency is launching a new public-facing portal that aggregates
authoritative data from three back-office systems (registry, payments,
case management) into a single citizen-facing service. The portal reuses
patterns from a previously-delivered sister portal but extends them with
new integrations, an accessibility audit, and a UAT phase aligned with
the agency's quarterly release window.

## Objectives

- Deliver a citizen-facing portal that meets WCAG 2.1 AA and the agency's
  digital service standard.
- Integrate three internal authoritative sources via a service-bus layer
  already in place from the sister portal.
- Pass a security and accessibility audit before production release.

## Scope

### In scope

- Front-end (responsive UI, accessibility audit, branding alignment)
- Back-end (REST APIs, business logic, audit logging)
- Three integrations (registry, payments, case-management)
- DevOps (CI/CD, environments, monitoring), reusing the sister portal's
  baseline configuration
- UAT with the agency's testers
- Documentation (user manual, ops runbook, accessibility statement)

### Out of scope

- Identity provider (uses the agency's existing IdP)
- Hosting (existing private cloud)
- End-user training (agency PR team handles communication)

## Constraints

- Quarterly release window — go-live must land in a specific 2-week slot
- Accessibility audit gate must be passed before UAT
- Two parallel integration vendors with different SLAs — overlap of
  integration phase with core build is expected
- The contracting authority requires explicit Management Reserve at 20%

## Phases (planned)

| Phase | Description | Indicative weeks |
|-------|-------------|------------------|
| F0 | Setup & Discovery | 1-2 |
| F1 | UX & Functional Design | 3-5 |
| F2 | Core Build | 6-15 |
| F3 | Integrations (parallel with F2) | 8-15 |
| F4 | Security & Accessibility audit | 16-18 |
| F5 | Internal acceptance | 17-19 |
| F6 | UAT | 19-22 |
| F7 | Production deployment & hypercare | 22-25 |

## Roles (RBS)

- PM (Project Manager, billable)
- TA (Technical Architect, billable)
- BA (Business Analyst, billable)
- UX (UX Designer, billable)
- FE (Front-end Developer, billable)
- BE (Back-end Developer, billable)
- INT (Integration Specialist, billable)
- QA (Quality Assurance, billable)
- DEVOPS (DevOps Engineer, billable)
- DOC (Technical Writer, billable)

## Notes

This scenario is anonymized and intentionally generic. Any resemblance
to specific public-sector projects is incidental — it illustrates a
**class** of PA portal-with-integrations engagements, not a particular
client deliverable. Effort numbers are illustrative.
