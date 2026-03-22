# Statement of Work — Mobile App MVP

## Project Overview

**Project Name:** Mobile App MVP — Field Operations Management
**Client:** TechCorp Industries
**Estimation Level:** Level A (Formative)
**Date:** 2026-06-01
**Currency:** EUR
**Avg Daily Rate:** 550 EUR/pd

---

## Estimation Context (Level A — Formative)

This is a **formative estimate** (Level A), produced at early project conception with
limited requirements definition. Uncertainty bands are wide by design. The estimate
should be revisited at Level B (budgetary) once UX mockups and backend architecture
are approved.

---

## Scope Summary

A cross-platform mobile application (iOS + Android) enabling field technicians to:
- Create and manage work orders on-device
- Capture photos and digital signatures
- Sync data with the central backend when online
- Receive push notifications for urgent assignments

---

## Roles

| Code | Name          | Team        | Billable |
|------|---------------|-------------|----------|
| PO   | Product Owner | Product     | true     |
| MOB  | Mobile Dev    | Engineering | true     |
| BED  | Backend Dev   | Engineering | true     |
| QA   | QA Engineer   | Engineering | true     |

**Teams:** Product (1 role), Engineering (3 roles)

---

## Phases and Activities

### Phase 1 — Discovery (2 weeks)

**1.1 Project Kickoff**
- 1.1.1 Stakeholder workshop (PO) — best 2d / likely 3d / worst 5d
- 1.1.2 Requirements elicitation (PO, BED) — best 3d / likely 5d / worst 8d

**1.2 Technical Feasibility**
- 1.2.1 Technology stack selection (MOB, BED) — best 1d / likely 2d / worst 3d
- 1.2.2 Architecture draft (BED) — best 2d / likely 3d / worst 5d

---

### Phase 2 — UX Design (3 weeks)

**2.1 Wireframing**
- 2.1.1 User flow mapping (PO) — best 2d / likely 3d / worst 5d
- 2.1.2 Low-fidelity wireframes (MOB, PO) — best 3d / likely 4d / worst 6d

**2.2 Prototyping**
- 2.2.1 Interactive prototype (MOB) — best 3d / likely 5d / worst 8d
- 2.2.2 Usability review (PO, QA) — best 1d / likely 2d / worst 4d
- 2.2.3 Design iteration (MOB) — best 2d / likely 3d / worst 5d

---

### Phase 3 — Backend Development (5 weeks)

**3.1 Core API**
- 3.1.1 Auth & user management API (BED) — best 3d / likely 5d / worst 8d
- 3.1.2 Work order CRUD API (BED) — best 4d / likely 6d / worst 10d
- 3.1.3 File upload API (BED) — best 2d / likely 3d / worst 5d

**3.2 Infrastructure**
- 3.2.1 Cloud environment setup (BED) — best 2d / likely 3d / worst 4d
- 3.2.2 Push notification service (BED, MOB) — best 2d / likely 3d / worst 5d
- 3.2.3 Backend integration tests (QA, BED) — best 3d / likely 4d / worst 7d

---

### Phase 4 — Mobile Development (6 weeks)

**4.1 Core Features**
- 4.1.1 Offline data sync module (MOB) — best 4d / likely 6d / worst 10d
- 4.1.2 Work order UI (MOB) — best 5d / likely 7d / worst 12d
- 4.1.3 Photo & signature capture (MOB) — best 3d / likely 4d / worst 7d

**4.2 Integration & Testing**
- 4.2.1 Backend integration (MOB, BED) — best 3d / likely 5d / worst 8d
- 4.2.2 Mobile E2E testing (QA) — best 4d / likely 5d / worst 8d

---

### Phase 5 — Launch (2 weeks)

**5.1 Release**
- 5.1.1 App store submission (MOB, PO) — best 2d / likely 3d / worst 5d
- 5.1.2 UAT with pilot users (QA, PO) — best 3d / likely 4d / worst 6d
- 5.1.3 Go-live & monitoring (BED, MOB) — best 2d / likely 3d / worst 5d

---

## Risks

| ID | Description                                     | Category       | P | I | Strategy |
|----|-------------------------------------------------|----------------|---|---|----------|
| R1 | App store approval delays                       | External       | 3 | 3 | Mitigate |
| R2 | Offline sync complexity underestimated          | Technical      | 4 | 5 | Mitigate |
| R3 | Key mobile developer unavailability             | Organizational | 2 | 5 | Mitigate |
| R4 | Third-party push notification service outage    | External       | 2 | 3 | Accept   |
| R5 | Scope creep from stakeholder change requests    | Organizational | 4 | 4 | Mitigate |
| R6 | iOS/Android compatibility fragmentation issues  | Technical      | 3 | 3 | Mitigate |

---

## Notes

- Estimate validity: 60 days from issue date
- Management reserve: 10% of total adjusted effort
- Period type: Biweekly
- Project start: 2026-07-01
