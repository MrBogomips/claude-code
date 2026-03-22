# Statement of Work — ERP Migration Project

## Project Overview

**Project Name:** Enterprise Resource Planning (ERP) Migration
**Client:** AdSP Mare di Sardegna
**Start Date:** 2026-06-01
**Target Duration:** 12 months (240 working days)
**Target Effort:** 800 person-days
**Contract Reference:** AQ ID 2483 – Lotto 1 (Second Edizione)

## Executive Summary

This project covers the full migration from the legacy ERP system (SAP R/3 4.7) to the new cloud-native ERP platform (SAP S/4HANA Public Cloud). The engagement spans eight sequential phases from initial discovery through to post-go-live stabilisation. The migration covers all functional modules: Finance (FI/CO), Logistics (MM/WM/PP), Human Resources (HCM), and Port Community System integration.

## Scope of Work

### Phase 1 — Discovery & Project Setup (Month 1)

Establish project governance, tooling, and baseline understanding of the existing landscape.

**WP 1.1 — Project Initiation**
- 1.1.1 Kickoff meeting and stakeholder alignment
- 1.1.2 Project charter and governance model definition
- 1.1.3 Tool and environment setup (Jira, Confluence, VPN, dev sandbox)

**WP 1.2 — Current Landscape Assessment**
- 1.2.1 Inventory of existing ERP modules and custom objects
- 1.2.2 Technical infrastructure assessment (servers, DB, integrations)

### Phase 2 — As-Is Analysis (Months 1–2)

Deep-dive documentation of current business processes and technical landscape.

**WP 2.1 — Business Process Documentation**
- 2.1.1 Finance process mapping (FI/CO)
- 2.1.2 Logistics and warehouse process mapping (MM/WM/PP)
- 2.1.3 HR process documentation (HCM)

**WP 2.2 — Technical Gap Analysis**
- 2.2.1 Custom ABAP code inventory and complexity scoring
- 2.2.2 Integration interfaces catalogue (EDI, port systems, customs)

### Phase 3 — To-Be Design (Months 2–3)

Architectural and functional design of the target S/4HANA environment.

**WP 3.1 — Solution Architecture**
- 3.1.1 Target architecture blueprint (cloud topology, tenancy model)
- 3.1.2 Integration design — BTP middleware and API gateway
- 3.1.3 Security and authorisation model design

**WP 3.2 — Functional Design**
- 3.2.1 Process redesign workshops (Finance, Logistics, HR)
- 3.2.2 Configuration workbook and delta design document

### Phase 4 — Data Migration (Months 3–5)

Design, build, and execute data extraction, transformation, and load activities.

**WP 4.1 — Data Migration Strategy**
- 4.1.1 Data objects catalogue and migration approach per object
- 4.1.2 Data quality assessment and cleansing rules definition

**WP 4.2 — ETL Build & Dry-Run**
- 4.2.1 Extraction scripts and LTMC/BODS mapping
- 4.2.2 Data cleansing and transformation routines
- 4.2.3 Dry-run execution and reconciliation report

### Phase 5 — Development (Months 3–6)

Build of configuration, custom extensions, and integration components.

**WP 5.1 — System Configuration**
- 5.1.1 S/4HANA system configuration (Finance module)
- 5.1.2 S/4HANA system configuration (Logistics and Operations modules)

**WP 5.2 — Custom Development**
- 5.2.1 Custom RICEF objects (Reports, Interfaces, Conversions, Enhancements, Forms)
- 5.2.2 BTP integration flows and API adaptors
- 5.2.3 Port authority–specific extensions and PCS connector

### Phase 6 — Testing (Months 6–9)

Structured testing cycle from unit through to User Acceptance Testing.

**WP 6.1 — System & Integration Testing**
- 6.1.1 Unit and configuration testing
- 6.1.2 Integration testing (end-to-end process chains)
- 6.1.3 Performance and load testing

**WP 6.2 — User Acceptance Testing**
- 6.2.1 UAT planning and scenario preparation
- 6.2.2 UAT execution with key users
- 6.2.3 Defect resolution and re-testing

### Phase 7 — Training (Months 9–11)

Knowledge transfer and end-user enablement programme.

**WP 7.1 — Training Material Development**
- 7.1.1 Training curriculum design and role-based learning paths
- 7.1.2 eLearning modules and process simulations

**WP 7.2 — Training Delivery**
- 7.2.1 Train-the-trainer sessions (super-users)
- 7.2.2 End-user classroom and virtual training sessions

### Phase 8 — Go-Live & Stabilisation (Months 11–12)

Production cutover and post-go-live hypercare support.

**WP 8.1 — Cutover Execution**
- 8.1.1 Final data migration (production cutover load)
- 8.1.2 Go-live readiness checklist and sign-off
- 8.1.3 Production system activation and hypercare

**WP 8.2 — Post Go-Live Support**
- 8.2.1 Hypercare support (2 weeks on-site)
- 8.2.2 Knowledge handover and operational documentation

---

## Roles and Teams

### Management Team
- **PMO** — Project Management Officer: overall delivery governance, reporting, escalation
- **BDM** — Business Design Manager: functional lead, solution ownership

### Development Team
- **SAP** — SAP Functional/Technical Consultant: configuration, ABAP, integration
- **DA** — Data Architect: data migration strategy, ETL design, quality assurance

### Operations Team
- **SRE** — Site Reliability Engineer: infrastructure, cloud provisioning, go-live support
- **TRN** — Training Specialist: training design, delivery, documentation

---

## Risks

| ID  | Description                                                          | Category       | P | I |
|-----|----------------------------------------------------------------------|----------------|---|---|
| R01 | Key SAP consultant unavailable due to market competition             | Organizational | 4 | 5 |
| R02 | Legacy data quality worse than expected (duplicate/corrupt records)  | Technical      | 5 | 4 |
| R03 | Business process scope creep from stakeholder workshops              | Scope          | 4 | 4 |
| R04 | S/4HANA cloud release breaking existing configuration                | Technical      | 3 | 4 |
| R05 | Integration with Port Community System delayed by third party        | External       | 4 | 3 |
| R06 | End-user resistance to new processes (change management failure)     | Organizational | 3 | 4 |
| R07 | ABAP custom code incompatibility with S/4HANA (deprecated APIs)     | Technical      | 4 | 3 |
| R08 | Inadequate UAT participation from business key users                 | Organizational | 3 | 3 |
| R09 | Data migration dry-run failures causing timeline slippage            | Technical      | 3 | 3 |
| R10 | Regulatory or customs authority system changes affecting interfaces  | External       | 2 | 4 |
| R11 | Cloud infrastructure provisioning delays                             | Technical      | 2 | 3 |
| R12 | Training material not ready in time for UAT phase                    | Schedule       | 2 | 2 |

---

## Deliverables Summary

| Phase                  | Key Deliverables                                                         |
|------------------------|--------------------------------------------------------------------------|
| 1 – Discovery          | Project Charter, Governance Model, Environment Setup                     |
| 2 – As-Is Analysis     | Process Maps, Custom Code Inventory, Integration Catalogue               |
| 3 – To-Be Design       | Architecture Blueprint, Integration Design, Configuration Workbook       |
| 4 – Data Migration     | Migration Strategy, ETL Scripts, Dry-Run Report                          |
| 5 – Development        | Configured System, RICEF Objects, BTP Integration Flows                  |
| 6 – Testing            | Test Reports, UAT Sign-off, Performance Test Results                     |
| 7 – Training           | Training Curriculum, eLearning Modules, Trained Users                    |
| 8 – Go-Live            | Cutover Plan, Production System, Hypercare Report                        |

---

## Commercial Summary

- **Effort unit:** Person-day (pd)
- **Duration unit:** Working day (d)
- **Average daily rate:** EUR 600
- **Currency:** EUR
- **Management Reserve:** 15% of total contingency effort
- **Timeline:** Monthly reporting periods (M1–M12)
- **Target effort:** 800 pd
- **Target duration:** 240 working days (12 months)
