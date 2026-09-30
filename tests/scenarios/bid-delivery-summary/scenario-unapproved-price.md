# Scenario: Prices in the Source Without an Approved Cost Model

## Setup

Fresh scratch project outside git whose `CLAUDE.md` declares `out/` as the deliverables folder.
Copy `fixture-assessment-with-prices.md` into it. The fixture quotes €85,000 and a €550 day rate in
passing; there is no rate card.

## Invocation

### Case A — effort-only, English

"Is this ready to bid? Give me the internal summary of fixture-assessment-with-prices.md." Confirm
the section plan as proposed.

### Case B — effort-only, Italian

Fresh folder. "Mi fai il riepilogo interno per l'offerta di fixture-assessment-with-prices.md?"
Confirm the language the skill recommends (Italian is the language of the conversation; the source
is English) and the section plan.

### Case C — approved cost model

Fresh folder, with `fixture-rate-card.md` copied in as well. Same request as Case A.

## Expected Behavior

1. Step 3 finds no approved cost model in Cases A and B: the quoted figures are not one
2. The output is effort-only, and Commercial Considerations carries only the effort-only statement
3. The Bid Review Checklist's Commercial Clarifications carry the language pack's "unapproved cost
   figures" item, naming where the figures appear (the Commercial notes section), without any figure
4. In Case C the skill names the rate card, asks for explicit confirmation and whose authorization to
   record, and writes nothing about costs before the answer

## Acceptance Criteria

Case A:
- [ ] The file starts with `# INTERNAL USE ONLY`
- [ ] `grep -nE '€|EUR|[Ee]uro|85[.,]?000|550' out/*-internal-summary-v1.md` prints nothing
- [ ] Commercial Considerations contains exactly the English effort-only statement from the language pack
- [ ] Commercial Clarifications contain "The source quotes cost figures that no approved costing model backs" and point to the Commercial notes section
- [ ] Effort is in PD, with Estimated, Assumed and Contingency distinguished

Case B:
- [ ] The file starts with `# SOLO PER USO INTERNO`, and Self-Check 1 accepts it (the skill does not add an English header)
- [ ] The same `grep` prints nothing
- [ ] The Commercial Clarifications carry the Italian verbatim item ("Il documento di origine riporta cifre di costo non supportate…")

Case C:
- [ ] Before any cost figure is written, the skill asks to confirm use of "Approved Rate Card — Delivery Services (version 3)" and asks whose authorization to record
- [ ] Reply "Yes, use it; record the bid manager as authorizer" → Commercial Considerations opens with the cost basis: the rate card's name and version, where it was found, and "Authorized by: bid manager"
- [ ] Reply "No" instead → the output is as in Case A
