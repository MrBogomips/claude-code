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

Every work package should require between **8 hours and 80 hours** of effort.

| Condition | Problem | Action |
|-----------|---------|--------|
| Package < 8 hours | Over-decomposed; tracking overhead exceeds value | Merge with sibling or parent |
| Package > 80 hours | Under-decomposed; too coarse for reliable estimation | Split into smaller packages |
| Package = 8-80 hours | Appropriate granularity | Proceed with estimation |

**Practical guidance**: For a typical 3-6 month project, most leaf activities should be 2-10 person-days. Shorter tasks are acceptable if they represent distinct deliverables.

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

## 3. Statistical Confidence Intervals

### Per-Activity Confidence

```
CI 68% = PERT +/- 1 sigma    (one standard deviation)
CI 95% = PERT +/- 2 sigma    (two standard deviations)
```

### Project-Level Aggregation

For the total project duration, assuming activities are statistically independent (standard PERT/CLT assumption):

```
sigma_total = SQRT( SUM( sigma_i^2 ) )
```

Where sigma_i is the standard deviation of each phase/activity on the critical path.

**Project-level CI**:

```
CI 68%: PERT_total +/- sigma_total
CI 95%: PERT_total +/- 2 * sigma_total
```

### Stakeholder Communication

| Audience | Recommended metric | Explanation |
|----------|-------------------|-------------|
| Executive sponsor | CI 95% upper bound | "We are 95% confident the project will complete within X days." |
| Project team | PERT value | "Our expected duration is X days." |
| PMO / governance | CI 68% range | "We expect completion between X and Y days with 68% confidence." |
| Contract / procurement | CI 95% upper bound + management reserve | Conservative commitment for contractual obligations. |

### Independence Assumption

The formula `sigma_total = SQRT(SUM(sigma_i^2))` assumes activities are statistically independent. In practice, correlated risks (e.g., team-wide skill gaps, organization-wide disruptions) increase actual variance. The Risk Register and Management Reserve are the mechanisms to address correlated risk — they provide additive buffers on top of the statistical CI.

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
| **Management Reserve** | Address unknown unknowns and correlated risks | Percentage of total PERT (typically 5-15%) | Sponsor / PMO |

**Practical formula**:

```
Adjusted Estimate = PERT + Total Contingency + Management Reserve
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
| Confidence intervals | 2.7 Uncertainty Performance Domain |
