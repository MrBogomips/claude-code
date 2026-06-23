# Information Extraction Principles

Apply these when analyzing the source to build the working model that feeds the 13 sections. The goal
is decision support for commercial and delivery stakeholders — not a faithful reproduction of the
source.

## Principles

- **Prioritize actionable information** — keep what affects planning, staffing, effort, risk,
  schedule, or commercial decisions; drop the rest.
- **Consolidate duplicated information** — merge repeated statements into a single clear entry.
- **Reconcile inconsistent estimates** — when the source gives conflicting figures, reconcile them
  where possible and note the basis; where they cannot be reconciled, surface the discrepancy as an
  ambiguity.
- **Highlight ambiguities** — anything unclear or open to interpretation is flagged, not glossed over.
- **Explicitly identify missing information** — list what a planner would need but the source does not
  provide. Missing information is a first-class output (it feeds the Bid Review Checklist), never a
  silent omission.
- **Preserve assumptions and constraints** — keep those that affect delivery, and the estimation
  rationale behind figures when it matters for planning decisions.
- **Exclude unnecessary implementation detail** — algorithm-level design, code structure, and
  architectural deep-dives are out of scope unless they drive effort, risk, or staffing.

## What "actionable" means here

A detail is actionable if a sales, bid, delivery, or resource manager would change a decision based on
it: team composition, effort validation, schedule commitment, risk to raise with the customer, a cost
driver, or a clarification to request before bidding. If it would not change such a decision, it is
implementation detail and belongs elsewhere — not in this summary.

## Handling thin or AI-generated sources

When the source is sparse, contradictory, or AI-generated:
- Do not fabricate effort, roles, risks, or figures to fill gaps — record them as missing instead.
- Translate condensed or fragmentary notes into clear entries without inventing substance.
- Let the volume of flagged gaps and ambiguities inform the Bid Readiness Conclusion and the Delivery
  Confidence Level.
