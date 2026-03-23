# Ratchet Strategies

## Greedy Strategy (Single KPI)

Used when `strategy: greedy` in the profile, or when the profile defines a single KPI.

**Decision rule:**
```
IF kpi_after < kpi_before (for minimize direction)
   OR kpi_after > kpi_before (for maximize direction)
   AND abs(kpi_after - kpi_before) >= epsilon
THEN KEEP
ELSE REVERT
```

Simple hill-climbing. No tolerance for regression. Each iteration either locks in an improvement or returns to the previous best state.

**Epsilon role:** Prevents noise from being treated as improvement. If a KPI changes by less than epsilon, it's treated as unchanged. Typical epsilon values:
- Ratios: 0.01-0.05
- Percentages: 1-5
- Counts: 1
- Time (seconds): 0.5-2.0

## Multi-Objective Strategy

Used when `strategy: multi-objective` in the profile, or when multiple KPIs are defined.

**Decision rule (Pareto dominance):**
```
improved = [kpi for kpi in kpis if delta(kpi) >= epsilon in the desired direction]
regressed = [kpi for kpi in kpis if delta(kpi) >= epsilon in the undesired direction]
unchanged = [kpi for kpi in kpis if abs(delta(kpi)) < epsilon]

IF len(regressed) == 0 AND len(improved) >= 1:
    KEEP  (Pareto improvement — at least one better, none worse)

IF len(regressed) > 0:
    IF autonomy == "autonomous":
        REVERT  (cannot accept trade-offs without human judgment)
    ELSE:
        ESCALATE to user:
        "Iteration {N} improved {improved_kpis} but regressed {regressed_kpis}.
         Accept this trade-off?"

IF len(improved) == 0 AND len(regressed) == 0:
    REVERT  (no meaningful change)
```

**Trade-off presentation (for ESCALATE):**

| KPI | Before | After | Delta | Direction |
|-----|--------|-------|-------|-----------|
| tool_efficiency | 0.65 | 0.72 | +0.07 | improved |
| search_precision | 3.2 | 3.8 | +0.6 | regressed |

"tool_efficiency improved by 10.8% but search_precision worsened by 18.8%. Accept?"

## Patience Mechanism

Both strategies use a patience counter to detect convergence:

```
patience_counter = 0

After each DECIDE:
  IF decision == KEEP:
    patience_counter = 0  (reset)
  IF decision == REVERT:
    patience_counter += 1

IF patience_counter >= convergence.patience:
    STOP (convergence — improvement has plateaued)
```

Typical patience values:
- Fast convergence: 2 (stop after 2 consecutive reverts)
- Standard: 3
- Thorough exploration: 5 (allow more failed attempts before giving up)

## Avoiding Repetition

The proposer MUST track reverted proposals. After a revert:
- The next iteration's PROPOSE phase receives the reverted proposal as negative context
- The proposer should try a different approach (different file, different strategy, different hypothesis)
- If the proposer has exhausted all hypotheses, it should report `no_proposal` which counts toward patience
