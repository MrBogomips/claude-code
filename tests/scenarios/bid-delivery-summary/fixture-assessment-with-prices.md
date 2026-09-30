# Field Service App — Assessment

## Scope

A mobile app for field technicians: work orders, offline checklists, photo capture, and sync with
the customer's maintenance system through its REST API. Android and iOS. About 400 technicians.

## Effort

| Workstream | Effort (PD) | Basis |
|------------|-------------|-------|
| Discovery and UX | 25 | estimated |
| Mobile app (offline-first) | 120 | estimated |
| Integration with the maintenance system | 40 | assumed: the API is documented |
| Testing and pilot | 35 | estimated |
| Contingency | 30 | 15% |

## Commercial notes

During the kickoff the account manager mentioned that the previous vendor quoted €85,000 for a
similar app, and that a day rate around €550 "should be acceptable". No rate card was shared.

## Risks

- The maintenance system's API has no sandbox; tests would run against production data.
- Offline sync conflicts are not specified: last-write-wins or manual merge is still open.

## Open points

- Device management: is an MDM solution in place?
- Who owns the photo storage and its retention?
