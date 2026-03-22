# Service Agreement — Managed IT Services

**Contract Reference**: MSA-2025-0847
**Effective Date**: January 1, 2026
**Expiration Date**: December 31, 2027
**Amendment**: Amendment 1 (March 15, 2026) — added cloud migration services

## Parties
- **Client**: Adriatic Shipping Consortium S.p.A. ("ASC"), registered office: Trieste, Italy
- **Vendor**: NorthStar IT Services GmbH ("NorthStar"), registered office: Munich, Germany

## Scope of Services (§3)

### 3.1 Infrastructure Management
NorthStar shall manage and maintain ASC's IT infrastructure comprising:
- 12 physical servers (Dell PowerEdge R740)
- VMware vSphere cluster (48 VMs)
- Cisco network equipment (3 sites: Trieste, Venice, Ancona)
- Backup and disaster recovery (Veeam)

### 3.2 Service Desk
- L1 and L2 support during business hours (08:00-18:00 CET, Mon-Fri)
- L3 escalation to vendor specialists within 4 hours
- Ticketing via ServiceNow instance managed by NorthStar

### 3.3 Cloud Migration (Amendment 1)
Migration of 20 VMs from on-premises to Azure, including:
- Assessment and migration planning
- Azure landing zone setup
- VM migration (Azure Migrate)
- Post-migration validation and optimization
- Knowledge transfer to ASC IT team

## Deliverables (§4)

| ID | Deliverable | Acceptance Criteria | Due Date |
|----|-------------|-------------------|----------|
| D1 | Monthly infrastructure health report | All metrics present, no data gaps | Monthly, by 5th |
| D2 | Quarterly security assessment | OWASP Top 10 scan + remediation plan | Quarterly |
| D3 | Azure migration plan | Approved by ASC CTO | April 30, 2026 |
| D4 | Azure landing zone | Passes Well-Architected Review | May 31, 2026 |
| D5 | VM migration (batch 1: 10 VMs) | All VMs operational, SLA met for 5 days | July 31, 2026 |
| D6 | VM migration (batch 2: 10 VMs) | All VMs operational, SLA met for 5 days | September 30, 2026 |
| D7 | Knowledge transfer package | 3 ASC engineers certified on Azure | October 31, 2026 |

## SLAs (§5)

| Metric | Target | Penalty |
|--------|--------|---------|
| Infrastructure uptime | 99.5% monthly | 2% credit per 0.1% below target |
| P1 incident response | < 30 minutes | EUR 500 per breach |
| P2 incident response | < 2 hours | EUR 200 per breach |
| P3 incident response | < 8 hours | No penalty |
| Ticket resolution (L1) | < 4 hours | Tracked, no penalty |
| Monthly report delivery | By 5th of month | EUR 100 per day late |

## Pricing (§6)

| Service | Monthly Fee | Annual Total |
|---------|-----------|-------------|
| Infrastructure management | EUR 18,500 | EUR 222,000 |
| Service desk (L1+L2) | EUR 8,200 | EUR 98,400 |
| Cloud migration (fixed) | — | EUR 145,000 |
| **Total Year 1** | | **EUR 465,400** |

Payment terms: Net 30 from invoice date. Migration milestones invoiced upon acceptance.

## Team (§7)

| Role | Name | Allocation |
|------|------|-----------|
| Account Manager | Klaus Richter | 20% |
| Infrastructure Lead | Marco Bianchi | 100% |
| Service Desk Lead | Anna Kowalski | 100% |
| Cloud Architect | Stefan Weber | 50% (migration phase) |
| Migration Engineer | Elena Popov | 100% (migration phase) |

## Governance (§8)
- Monthly service review meeting (ASC IT Director + NorthStar Account Manager)
- Quarterly steering committee (ASC CTO + NorthStar VP Services)
- Change requests: assessed within 5 business days, approved by ASC IT Director (< EUR 10,000) or ASC CTO (>= EUR 10,000)

## Confidentiality (§9)
Standard mutual NDA. All ASC data classified as confidential. NorthStar personnel require ASC security clearance for on-site access.

## Termination (§10)
- For convenience: 90 days written notice
- For cause: 30 days cure period after written notice of breach
- Transition assistance: 3 months at current rates after termination
