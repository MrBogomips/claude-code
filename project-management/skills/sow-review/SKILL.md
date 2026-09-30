---
name: sow-review
description: "Review and score Statement of Work documents across 8 quality dimensions with adversarial analysis. Produces a structured scorecard (1-5 per dimension), critical issues list, improvement recommendations, and adversarial challenges from both client and vendor perspectives. Use this skill whenever the user wants to review a SOW, check SOW quality, do an adversarial review of a statement of work, validate a proposal, audit a capitolato tecnico, or mentions 'revisiona SoW', 'SOW quality check', or 'review proposal document'."
---

# SOW Review — Quality Assessment & Adversarial Analysis

## 1. Overview

This skill reviews Statement of Work documents against 8 quality dimensions, producing a structured scorecard with actionable recommendations. It includes an adversarial pass that role-plays as both client and vendor to identify exploitable gaps.

**Inputs:**
- **SOW document** (required) — path to a Markdown, PDF or DOCX file
- **Addenda** (optional) — estimation docs, PERT Excel, appendices, meeting notes
- **Corporate standards** (optional) — company templates, style guides, or previous SOWs for compliance checking

**Connector support:**
- If **~~knowledge base** is connected: pull corporate templates and standards automatically
- If **~~chat** is connected: post review summaries to stakeholders
- If **~~document converter** is connected: convert PDF or DOCX inputs to Markdown

---

## 2. Pipeline

### Step 1 — Document Ingestion

Read the SOW and all addenda. Markdown is read directly, and PDF with the Read tool. A DOCX cannot be read directly: convert it with a **~~document converter** if one is connected; otherwise look for a converter on the system (`command -v markitdown pandoc`) and, if one is found, ask before running it (`markitdown <file>` or `pandoc -t gfm <file>`); if none is available, ask the user for a Markdown or PDF export.

Determine:
- **Mode**: full (15-section) or summary (9-section) based on document structure
- **Language**: the dominant language of the SOW; the report is written in it (Step 5)
- **Completeness**: which sections are present, which are missing

If corporate standards are provided (or available via ~~knowledge base), load them for comparison.

### Step 2 — Domain Research (optional)

**Activation criteria:** the user explicitly requests domain-specific validation, OR the SOW covers a regulated domain (public procurement, healthcare, financial services) where industry-standard requirements apply.

If activated, dispatch parallel subagents to research relevant standards:
- Public sector SOW → research current procurement regulations (e.g., Codice degli Appalti D.Lgs. 36/2023)
- SaaS SOW → research standard SLA benchmarks for the industry
- Healthcare SOW → research HIPAA/regulatory requirements

Each subagent receives relevant SOW excerpts (not the full document) and returns findings that feed into the dimensional analysis.

### Step 3 — Dimensional Analysis

Score each of the 8 dimensions on a 1-5 scale. `Read references/review-checklist.md` for the detailed rubric per dimension and score level.

For each dimension:
1. Evaluate against the rubric criteria
2. Assign a score (1-5)
3. List specific evidence supporting the score
4. Identify issues (things that need fixing)
5. Suggest improvements (things that would raise the score)

The 8 dimensions:

| Dimension | What it checks |
|-----------|---------------|
| **Completeness** | All critical sections present? Missing sections flagged. Full: 15. Summary: 9. |
| **Clarity** | Scope unambiguous? Requirements measurable? No vague language? |
| **Consistency** | Deliverables in scope match deliverables table? Milestones aligned with timeline? |
| **Risk Coverage** | Risks identified? Mitigations actionable? Assumptions explicit? Dependencies documented? |
| **Commercial Adequacy** | Payment terms clear? Change process defined? Penalties proportionate? |
| **Collaboration Model** | Roles defined? RACI complete? Governance clear? Escalation paths documented? |
| **Best Practice Adherence** | Follows PMI/PMBOK patterns? Exclusions explicit? Acceptance criteria per deliverable? |
| **Corporate Standards** | If provided: formatting, terminology, required clauses, branding compliance |

If no corporate standards are provided, score Corporate Standards as N/A and compute the overall grade from 7 dimensions.

### Step 4 — Adversarial Pass

Role-play two adversarial perspectives. `Read references/common-pitfalls.md` for known exploitation patterns.

**As the Client:**
- What scope ambiguity could the vendor exploit to deliver less?
- Where could the vendor claim something is "out of scope" to avoid work?
- Are there enough controls to ensure quality?
- Could the vendor substitute less-qualified team members?

**As the Vendor:**
- What scope ambiguity could the client exploit to demand more?
- Are there unbounded obligations ("as needed", "all reasonable efforts")?
- Could the client delay acceptance indefinitely?
- Are penalties disproportionate to contract value?

For each exploitable gap, describe the scenario and recommend a specific fix.

### Step 5 — Report Generation

Produce a structured review report with these sections:

#### Scorecard

| Dimension | Score (1-5) | Key Evidence |
|-----------|:-----------:|-------------|
| Completeness | {SCORE} | {EVIDENCE} |
| Clarity | {SCORE} | {EVIDENCE} |
| Consistency | {SCORE} | {EVIDENCE} |
| Risk Coverage | {SCORE} | {EVIDENCE} |
| Commercial Adequacy | {SCORE} | {EVIDENCE} |
| Collaboration Model | {SCORE} | {EVIDENCE} |
| Best Practice Adherence | {SCORE} | {EVIDENCE} |
| Corporate Standards | {SCORE} or N/A | {EVIDENCE} |
| **Overall** | **{AVG}** | |

The overall score is the average of the scored dimensions, rounded to two decimals. Grade interpretation (each band includes its lower bound):
- **≥ 4.5**: Ready for signature
- **≥ 3.5 and < 4.5**: Minor improvements recommended
- **≥ 2.5 and < 3.5**: Significant gaps — revise before signing
- **≥ 1.5 and < 2.5**: Major rework needed
- **< 1.5**: Fundamental issues — reconsider approach

For example, 31/7 = 4.43 is "Minor improvements recommended" and 24/7 = 3.43 is "Significant gaps".

#### Critical Issues
Must-fix items before signing: missing sections, contradictions, legal gaps, unbounded obligations.

#### Improvements
Should-fix items for quality: vague language, missing traceability, weak acceptance criteria, incomplete RACI.

#### Adversarial Challenges
"If I were the client/vendor, I would exploit..." scenarios with specific fixes.

#### Standards Compliance (if applicable)
Checklist of corporate standard requirements with pass/fail per item.

**Report language.** Write the whole report in the SOW's language: headings, dimension names, grade labels, findings and adversarial scenarios. For an Italian SOW, use these dimension names: Completezza, Chiarezza, Coerenza, Copertura dei rischi, Adeguatezza commerciale, Modello di collaborazione, Aderenza alle best practice, Standard aziendali; adversarial scenarios refer to the Italian context where relevant (e.g. the Codice degli Appalti, D.Lgs. 36/2023). If the SOW mixes languages, use the dominant one and say so in the report.

Save the report as `<project-name>-sow-review.md` in the output folder: `OutputDir` in the project's `CLAUDE.md` section `## project-management Configuration`; if it is not set, ask the user (suggest `docs/outbox/`) and record it. When the SOW name carries a version, include it (`<project-name>-sow-v0.2.0-review.md`), so each review stays next to the version it reviewed. Never overwrite an existing report: if the name is taken, add `-2`, `-3`, … before `.md`.

---

## 3. Progressive Disclosure

| Step | Documents to Read |
|------|-------------------|
| Steps 1-2 | (no references — document ingestion and research) |
| Step 3 | `references/review-checklist.md` + `references/best-practices.md` |
| Step 4 | `references/common-pitfalls.md` |
| Step 5 | (no references — report generation) |

---

## 4. Integration with Other Skills

- **After `sow-write`**: run `sow-review` on the generated SOW to identify gaps before sharing with stakeholders
- **Before `sow-estimate`**: review ensures the SOW's scope and phases are well-defined enough for WBS extraction
- **Feedback loop**: review findings can be fed back into `sow-write` for targeted revisions
