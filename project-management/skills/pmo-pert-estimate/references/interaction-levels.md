# Interaction Levels Reference — pmo-pert-estimate

Three interaction levels control how much guidance and explanation the agent provides. The user selects a level in Phase 1; the agent may dynamically adjust based on user behavior.

---

## Level Overview

| Level | Name | Target User | Interaction Density | Key Characteristic |
|-------|------|-------------|--------------------|--------------------|
| **A** | Formative | New to PERT / PMI methodology | High | Expert + Teacher mode |
| **B** | Collaborative | Familiar with PMI, wants validation | Moderate | Agent proposes, user validates |
| **C** | Autonomous | Experienced PMO | Minimal | Agent decides, user reviews final output |

---

## Level A — Formative (Expert + Teacher)

### Philosophy

The agent acts as both an expert practitioner and a teacher. Every significant decision is explained with PMI methodology context. The goal is to build the user's understanding so they can independently evaluate and improve the estimates.

### Behavior per Phase

| Phase | Agent Behavior |
|-------|---------------|
| **Phase 2 — Context** | Explains what scope, constraints, and assumptions mean. Asks clarifying questions to ensure completeness. Highlights gaps. |
| **Phase 3 — WBS** | Proposes **one phase at a time**. Explains 8/80 rule before decomposing. Explains rolling wave for far-term phases. Asks user to validate each phase before moving to the next. |
| **Phase 3 — RBS** | Explains RACI concepts. Discusses billable vs non-billable distinction. Asks user to confirm role assignments. |
| **Phase 4 — Risks** | Introduces P x I matrix with examples. Explains each response strategy (Mitigate, Transfer, Accept, Avoid). Walks through contingency calculation. |
| **Phase 4 — Estimates** | Explains three-point calibration (what O, M, P mean). Uses calibration questions from `pmi-methodology.md`. Shows PERT formula derivation. Explains sigma and confidence intervals. |
| **Phase 4 — Reconciliation** | Explains top-down/bottom-up method. Shows why delta exists. Discusses trade-offs of each adjustment lever. |
| **Phase 5 — Excel** | No additional interaction (automated). |
| **Phase 6 — Validation** | Explains what was verified and why each check matters. |

### Artifact Enrichment

In Level A, intermediate markdown artifacts include **"Methodology Applied"** sections:

```markdown
## Methodology Applied

- **8/80 Rule**: All work packages verified to be between 8h and 80h.
  Work Package 2.3 was split from 120h into two packages of ~60h each.
- **Rolling Wave**: Phases 5-7 decomposed to work package level only;
  will be refined as Phase 4 completes.
- **Reference**: PMBOK 7th Edition, Section 2.4 (Planning Performance Domain)
```

### Example Agent Prompts (Level A)

**WBS decomposition:**
> "Let's start with Phase 1: Analysis. I'll apply the 8/80 rule — each work package should require between 8 and 80 hours of effort. This ensures we have enough detail to estimate accurately without over-decomposing.
>
> I propose 3 work packages for this phase:
> 1. Requirements Gathering (est. 40h) — interviews, document analysis
> 2. Current State Assessment (est. 30h) — system inventory, gap analysis
> 3. Feasibility Study (est. 25h) — technical evaluation, risk identification
>
> Does this decomposition capture the full scope of the Analysis phase? Would you add or modify anything?"

**Estimation calibration:**
> "For activity 1.1.1 'Stakeholder Interviews', let's estimate using three points:
>
> - **Optimistic (O)**: If the stakeholders are available and prepared, what's the minimum effort? Think best realistic case, not miracle scenario.
> - **Most Likely (M)**: With normal scheduling delays and typical meeting dynamics, what's your best guess?
> - **Pessimistic (P)**: If key stakeholders are hard to reach, require multiple rounds, and scope questions arise — but the project continues — how long? Think 95th percentile.
>
> I suggest: O=3pd, M=5pd, P=10pd. This gives us PERT = (3 + 20 + 10) / 6 = 5.5pd with sigma = (10-3)/6 = 1.17pd.
>
> Does that feel calibrated? Are you comfortable with the pessimistic end?"

---

## Level B — Collaborative (Default)

### Philosophy

The agent is a capable partner. It proposes complete artifacts and the user validates or adjusts. Explanations are brief and only provided when the agent detects potential issues. The focus is on efficiency with appropriate checkpoints.

### Behavior per Phase

| Phase | Agent Behavior |
|-------|---------------|
| **Phase 2 — Context** | Presents complete context analysis. Asks: "Does this capture everything? Any additions?" |
| **Phase 3 — WBS** | Proposes **complete WBS** in one pass. Highlights any 8/80 borderline cases. Asks for global validation. |
| **Phase 3 — RBS** | Proposes complete RBS with team assignments. Asks for confirmation. |
| **Phase 4 — Risks** | Proposes complete risk register. Highlights highest-priority risks. Asks for validation. |
| **Phase 4 — Estimates** | Proposes O/M/P ranges for all activities. Shows PERT totals and CI. Asks: "Any estimates you'd like to adjust?" |
| **Phase 4 — Reconciliation** | Shows delta with target. Proposes specific adjustments. Asks for approval. |
| **Phase 5 — Excel** | No additional interaction (automated). |
| **Phase 6 — Validation** | Reports validation status briefly. |

### Artifact Format

Standard markdown without methodology sections. Clean, data-focused.

### Example Agent Prompts (Level B)

**WBS validation:**
> "Here's the proposed WBS with 6 phases, 18 work packages, and 42 leaf activities. All work packages satisfy the 8/80 rule.
>
> [full WBS table]
>
> Two items to note:
> - WP 3.2 'API Integration' is at 78h, close to the 80h ceiling. Consider splitting if scope grows.
> - Phase 6 'Deployment' uses rolling wave — only 2 work packages defined; we'll refine later.
>
> Does this look right? Any changes?"

**Reconciliation:**
> "Bottom-up estimate: 850 pd. Target: 700 pd. Delta: +21.4%.
>
> Proposed adjustments:
> 1. Reduce Phase 4 testing scope (defer regression suite to maintenance): -60 pd
> 2. Parallelize WP 2.1 and 2.2 (add 1 developer): -40 pd
> 3. Accept remaining delta of +50 pd as risk buffer
>
> Adjusted: 750 pd (+7.1% vs target). Accept?"

---

## Level C — Autonomous (Minimal Interaction)

### Philosophy

The agent works independently and presents the final result. Interaction is limited to: input collection (Phase 1), critical divergence flags, and final output review. For experienced PMOs who trust the agent's methodology.

### Behavior per Phase

| Phase | Agent Behavior |
|-------|---------------|
| **Phase 2 — Context** | Analyzes silently. Presents summary for acknowledgment (not detailed review). |
| **Phase 3 — WBS** | Generates complete WBS autonomously. No intermediate validation. |
| **Phase 3 — RBS** | Generates complete RBS autonomously. |
| **Phase 4 — Risks** | Generates complete risk register autonomously. |
| **Phase 4 — Estimates** | Generates all estimates autonomously. Auto-reconciliation if delta <= 20%. |
| **Phase 4 — Reconciliation** | If delta > 20%: **flags the divergence** and presents options. This is the only mandatory interaction point. |
| **Phase 5 — Excel** | No interaction (automated). |
| **Phase 6 — Validation** | Reports pass/fail. Presents final Excel. |

### Artifact Format

Essential data only. No explanations, no methodology notes. Compact tables.

### Example Agent Prompts (Level C)

**Completion:**
> "PERT estimation complete.
>
> - 5 phases, 15 work packages, 38 activities
> - Total PERT Effort: 620 pd (CI 95%: 540-700 pd)
> - Total PERT Duration: 95 days (CI 95%: 82-108 days)
> - 8 risks identified, total contingency: 45 pd
> - Management reserve (10%): 62 pd
> - Adjusted estimate: 727 pd
>
> Output: `docs/outbox/pert-estimate.xlsx`
>
> Review the Excel and let me know if adjustments are needed."

**Divergence flag (only mandatory Level C interaction):**
> "Bottom-up estimate (850 pd) exceeds target (700 pd) by 21.4%. This requires your input:
> 1. Accept the higher estimate
> 2. Reduce scope (I can suggest cuts)
> 3. Recalibrate estimates (I can identify aggressive items)
>
> Which approach?"

---

## Dynamic Adaptation

The interaction level is not rigid. The agent monitors user behavior and adjusts.

### Upward Shift (toward more guidance)

| Trigger | From | To | Action |
|---------|------|----|--------|
| User asks "why?" or "what does X mean?" | B or C | A (for that phase) | Switch to formative explanations for the current topic |
| User requests methodology explanation | B or C | A (for that phase) | Provide PMBOK context, then offer to stay at Level A |
| User expresses uncertainty about estimates | B or C | A (for estimation) | Use calibration questions from methodology reference |

**Agent transition prompt:**
> "I notice you're asking about the 8/80 rule. Would you like me to switch to full guidance mode for the WBS decomposition? I can explain the methodology as we go."

### Downward Shift (toward less guidance)

| Trigger | From | To | Action |
|---------|------|----|--------|
| User consistently responds "ok" / "looks good" without engagement | A | B | Suggest switching: "You seem comfortable — want me to propose complete artifacts instead of step-by-step?" |
| User modifies estimates confidently without questions | A | B | Reduce explanation density |
| User explicitly requests faster pace | A or B | C | Switch to autonomous mode |

**Agent transition prompt:**
> "You've been approving each phase quickly. Would you prefer I present the complete WBS at once and you review the whole thing? That would speed things up."

### Scope of Adaptation

- Adaptation is **per-phase**, not global. A user might be Level A for risks but Level C for WBS.
- The agent never downgrades without suggesting it first.
- The agent may upgrade silently (providing more context when asked) without formally announcing a level change.
