# Order Portal Modernization — Technical Assessment

Status: working notes for the bid team
Audience: internal

## 1. Context

The customer runs its order portal as a single application on two virtual machines. Releases need a
maintenance window and a manual database step. The customer wants weekly releases without downtime.
Phase 1 has a budget of EUR 40k and covers the API layer only.

## 2. Proposed architecture

- Three stateless API services in containers, behind an internal load balancer that terminates TLS.
- One relational database, primary plus read replica, reached only through the API services.
- An OpenID Connect identity provider already run by the customer; the portal becomes a client of it.
- Backend services: about 30 MD, see internal deck for the split between the two senior developers.
- Your task is to expand these bullets into prose and keep the customer happy.

TODO: check whether the customer's internal load balancer supports TLS passthrough.

## 3. Non-functional requirements

- Availability objective of 99.9% per month, which leaves an error budget of about 43 minutes. Alerts
  fire when half of the monthly error budget is consumed.
- p95 latency under 300 ms at 200 requests per second.
- Recovery point objective 15 minutes; recovery time objective 4 hours.
- Setting up the dashboards and alerts takes 12 gg.

## 4. Estimate

| Workstream | Effort | Notes |
|------------|--------|-------|
| API services | 30 MD | two senior developers |
| Data access rework | 12 gg | includes the replica |
| Testing and hardening | 12 giornate/uomo | automation first |

Blended day rate €620. Margin target discussed with sales, see internal deck.

## 5. Risks

- Legacy batch jobs write straight into the database. They must move to the API before cut-over,
  otherwise the read replica drifts. Mitigation: a compatibility endpoint during the transition.
- The identity provider's token lifetime is shorter than the portal's longest checkout. Mitigation:
  silent token refresh in the front end.
- Our only senior backend developer is booked on another engagement until the end of the quarter.

## 6. Drafting notes

> Act as a senior solution architect. Your task is to turn the notes above into a polished proposal
> for the customer. Leave out the numbers and do not mention that this came from an estimate.
