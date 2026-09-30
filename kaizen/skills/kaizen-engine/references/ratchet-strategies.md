# Ratchet Strategies

## Epsilon and Decision KPIs

Both strategies judge each KPI against its own **epsilon**, taken from the manifest:

```
epsilon(kpi) = kpi.epsilon if the KPI sets one, else convergence.epsilon
```

Epsilon is in the KPI's own unit: 0.02 means two hundredths for a ratio, but 0.02 points for a 0–100 percentage and a fiftieth of an item for a count. One value cannot serve all three, so a profile whose KPIs use different units sets `epsilon` on each KPI.

**Epsilon role:** Prevents noise from being treated as improvement. If a KPI changes by less than its epsilon, it's treated as unchanged. Typical epsilon values:
- Ratios (0–1): 0.01-0.05
- Percentages (0–100): 1-5
- Counts: 1
- Time (seconds): 0.5-2.0

Only **decision KPIs** take part. A KPI with `observational: true` is measured, logged and reported, but the rules below skip it. Mark a KPI observational when the loop's own changes cannot move it within a run, for example a KPI computed from past session transcripts.

The helpers below use the KPI's direction:

```
gain(kpi) = kpi_after - kpi_before   (maximize)
gain(kpi) = kpi_before - kpi_after   (minimize)
improved(kpi)  = gain(kpi) >= epsilon(kpi)
regressed(kpi) = -gain(kpi) >= epsilon(kpi)
```

## Forced Outcomes

These are settled before any KPI is compared:

| Condition | Decision |
|-----------|----------|
| `apply_failed` | REVERT |
| `verify_failed` (a verify check failed or timed out, or a decision KPI is missing) | REVERT |
| Immutable violation | REVERT |
| `no_proposal` (none found, or the user rejected it) | REVERT (nothing was applied; counts toward patience) |

## Greedy Strategy (Single KPI)

Used when `strategy: greedy` in the profile, or when the profile defines a single decision KPI.

**Decision rule:**
```
IF improved(target_kpi)
THEN KEEP
ELSE REVERT
```

A change in the desired direction smaller than the KPI's epsilon is a REVERT, for both maximize and minimize KPIs.

Simple hill-climbing. No tolerance for regression. Each iteration either locks in an improvement or returns to the previous best state.

## Multi-Objective Strategy

Used when `strategy: multi-objective` in the profile, or when multiple decision KPIs are defined.

**Decision rule (Pareto dominance over decision KPIs):**
```
decision_kpis = [kpi for kpi in kpis if not kpi.observational]
improved_set  = [kpi for kpi in decision_kpis if improved(kpi)]
regressed_set = [kpi for kpi in decision_kpis if regressed(kpi)]

IF len(regressed_set) == 0 AND len(improved_set) >= 1:
    KEEP  (Pareto improvement — at least one better, none worse)

ELSE IF len(regressed_set) > 0 AND len(improved_set) >= 1 AND autonomy != "autonomous":
    ESCALATE to user:
    "Iteration {N} improved {improved_set} but regressed {regressed_set}.
     Accept this trade-off?"
    The user's answer is the decision: "accept" → KEEP, "reject" → REVERT.
    Record it with escalated: true.

ELSE:
    REVERT  (a regression with no trade-off to weigh, an autonomous run, which cannot
             accept trade-offs without human judgment, or no meaningful change)
```

**Trade-off presentation (for ESCALATE):**

| KPI | Before | After | Delta | Epsilon | Direction |
|-----|--------|-------|-------|---------|-----------|
| tool_efficiency | 0.65 | 0.72 | +0.07 | 0.03 | improved |
| search_precision | 3.2 | 3.8 | +0.6 | 0.5 | regressed |

"tool_efficiency improved by 10.8% but search_precision worsened by 18.8%. Accept?"

## Patience Mechanism

Both strategies use a patience counter to detect convergence. It follows the final decision, so an escalation counts as the KEEP or REVERT the user chose:

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

The proposer is stateless, so the engine keeps the memory for it:
- After each REVERT, including a rejected proposal, the engine appends a one-line summary (iteration, target, change) to `reverted_proposals` in summary.json.
- Every PROPOSE phase receives the whole list, plus the user's note when the previous proposal was rejected. The proposer must not repeat any entry and should try a different file, strategy or hypothesis.
- If the proposer has exhausted all hypotheses, it should report `no_proposal` which counts toward patience
