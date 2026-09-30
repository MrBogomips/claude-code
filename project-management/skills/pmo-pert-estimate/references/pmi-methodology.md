# PMI Methodology Reference — pmo-pert-estimate

This document is the teaching reference for **Level A (Formative)** mode. When the agent operates in formative mode, it draws from this material to explain concepts, calibrate user understanding, and justify decisions.

---

## 1. Work Breakdown Structure (WBS)

### What is a WBS?

A WBS is a hierarchical decomposition of the total scope of work. It breaks the project into manageable pieces that can be estimated, scheduled, and tracked. The WBS is deliverable-oriented, not activity-oriented.

> **PMBOK 7th Edition**: Section 2.4 (Planning Performance Domain) — "The WBS is a hierarchical decomposition of the total scope of work to be carried out by the project team."

### Decomposition Levels

```
Level 0: Project
Level 1: Phase (e.g., "Analysis", "Development", "Testing")
Level 2: Work Package (estimable unit of work)
Level 3: Activity (leaf — the actual task being estimated)
```

### The 8/80 Rule

The classic rule says a unit of work should take between **8 and 80 hours**. This skill works in
person-days (PD, 8 hours) and applies the rule to **leaf activities**, the level that is
estimated: each activity's most-likely effort should be between **1 PD and 10 PD**.

| Condition | Problem | Action |
|-----------|---------|--------|
| Activity < 1 PD | Over-decomposed; tracking overhead exceeds value | Merge with a sibling |
| Activity > 10 PD | Under-decomposed; too coarse for reliable estimation | Split into smaller activities |
| Activity 1–10 PD | Appropriate granularity | Proceed with estimation |

A work package is then simply the sum of its activities; it may well exceed 10 PD.

**Practical guidance**: for a typical 3–6 month project, most leaf activities are 2–10 PD.
Shorter activities are acceptable when they are distinct deliverables. `scripts/summarize.py`
lists the activities outside 1–10 PD as warnings.

### The 100% Rule

The WBS must include 100% of the project scope. At every level:

- The sum of children must equal exactly 100% of the parent
- No work should exist outside the WBS
- No extra work should be included that is not part of the scope

**Verification**: After building the WBS, trace every deliverable from the scope back to at least one leaf activity. If any deliverable has no corresponding activity, the WBS is incomplete.

### Rolling Wave Planning

Not all phases need the same level of decomposition at the start:

- **Near-term phases** (next 1-3 months): fully decomposed to leaf activities
- **Far-term phases** (3+ months): decomposed to work packages only
- **Refinement trigger**: decompose far-term phases as they move into the near-term horizon

> **PMBOK 7th Edition**: Section 2.4 — "Planning is iterative and incremental. Work to be accomplished in the near term is planned in detail, while work further in the future is planned at a higher level."

This is especially appropriate for agile-influenced projects or when requirements are expected to evolve.

---

## 2. Three-Point Estimation (PERT)

### The PERT Formula

For each activity, three estimates are collected:

| Symbol | Name | Definition | Calibration Guidance |
|--------|------|------------|---------------------|
| **O** | Optimistic | Best realistic case | "Everything goes right, but nothing miraculous." ~5th percentile. |
| **M** | Most Likely | Expected case | "Most common outcome if we did this 20 times." Mode of the distribution. |
| **P** | Pessimistic | Worst realistic case | "Major obstacles, but project not cancelled." ~95th percentile. NOT absolute worst. |

**PERT weighted average**:

```
PERT = (O + 4M + P) / 6
```

This assumes a Beta distribution. The weight of 4 on M reflects that the most likely outcome dominates the average.

**Standard deviation**:

```
sigma = (P - O) / 6
```

### Calibration Questions

When eliciting estimates in formative mode, use these calibration prompts:

1. **For Optimistic (O)**: "If the team is experienced and no blockers arise, what's the minimum effort? Don't assume miracles — just favorable conditions."
2. **For Most Likely (M)**: "Given normal conditions with typical interruptions and learning curves, what's your best guess?"
3. **For Pessimistic (P)**: "If significant problems occur — key person unavailable, requirements change, technical issues — but the project continues, how long? Think 95th percentile, not apocalypse."

### Common Estimation Pitfalls

| Pitfall | Symptom | Correction |
|---------|---------|------------|
| Anchoring | O, M, P are too close together | Ask each estimate independently; start with M, then O, then P |
| Optimism bias | O is the "plan", M is very close to O | Challenge: "What's the last time this type of task went exactly as planned?" |
| Catastrophizing | P is extreme (10x of M) | Reframe: "95th percentile, not worst imaginable. The project still continues." |
| Copy-paste estimates | All activities have identical O/M/P | Each activity has unique characteristics; estimate individually |

---

## 3. Uncertainty: σ, rollups and what to quote

### Per-activity spread

σ = (P − O) / 6 measures the spread of one activity. As a teaching aid, PERT ± 1σ covers roughly
68% of outcomes and PERT ± 2σ roughly 95%, if the Beta approximation holds.

### How the workbook rolls up σ

The workbook computes σ for **durations** only (WBS column M). On a work-package, phase or TOTAL
row it applies the same formula to the summed values, `(ΣP − ΣO) / 6`, which equals the
**linear sum** of the children's σ. That is the conservative case: it assumes the activities are
fully correlated (one bad surprise hits them all) and that they run in sequence.

The textbook alternative assumes independent activities on a single critical path:

```
sigma_path = SQRT( SUM( sigma_i^2 ) )
```

It is always smaller than the linear sum. The workbook does not compute it, because the
activities are rarely independent and the leaf durations are not a critical path: phases
overlap. If a sponsor asks for it, compute it by hand for the activities of the critical path
and say which assumption it rests on.

### What to quote to stakeholders

The workbook quotes **effort bands**, not a confidence interval. Use them:

| Audience | Recommended figure | Explanation |
|----------|--------------------|-------------|
| Project team | Tech PERT per phase | "Our expected effort is X PD." |
| PMO / governance | Low / Medium / High Band | "Between X and Z PD; we plan on the Medium Band, Y PD." |
| Executive sponsor | Medium Band and Calendar Duration | "Y PD over W weeks, including contingency and management reserve." |
| Contract / procurement | Medium Band, or the High Band for a fixed price | Conservative commitment for contractual obligations. |

### Correlated risk

Correlated risks (team-wide skill gaps, organization-wide disruptions) increase the real
variance beyond any per-activity σ. The Risk Register's contingency and the Management Reserve
are the mechanisms for them: they are added on top of the PERT effort in the bands.

---

## 4. Risk Management

### Risk Identification Techniques

1. **Brainstorming**: Team-based identification session structured by WBS phase
2. **Checklist review**: Use historical risk lists from similar projects
3. **SWOT analysis**: Strengths/Weaknesses (internal), Opportunities/Threats (external)
4. **Expert judgment**: Leverage team members' past experience with similar activities
5. **Document analysis**: Review scope, constraints, assumptions for implicit risks

> **PMBOK 7th Edition**: Section 2.7 (Uncertainty Performance Domain) — "Risks are uncertain events or conditions that, if they occur, have a positive or negative effect on one or more project objectives."

### Probability x Impact Matrix

Both Probability and Impact are scored on a 1-5 scale:

| Score | Probability | Impact |
|-------|------------|--------|
| 1 | Very Low (< 10%) | Negligible effect |
| 2 | Low (10-25%) | Minor delay/cost increase |
| 3 | Medium (25-50%) | Moderate delay/cost increase |
| 4 | High (50-75%) | Significant delay/cost increase |
| 5 | Very High (> 75%) | Critical — threatens project success |

**Risk Score = P x I**

| Score Range | Priority | Action Required |
|-------------|----------|----------------|
| 1-4 | LOW | Monitor; accept if cost of response exceeds impact |
| 5-9 | MEDIUM | Plan response; allocate contingency |
| 10-14 | HIGH | Active management; dedicated mitigation |
| 15-25 | CRITICAL | Immediate escalation; mandatory mitigation or avoidance |

A **high risk** is any risk with P×I ≥ 10 (HIGH or CRITICAL): it needs a mitigation action and
an owner. The same threshold is used by the SOW skills of this plugin and by the red font on the
Risks sheet.

### Response Strategies

| Strategy | When to Use | Example |
|----------|------------|---------|
| **Mitigate** | Reduce probability or impact | Add training to reduce skill gap risk |
| **Transfer** | Shift impact to third party | Purchase insurance; outsource risky component |
| **Accept** | Cost of response > expected impact | Accept minor delays; document in risk register |
| **Avoid** | Eliminate the threat entirely | Remove risky feature from scope; change approach |

### Contingency vs Management Reserve

| Type | Purpose | Calculated from | Controlled by |
|------|---------|----------------|---------------|
| **Contingency** | Address identified, specific risks | Sum of contingency per risk (effort-based) | Project Manager |
| **Management Reserve** | Address unknown unknowns and correlated risks | Percentage (typically 5-15%) of Tech PERT + PM/DevOps overhead + total contingency | Sponsor / PMO |

**Practical formula** (as computed on the Summary sheet):

```
Low Band (Fascia BASSA)    = Tech PERT + PM/DevOps Overhead + Total Contingency
Management Reserve         = Low Band × MR%
Medium Band (Fascia MEDIA) = Low Band + Management Reserve   (recommended)
High Band (Fascia ALTA)    = Medium Band × (1 + alta_uplift_pct)
```

---

## 5. Top-Down / Bottom-Up Reconciliation

### When Reconciliation Is Needed

Reconciliation is triggered when there is a significant divergence between:

- **Bottom-up estimate**: Sum of all leaf-level PERT estimates
- **Top-down target**: Client/sponsor expected effort or duration

A divergence threshold of **20%** triggers the formal reconciliation process.

### Reconciliation Process

```
Step 1: Measure delta
  delta = (bottom_up - target) / target * 100%

Step 2: If |delta| <= 20% --> Accept bottom-up (within normal variance)

Step 3: If |delta| > 20% --> Initiate guided reconciliation:
  a. Analyze root causes:
     - Scope: Is the WBS capturing more/less than intended?
     - Estimates: Are individual O/M/P calibrated correctly?
     - Resources: Could different staffing reduce effort?
     - Dependencies: Are there serialization bottlenecks?

  b. Propose adjustments (one or more):
     - Scope adjustment: defer non-critical work packages
     - Estimate recalibration: challenge outlier estimates
     - Resource reallocation: add parallel capacity
     - Risk reassessment: reduce contingency if over-conservative

  c. Re-calculate and present new delta

  d. Iterate until convergence OR user explicitly accepts the delta

Step 4: Document reconciliation log in estimates-draft.md
```

### Reconciliation in Formative Mode (Level A)

In formative mode, the agent explains each step:

- Why the delta exists
- What each adjustment lever does
- Trade-offs of each option (scope cut = risk to completeness; estimate reduction = risk to accuracy)
- Why convergence may not be possible (the target may be unrealistic)

---

## 6. PMBOK Reference Map

| Concept | PMBOK 7th Edition Section |
|---------|--------------------------|
| WBS decomposition | 2.4 Planning Performance Domain |
| Rolling wave planning | 2.4 Planning Performance Domain |
| Three-point estimation | 2.4 Planning Performance Domain |
| Risk identification | 2.7 Uncertainty Performance Domain |
| P x I assessment | 2.7 Uncertainty Performance Domain |
| Risk response strategies | 2.7 Uncertainty Performance Domain |
| Stakeholder engagement | 2.1 Stakeholder Performance Domain |
| Schedule management | 2.5 Project Work Performance Domain |
| Cost estimation | 2.4 Planning Performance Domain |
| Uncertainty and ranges | 2.7 Uncertainty Performance Domain |
