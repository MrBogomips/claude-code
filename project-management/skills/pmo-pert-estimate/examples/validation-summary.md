# PMO PERT Estimate — Example Scenarios

Six example estimates, each with its input SOW (`input-sow.md`), the generator input
(`excel-input.json`) and the generated workbook (`pert-estimate.xlsx`). All clients, contract
references and names in them are fictional. `sample-input.json` is the smallest complete input
and the one to copy when writing a new `excel-input.json`.

## What each scenario exercises

| Scenario | Lang | Phases / activities | Risks (high) | What it covers |
|----------|------|---------------------|--------------|----------------|
| 1 — Website redesign | en | 3 / 13 | 3 (2) | Level C, no targets, a small team |
| 2 — ERP migration | en | 8 / 40 | 12 (7) | Large multi-team estimate with a stated effort target |
| 3 — Mobile app | en | 5 / 23 | 6 (3) | Level A (formative), wide uncertainty ranges |
| 4 — Cloud migration | en | 7 / 44 | 15 (11) | An unrealistic target that forces reconciliation |
| 5 — Consulting | en | 4 / 17 | 5 (3) | Effort in hours instead of person-days |
| 6 — Public-sector portal | it | 8 / 17 | 11 (8) | Italian labels, overlapping phases, 20% Management Reserve, capacity warnings |

High risks are those with P×I ≥ 10.

## How they are checked

`scripts/tests/test_examples.py` generates a workbook from every `excel-input.json` (and from
`sample-input.json`) and runs the `summarize.py` checks on it: sheet order and names, formula
patterns, rollup ranges, the Management Reserve base, the Summary bands and the calendar
duration. Run it with the rest of the suite:

```bash
cd scripts && python3 -m pytest -q
```

`summarize.py --input examples/<scenario>/excel-input.json --format markdown` prints the
figures of one scenario.

## Known warnings

The scenarios are kept close to real-sized estimates, so `summarize.py` reports some warnings
on purpose:

- Scenarios 2, 4 and 6 contain activities above 10 PD most-likely, outside the 8/80 rule; they
  show what the warning looks like. `sample-input.json` respects the rule.
- Most scenarios overcommit a role in some weeks (more than 5 PD per week), which the Resource
  Plan highlights and lists under Capacity Warnings.
