# Interaction Levels Reference — pmo-pert-estimate

Three interaction levels control how much guidance and explanation the skill provides. The user selects a level in Phase 1; the skill adjusts it per phase based on user behavior.

Dispatched agents cannot talk to the user: they return a draft plus open questions, and the skill runs every checkpoint described below (SKILL.md, "How phases use agents"). "Asks" in the tables means the skill asks at the checkpoint.

---

## Level Overview

| Level | Name | Target User | Interaction Density | Key Characteristic |
|-------|------|-------------|--------------------|--------------------|
| **A** | Formative | New to PERT / PMI methodology | High | Expert + Teacher mode |
| **B** | Collaborative | Familiar with PMI, wants validation | Moderate | Skill proposes, user validates |
| **C** | Autonomous | Experienced PMO | Minimal | Skill decides, user reviews final output |

---

## Level A — Formative (Expert + Teacher)

### Philosophy

The skill acts as both an expert practitioner and a teacher: agents write the explanations into their drafts, and the skill walks the user through them. Every significant decision is explained with PMI methodology context. The goal is to build the user's understanding so they can independently evaluate and improve the estimates.

### Behavior per Phase

| Phase | Behavior |
|-------|---------------|
| **Phase 2 — Context** | Explains what scope, constraints, and assumptions mean. Asks clarifying questions to ensure completeness. Highlights gaps. |
| **Phase 3 — WBS** | Proposes **one project phase at a time**: the WBS builder is dispatched once per phase, with a checkpoint in between. Explains the 8/80 rule (1–10 PD per activity) before decomposing. Explains rolling wave for far-term phases. |
| **Phase 3 — RBS** | Explains RACI concepts. Discusses billable vs non-billable distinction. Asks user to confirm role assignments. |
| **Phase 4 — Risks** | Introduces P x I matrix with examples. Explains each response strategy (Mitigate, Transfer, Accept, Avoid). Walks through contingency calculation. |
| **Phase 4 — Estimates** | Explains three-point calibration (what O, M, P mean). Uses calibration questions from `pmi-methodology.md`. Shows PERT formula derivation. Explains sigma, why the workbook sums it linearly, and why the effort bands are what gets quoted. |
| **Phase 4 — Reconciliation** | Explains top-down/bottom-up method. Shows why delta exists. Discusses trade-offs of each adjustment lever. |
| **Phase 5 — Excel** | No additional interaction (automated). |
| **Phase 6 — Checks** | Explains what `summarize.py` verified and why each check matters. |

### Artifact Enrichment

In Level A, intermediate markdown artifacts include **"Methodology Applied"** sections:

```markdown
## Methodology Applied

- **8/80 Rule**: All leaf activities verified to be between 1 and 10 PD most-likely.
  Activity 2.3.1 was split from 15 PD into two activities of ~7.5 PD each.
- **Rolling Wave**: Phases 5-7 decomposed to work package level only;
  will be refined as Phase 4 completes.
- **Reference**: PMBOK 7th Edition, Section 2.4 (Planning Performance Domain)
```

### Example messages to the user (Level A)

**WBS decomposition:**
> "Let's start with Phase 1: Analysis. I'll apply the 8/80 rule — each activity should take between 1 and 10 person-days (8 to 80 hours). This gives enough detail to estimate accurately without over-decomposing.
>
> I propose 3 work packages for this phase:
> 1. Requirements Gathering (est. 5 PD) — interviews, document analysis
> 2. Current State Assessment (est. 4 PD) — system inventory, gap analysis
> 3. Feasibility Study (est. 3 PD) — technical evaluation, risk identification
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

The skill is a capable partner. It proposes complete artifacts and the user validates or adjusts. Explanations are brief and only provided when a draft shows potential issues. The focus is on efficiency with appropriate checkpoints.

### Behavior per Phase

| Phase | Behavior |
|-------|---------------|
| **Phase 2 — Context** | Presents complete context analysis. Asks: "Does this capture everything? Any additions?" |
| **Phase 3 — WBS** | Proposes **complete WBS** in one pass. Highlights any 8/80 borderline cases. Asks for global validation. |
| **Phase 3 — RBS** | Proposes complete RBS with team assignments. Asks for confirmation. |
| **Phase 4 — Risks** | Proposes complete risk register. Highlights highest-priority risks. Asks for validation. |
| **Phase 4 — Estimates** | Proposes O/M/P ranges for all activities. Shows PERT totals per phase and a preview of the effort bands (final figures come from `summarize.py`). Asks: "Any estimates you'd like to adjust?" |
| **Phase 4 — Reconciliation** | Shows delta with target. Proposes specific adjustments. Asks for approval. |
| **Phase 5 — Excel** | No additional interaction (automated). |
| **Phase 6 — Checks** | Reports the check result briefly. |

### Artifact Format

Standard markdown without methodology sections. Clean, data-focused.

### Example messages to the user (Level B)

**WBS validation:**
> "Here's the proposed WBS with 6 phases, 18 work packages, and 42 leaf activities. All activities satisfy the 8/80 rule (1–10 PD).
>
> [full WBS table]
>
> Two items to note:
> - Activity 3.2.1 'API Integration' is at 9.5 PD, close to the 10 PD ceiling. Consider splitting if scope grows.
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

The skill works independently and presents the final result. Interaction is limited to: input collection (Phase 1), critical divergence flags, and final output review. For experienced PMOs who trust the methodology.

### Behavior per Phase

| Phase | Behavior |
|-------|---------------|
| **Phase 2 — Context** | Analyzes silently. Presents summary for acknowledgment (not detailed review). |
| **Phase 3 — WBS** | Generates complete WBS autonomously. No intermediate validation. |
| **Phase 3 — RBS** | Generates complete RBS autonomously. |
| **Phase 4 — Risks** | Generates complete risk register autonomously. |
| **Phase 4 — Estimates** | Generates all estimates autonomously. Auto-reconciliation if delta <= 20%. |
| **Phase 4 — Reconciliation** | If delta > 20%: **flags the divergence** and presents options. This is the only mandatory interaction point. |
| **Phase 5 — Excel** | No interaction (automated). |
| **Phase 6 — Checks** | Reports pass/fail. Presents the final workbook and its figures. |

### Artifact Format

Essential data only. No explanations, no methodology notes. Compact tables.

### Example messages to the user (Level C)

**Completion:**
> "PERT estimation complete.
>
> - 5 phases, 15 work packages, 38 activities
> - Tech PERT effort: 620 pd (+ PM/DevOps overhead: 62 pd)
> - 8 risks identified, total contingency: 45 pd
> - Low Band: 727 pd · Management Reserve (10%): 73 pd · Medium Band (recommended): 800 pd · High Band: 896 pd
> - Calendar duration: 22 weeks
>
> Output: `{OutputDir}/<estimate-slug>-pert-v1.xlsx`
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

The interaction level is not rigid. The skill monitors user behavior and adjusts.

### Upward Shift (toward more guidance)

| Trigger | From | To | Action |
|---------|------|----|--------|
| User asks "why?" or "what does X mean?" | B or C | A (for that phase) | Switch to formative explanations for the current topic |
| User requests methodology explanation | B or C | A (for that phase) | Provide PMBOK context, then offer to stay at Level A |
| User expresses uncertainty about estimates | B or C | A (for estimation) | Use calibration questions from methodology reference |

**Transition message:**
> "I notice you're asking about the 8/80 rule. Would you like me to switch to full guidance mode for the WBS decomposition? I can explain the methodology as we go."

### Downward Shift (toward less guidance)

| Trigger | From | To | Action |
|---------|------|----|--------|
| User consistently responds "ok" / "looks good" without engagement | A | B | Suggest switching: "You seem comfortable — want me to propose complete artifacts instead of step-by-step?" |
| User modifies estimates confidently without questions | A | B | Reduce explanation density |
| User explicitly requests faster pace | A or B | C | Switch to autonomous mode |

**Transition message:**
> "You've been approving each phase quickly. Would you prefer I present the complete WBS at once and you review the whole thing? That would speed things up."

### Scope of Adaptation

- Adaptation is **per-phase**, not global. A user might be Level A for risks but Level C for WBS.
- The skill never downgrades without suggesting it first.
- The skill may upgrade silently (providing more context when asked) without formally announcing a level change.
