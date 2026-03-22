# Statement of Work — Cloud Migration Project

## Project Overview

**Project Name:** Enterprise Cloud Migration
**Client:** Acme Corp
**Start Date:** 2026-09-01
**Project Manager:** PM team
**Stated Target (unrealistic):** 100 pd effort / 40 calendar days

### Background

Acme Corp operates a large on-premises infrastructure hosting 12 business-critical applications
across 3 data centres. The board has mandated a full lift-and-shift + modernisation migration to a
major hyperscaler cloud platform (AWS/Azure) to reduce operational costs and increase resilience.
The scope includes workload assessment, cloud architecture design, infrastructure provisioning,
application migration in three waves, security hardening, performance testing, and production cutover.

This is a high-risk, high-complexity programme. Historical benchmarks for similar migrations
range from 350 to 600+ person-days depending on application complexity and team maturity.
The stated client target of **100 pd** is significantly below any realistic estimate and will be
flagged in the PERT reconciliation section.

---

## Scope of Work

### Teams

| Team | Roles |
|------|-------|
| Technical | Cloud Architect, DevOps Engineer, Security Engineer, Developer |
| Management | PM |

### Roles

| Code | Name | Team | Billable |
|------|------|------|---------|
| CA | Cloud Architect | Technical | Yes |
| DE | DevOps Engineer | Technical | Yes |
| SE | Security Engineer | Technical | Yes |
| DEV | Developer | Technical | Yes |
| PM | Project Manager | Management | Yes |

---

## Phases and Work Breakdown Structure

### Phase 1 — Assessment & Discovery (15–22 d)
**Goal:** Understand the current state of all applications, infrastructure, and dependencies.

#### 1.1 Infrastructure Inventory
- 1.1.1 Server and network inventory catalogue
- 1.1.2 Application dependency mapping
- 1.1.3 Licensing and compliance audit

#### 1.2 Workload Assessment
- 1.2.1 Application portfolio classification (6-R model)
- 1.2.2 TCO and ROI analysis for cloud migration
- 1.2.3 Risk and constraint identification

### Phase 2 — Cloud Architecture & Planning (20–30 d)
**Goal:** Design the target cloud architecture and detailed migration plan.

#### 2.1 Architecture Design
- 2.1.1 Landing zone and network topology design
- 2.1.2 Identity and access management architecture
- 2.1.3 Security controls and compliance framework
- 2.1.4 Disaster recovery and backup strategy

#### 2.2 Migration Planning
- 2.2.1 Wave planning and sequence definition
- 2.2.2 Migration runbook per application (12 apps)
- 2.2.3 Rollback plan definition

### Phase 3 — Infrastructure Setup (25–40 d)
**Goal:** Provision and configure the target cloud environment.

#### 3.1 Landing Zone Provisioning
- 3.1.1 Core account/subscription structure and policies
- 3.1.2 VPC/VNet configuration and peering
- 3.1.3 DNS, load balancers and CDN setup

#### 3.2 Platform Services Configuration
- 3.2.1 Kubernetes cluster setup and hardening
- 3.2.2 CI/CD pipeline infrastructure (GitOps)
- 3.2.3 Monitoring, logging, and alerting stack (Prometheus/Grafana/ELK)
- 3.2.4 Secret management and certificate automation

### Phase 4 — Migration Wave 1 (4 core apps, 30–50 d)
**Goal:** Migrate the first wave of 4 lower-complexity applications.

#### 4.1 Wave 1 Execution
- 4.1.1 Containerisation / refactoring of Wave 1 apps
- 4.1.2 Data migration — Wave 1 databases
- 4.1.3 Integration re-wiring and smoke tests

#### 4.2 Wave 1 Validation
- 4.2.1 Functional regression tests — Wave 1
- 4.2.2 Performance baseline comparison
- 4.2.3 Security scan and remediation — Wave 1

### Phase 5 — Migration Wave 2 (4 medium-complexity apps, 35–55 d)
**Goal:** Migrate the second wave of medium-complexity applications.

#### 5.1 Wave 2 Execution
- 5.1.1 Containerisation / refactoring of Wave 2 apps
- 5.1.2 Data migration — Wave 2 databases
- 5.1.3 Integration re-wiring and smoke tests

#### 5.2 Wave 2 Validation
- 5.2.1 Functional regression tests — Wave 2
- 5.2.2 Performance and load testing — Wave 2
- 5.2.3 Security hardening review — Wave 2

### Phase 6 — Migration Wave 3 (4 high-complexity apps, 40–65 d)
**Goal:** Migrate the final wave of high-complexity, business-critical applications.

#### 6.1 Wave 3 Execution
- 6.1.1 Containerisation / legacy code modernisation — Wave 3
- 6.1.2 Data migration — Wave 3 (large volumes, replication lag management)
- 6.1.3 Integration re-wiring, API gateway config, smoke tests

#### 6.2 Wave 3 Validation
- 6.2.1 Full regression suite — Wave 3
- 6.2.2 End-to-end integration testing
- 6.2.3 Security penetration testing

### Phase 7 — Testing & Validation (20–30 d)
**Goal:** Comprehensive system-wide testing prior to cutover.

#### 7.1 Non-Functional Testing
- 7.1.1 Full load and stress testing (all applications)
- 7.1.2 Chaos engineering / resilience testing

#### 7.2 Acceptance Testing
- 7.2.1 UAT coordination and execution support
- 7.2.2 Defect triage and remediation
- 7.2.3 Sign-off and go-live readiness report

### Phase 8 — Cutover & Stabilisation (15–22 d) [NOT IN JSON — mapped as Phase 7 for this scenario]

> Note: Cutover and stabilisation activities are embedded within Phase 7 for this scenario
> to keep the structure at 7 phases as specified in the SoW.

---

## Risk Register (15 Risks — High-Risk Project)

| ID | Description | Category | Probability | Impact |
|----|-------------|----------|-------------|--------|
| R01 | Cloud Architect resource unavailability | Organizational | 4 | 5 |
| R02 | Application dependency complexity exceeds assessment | Technical | 5 | 4 |
| R03 | Data migration volume / quality issues | Technical | 4 | 5 |
| R04 | Legacy application incompatibility with containers | Technical | 4 | 4 |
| R05 | Cloud provider service outage during migration | External | 3 | 5 |
| R06 | Scope creep from late-discovered applications | Scope | 4 | 3 |
| R07 | Security compliance gap in hardened cloud environment | Security | 3 | 4 |
| R08 | Network performance degradation post-migration | Technical | 3 | 4 |
| R09 | CI/CD pipeline instability blocking deployments | Technical | 3 | 3 |
| R10 | Key personnel departure during critical waves | Organizational | 3 | 4 |
| R11 | Third-party integrations not compatible with new endpoints | External | 4 | 3 |
| R12 | Licensing costs exceeding cloud budget | Financial | 3 | 3 |
| R13 | Inadequate rollback capability for Wave 3 | Technical | 3 | 5 |
| R14 | Regulatory/compliance audit triggered mid-migration | External | 2 | 4 |
| R15 | Client stakeholder unavailability for UAT sign-off | Organizational | 3 | 3 |

---

## Client Target (Unrealistic)

The client has stipulated a **maximum budget of 100 pd** effort and **40 calendar days** to complete
the full migration. This constraint is significantly below the realistic PERT estimate of approximately
400–480 pd and 120–160 calendar days. The PERT analysis below will quantify the gap and provide
the basis for a formal re-scoping discussion.

---

## Effort Basis

- All estimates in **person-days (pd)**, 1 pd = 8 hours
- Duration estimates in **calendar days (d)**
- Billing rate: EUR 650/pd
- Management reserve: 20% (high complexity, high risk)
- PERT formula: E = (O + 4M + P) / 6
