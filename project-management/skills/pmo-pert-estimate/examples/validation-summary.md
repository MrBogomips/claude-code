# PMO PERT Estimate — Validation Summary

## Overview

6 validation scenarios executed covering low-to-high complexity, EN and IT
output, multiple teams, public-sector PA integration patterns, and edge
cases. All scenarios use the v2 4-sheet layout (WBS, Resource Plan, Risks,
Summary).

## Score Matrix

| Criterion | S1 (Website) | S2 (ERP) | S3 (Mobile) | S4 (Cloud) | S5 (Consulting) | S6 (PA Portal) |
|-----------|:---:|:---:|:---:|:---:|:---:|:---:|
| 4 sheets in canonical order | PASS | PASS | PASS | PASS | PASS | PASS |
| Sheet names localized when `lang=it` | — | — | — | — | — | PASS |
| WBS structure & formulas | PASS | PASS | PASS | PASS | PASS | PASS |
| Resource Plan PD totals match WBS | PASS | PASS | PASS | PASS | PASS | PASS |
| Resource Plan calendar dates | PASS | PASS | PASS | PASS | PASS | PASS |
| Capacity highlight on overcommit | — | — | — | — | — | PASS |
| Risks P×I formulas | PASS | PASS | PASS | PASS | PASS | PASS |
| MR uses Tech+Overhead+Contingency | PASS | PASS | PASS | PASS | PASS | PASS |
| Summary Fascia BASSA / MEDIA / ALTA | PASS | PASS | PASS | PASS | PASS | PASS |
| Calendar Duration as single number | PASS | PASS | PASS | PASS | PASS | PASS |
| Effort by Team in real PD | PASS | PASS | PASS | PASS | PASS | PASS |
| Sensitivity scenarios listed | PASS | PASS | PASS | PASS | PASS | PASS |
| Cross-sheet references resolve | PASS | PASS | PASS | PASS | PASS | PASS |
| PM/DevOps overhead applied | PASS | PASS | PASS | PASS | PASS | PASS |

## Key changes vs the v1 layout

| Aspect | v1 (legacy) | v2 (this release) |
|--------|-------------|-------------------|
| Sheets | 5 (WBS, Timeline, Resources, Risks, Summary) | 4 (WBS, Resource Plan, Risks, Summary) |
| Resource sheet | % allocation matrix per phase × role | PD matrix per role × week, derived from primary role of each leaf |
| Calendar duration | `=SUM(WBS!leaf_durations)` — sequential, ignores parallelism | Single explicit value (`config.calendar_total_weeks` or `max(end_week)-min(start_week)+1`) |
| MR base | Contingency only | Tech + Overhead + Contingency (PMI PMBOK §4.3) |
| PM/DevOps overhead | Manual workaround | Native `config.pm_overhead_pct` / `config.devops_overhead_pct` |
| Effort bands | Single "Adjusted PERT" row | Fascia BASSA / MEDIA / ALTA explicit |
| Localization | Hardcoded English | en + it labels via `config.lang` |
| Legacy JSON | Required new schema | Soft backward-compat with stderr warning |

## Scenario 6 — PA Portal Integration (new)

Anonymized public-sector portal scenario with 8 phases (F0..F7), 14 leaf
activities, 11 risks, and overlapping integration/build phases. Output
language is Italian (`lang=it`). The scenario exercises every new
capability: explicit phase weeks, parallel phases (F2 overlaps F3,
F4 overlaps F5, F5 overlaps F6, F6 overlaps F7), PM/DevOps overhead,
20% Management Reserve on the correct base, and the Fascia ALTA uplift.

## Conclusion

The `pmo-pert-estimate` skill v2 is production-ready. The 4-sheet output
addresses the five issues identified in the real-world case study:

1. **Issue #1** (Resources held %, not PD) — resolved by replacing the
   sheet with a PD-based Resource Plan.
2. **Issue #2** (sequential leaf-sum CI Duration) — resolved by
   replacing the block with a single Calendar Duration value.
3. **Issue #3** (MR computed on Contingency only) — resolved by
   recomputing MR on Tech + Overhead + Contingency.
4. **Issue #4** (Timeline Gantt not actionable) — sheet removed.
5. **Issue #5** (no native PM/DevOps overhead) — added as first-class
   config fields with automatic Summary rows.
