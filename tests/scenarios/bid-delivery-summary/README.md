# bid-delivery-summary Test Scenarios

Layer 2 scenarios for the `tech-writing:bid-delivery-summary` skill. They check the cost-model gate
with objective tests: prices quoted in the source never reach an effort-only summary but are raised
as a clarification, the confidentiality notice follows the language pack, and an authorized cost
model is recorded with its approver.

## Setup

1. Create a scratch project outside any git repository whose `CLAUDE.md` declares the deliverables
   folder:

   ```markdown
   ## Working documents
   - Deliverables: `out/`
   ```

2. Copy the fixtures the scenario names into it.
3. Load the plugin (`claude --plugin-dir ./tech-writing`) or install it from the marketplace, and
   start the session in the scratch project.

All fixture content is fictional and anonymized.

## Fixtures

| File | Content |
|------|---------|
| fixture-assessment-with-prices.md | Assessment with effort in PD and two prices quoted in passing (no rate card) |
| fixture-rate-card.md | A versioned internal rate card that qualifies as an approved cost model |

## Scenarios

| File | What it tests |
|------|--------------|
| scenario-unapproved-price.md | Effort-only output with a Commercial Clarifications item and no figures (English and Italian); cost basis and approver recorded when a rate card is authorized |
