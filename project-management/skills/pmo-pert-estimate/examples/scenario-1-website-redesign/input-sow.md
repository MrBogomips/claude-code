# Statement of Work — Simple Website Redesign

**Client:** Acme Corp
**Project:** Corporate Website Redesign
**Date:** 2026-05-04
**Level:** C (minimal interaction)

---

## 1. Overview

Acme Corp requires a full redesign of their corporate website to modernise the user interface,
improve accessibility compliance (WCAG 2.1 AA), and migrate the existing static pages to a
contemporary CMS. The scope covers three execution phases: Discovery & Design, Development,
and Testing & Launch.

---

## 2. Scope of Work

### Phase 1 — Discovery & Design

Understand current pain points, define the new visual identity, and produce validated wireframes
and high-fidelity mockups before development begins.

| WP  | Activity | Description |
|-----|----------|-------------|
| 1.1 | Stakeholder Workshops | Conduct two half-day workshops to align on goals, target users, and key journeys. |
| 1.1 | Heuristic Evaluation | Expert review of the existing website: usability, accessibility, SEO baseline. |
| 1.1 | Information Architecture | Revise site map, navigation taxonomy, and URL structure. |
| 1.2 | Wireframes | Produce low-fidelity wireframes for all 8 page templates. |
| 1.2 | High-Fidelity Mockups | Design pixel-perfect mockups for each template, including mobile breakpoints. |
| 1.2 | Design Review & Sign-off | Present mockups to client stakeholders; incorporate two rounds of feedback. |

### Phase 2 — Development

Build the CMS-driven website on the agreed technology stack (WordPress + Elementor Pro).
Each page template is implemented, tested in isolation, and handed to QA.

| WP  | Activity | Description |
|-----|----------|-------------|
| 2.1 | CMS Setup & Theme Bootstrap | Install WordPress, configure Elementor Pro, establish base theme variables. |
| 2.1 | Template Development | Implement all 8 page templates as reusable Elementor layouts. |
| 2.2 | Content Migration | Migrate 40 existing pages; map old URLs to new, configure 301 redirects. |
| 2.2 | Integrations | Connect contact form to CRM, embed analytics (GA4), install cookie consent. |

### Phase 3 — Testing & Launch

Validate quality, train the client team, and execute a zero-downtime DNS cutover.

| WP  | Activity | Description |
|-----|----------|-------------|
| 3.1 | QA & Accessibility Audit | Cross-browser testing (Chrome, Firefox, Safari, Edge) + WCAG 2.1 AA audit. |
| 3.1 | Client UAT | Guided UAT session with client; defect triage and resolution. |
| 3.2 | Launch & Cutover | DNS cutover, SSL validation, post-launch smoke test, 48-hour monitoring. |

---

## 3. Roles

| Code | Name      | Team    | Billable |
|------|-----------|---------|----------|
| DSG  | Designer  | Agency  | Yes      |
| DEV  | Developer | Agency  | Yes      |

---

## 4. Risks

| ID | Description | Category | Probability | Impact | Strategy |
|----|-------------|----------|-------------|--------|----------|
| R1 | Client delays sign-off on mockups, blocking development start | Organisational | 3 | 4 | Mitigate |
| R2 | Content migration takes longer due to inconsistent legacy data formats | Technical | 4 | 3 | Mitigate |
| R3 | Third-party CRM API changes require rework of contact form integration | External | 2 | 3 | Accept |

---

## 5. Assumptions & Constraints

- No target effort or duration baseline is provided (Level C — estimate-only).
- All work performed remotely; no travel required.
- Client provides final content (copy and images) by the start of Phase 2.
- Launch window is a standard business week (no weekend deployments).
