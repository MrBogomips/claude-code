---
name: bid-delivery-summary
description: "Distill a software project assessment, estimation, technical analysis, architecture study, solution design or AI-generated evaluation into an INTERNAL commercial and delivery summary for sales, bid, account, delivery, project and resource managers and executives — scope, resources, effort, activities, milestones, assumptions, risks, dependencies, commercial considerations, a bid-readiness verdict and a delivery-readiness assessment. Effort-only unless an approved cost model is present and authorized. English or Italian. Use when asked for an internal, commercial, bid or delivery summary of an assessment, or whether a project is ready to bid or propose (e.g. 'is this ready to bid', 'riepilogo interno', 'sintesi per l'offerta', 'siamo pronti per l'offerta')."
---

# Bid & Delivery Summary — Internal Commercial & Delivery Brief

## 1. Overview

This skill analyzes a software project assessment — an estimation document, technical analysis,
architecture study, solution design, or AI-generated project evaluation — and produces a concise but
comprehensive **internal** summary that supports commercial evaluation, proposal preparation,
staffing decisions, delivery planning, and project governance.

It is the internal counterpart to `client-facing-doc`: where that skill strips confidential content
to produce an external deliverable, this skill foregrounds the planning-relevant substance (effort,
roles, risks, dependencies, readiness) for an internal audience.

**Intended audience:** sales teams, account managers, delivery managers, project managers, practice
leads, resource managers, bid managers, and executive stakeholders involved in proposal preparation
and delivery planning.

**The output focuses on actionable information and decision support, not implementation detail.**

Four rules are mandatory and non-negotiable:

1. **Confidentiality header** — the document always begins with the verbatim `INTERNAL USE ONLY`
   notice from the language pack.
2. **Cost-model authorization gate** — the skill never invents costs, rates, or margins. Cost figures
   appear only when an approved cost model is present **and** the user explicitly authorizes its use.
   Otherwise the output is effort-only, expressed in Person-Days (PD) / Man-Days (MD).
3. **Audience-aware section plan** — before generation, the skill proposes which of the standard
   sections to *include* and which to *remove*, given the source content and the internal audience,
   and asks the user to confirm or adjust.
4. **Summary only** — the output document contains no reasoning, chain-of-thought, AI commentary,
   editorial notes, or meta-observations about the source.

The skill pauses for the user at two points: the cost-model gate (Step 3) and the section-plan
approval (Step 4). Everything else runs automatically.

**Output:** the internal summary → `<deliverables>/<doc-name>-internal-summary-v<N>.md`, where `<deliverables>` is the output folder the project's CLAUDE.md declares; if none is declared, ask the user (suggest `docs/outbox/`). The
`INTERNAL USE ONLY` header carries the confidentiality semantics.

The skill auto-detects language from the input and produces output in the detected language.
Supported languages: English (`en`) and Italian (`it`). The user may override with an explicit choice.

**Connector support:** Skills degrade gracefully without connectors. See `CONNECTORS.md` for the
full registry.

- If **~~knowledge base** is connected: search for approved cost models, rate cards, service-catalog
  pricing, and commercial estimation frameworks (used only by the Step 3 authorization gate).

If no connector is available, the skill relies on the provided documents and conversation context and
proceeds effort-only when no approved cost model is found.

---

## 2. Pipeline

### Step 1 — Input Ingestion & Normalization

Read all provided source documents. If a source is not Markdown (PDF, DOCX, PPTX, XLSX, HTML), convert
it first with a connected **~~document converter** (for example markitdown's `convert_to_markdown`);
if none is connected, read it with the tools available and tell the user about any source that cannot be read.

Detect language by counting language-specific tokens across the input (house thresholds: >80% →
auto-select; 60–80% → recommend and confirm; <60% → ask).

Establish a working `<doc-name>` (slug from the source title or filename) for output naming.

### Step 2 — Source Analysis & Extraction

`Read references/extraction-principles.md`

Build a structured working model of the project from the source: scope and functional domains, roles
and competencies, effort figures, activities, milestones, assumptions, risks, and dependencies.

Apply the extraction principles:
- Prioritize actionable, decision-relevant information
- Consolidate duplicated information and reconcile inconsistent estimates where possible
- **Explicitly flag ambiguities and list missing information** — these feed the bid-review checklist
- Preserve assumptions, constraints, and estimation rationale that affect planning decisions
- Exclude implementation detail that does not affect planning, staffing, effort, risk, schedule, or
  commercial decisions

### Step 3 — Cost-Model Verification (Mandatory Gate)

`Read references/cost-model-verification.md`

Before producing any cost-related information, run the authorization logic:
1. Scan the provided documents, conversation, connected **~~knowledge base**, and any supplementary
   material for an **approved cost model** (rate card, internal costing table, service-catalog
   pricing, pricing matrix, cost-allocation model, commercial estimation framework).
2. **If one or more approved cost models are found:** inform the user and **ask for explicit
   confirmation** before using any of them. Do not calculate costs without confirmation.
3. **If none is found:** produce effort-only output in PD/MD. Do not infer, estimate, or invent costs,
   rates, margins, or pricing assumptions.

Record the resulting mode (effort-only vs cost-authorized) for the section plan and generation.

### Step 4 — Section Plan Proposal (Audience-Aware)

`Read references/summary-structure.md`

**Audience for this skill: internal — the document is *not* going to the customer.** Because the
audience is internal, the commercial, effort, resource, and risk sections that a client-facing version
would strip are exactly what belongs here. Against the 13 standard sections, and given what the source
actually supports, classify each:

- **Include** — sections the source can populate with decision-relevant substance for sales, bid, and
  delivery stakeholders.
- **Remove** — sections that are not applicable to this engagement or that the source cannot support
  at all (proposing an empty section adds noise). Note Commercial Considerations is *included* in
  effort-only mode — it carries the "no approved cost model" statement, not costs.

Present the plan as two short lists (Include / Remove) with a one-line rationale per removed section,
and call out any section the source leaves thin (it will be included but flagged as a gap in the Bid
Review Checklist). **Ask the user to confirm or adjust** before generating. Treat the confirmed list
as the section set for Step 5.

> Default to including all 13 sections; removal is the exception, justified by non-applicability or a
> total absence of source material. The mandatory `INTERNAL USE ONLY` notice and the Bid Review
> Checklist are never removed.

### Step 5 — Section Generation

`Read references/summary-structure.md` and `Read references/language-packs/{lang}.md`

Generate the confirmed sections in order, opening with the verbatim `INTERNAL USE ONLY` notice
from the language pack. The full standard set is:

1. Executive Summary
2. Scope Summary
3. Resource Requirements
4. Effort Estimation Summary
5. Resource Allocation Plan
6. High-Level Activities
7. Milestones
8. Assumptions
9. Risks
10. Dependencies
11. Commercial Considerations
12. Bid Review Checklist (ends with the Bid Readiness Conclusion)
13. Delivery Readiness Assessment

Use tables where the structure specifies them (resource requirements, effort breakdowns, risks).
Prefer structured sections, tables, bullet points, and action-oriented language. Avoid implementation
deep-dives, architectural detail, marketing language, and verbosity. Clearly distinguish effort
estimates, cost estimates (only if authorized), and commercial assumptions.

### Step 6 — Output

Write the internal summary to `<deliverables>/<doc-name>-internal-summary-v<N>.md` (start at `v1`;
increment the suffix if the target already exists).

Present a brief summary to the user (outside the document): the Bid Readiness Conclusion, the Delivery
Confidence Level, whether costs were included or the output is effort-only, the count of flagged gaps
and customer questions, and the detected language. If a DOCX-generation skill is available (for example
`document-skills:docx`), offer optional DOCX conversion with it.

---

## 3. Progressive Disclosure

| Step | Documents to Read |
|------|-------------------|
| Step 1 | (no references — ingestion, conversion via **~~document converter**, language detection) |
| Step 2 | `references/extraction-principles.md` |
| Step 3 | `references/cost-model-verification.md` |
| Step 4 | `references/summary-structure.md` (audience-aware section plan) |
| Step 5 | `references/summary-structure.md` + `references/language-packs/{lang}.md` |
| Step 6 | (no references — output and user summary) |

---

## 4. Self-Check Rules

Before writing output, the skill validates itself:

1. **Confidentiality header present** — the document begins with the verbatim `INTERNAL USE ONLY`
   notice. A summary without it is incomplete.
2. **No unauthorized costs** — no cost, rate, price, or margin figure appears unless an approved cost
   model was found in Step 3 **and** the user explicitly authorized it. When effort-only, Commercial
   Considerations contains the standard "no approved cost model" statement and nothing more.
3. **Effort in PD/MD** — all effort is expressed in Person-Days or Man-Days, with confirmed /
   estimated / assumed / contingency effort distinguished where the source allows.
4. **Effort vs cost vs commercial assumptions are separated** — never conflate them.
5. **Missing information is explicit** — gaps, ambiguities, and unknowns are listed, not silently
   omitted. They appear in the Bid Review Checklist.
6. **Readiness verdicts are enumerated** — the Bid Readiness Conclusion is exactly one of the four
   defined verdicts, and the Delivery Confidence Level is High / Medium / Low, each with a rationale.
7. **Section plan honored** — the document contains exactly the sections confirmed in Step 4 and none
   that were removed; the `INTERNAL USE ONLY` notice and the Bid Review Checklist are always present.
8. **Summary only** — the document contains no chain-of-thought, AI commentary, editorial notes, or
   meta-observations about the source.

---

## 5. Language Detection

Count language-specific tokens across the input. Classification:

- **>80% single language** → auto-select that language for output
- **60–80% dominant language** → recommend the dominant language, ask the user to confirm
- **<60% any language** → ask the user to choose

Supported languages:
- `en` — English (`references/language-packs/en.md`)
- `it` — Italian (`references/language-packs/it.md`)

For unsupported languages: produce section labels in the detected language, apply the English
structure and guidance internally, and note the limitation to the user. The `INTERNAL USE ONLY`
notice is emitted in the closest supported language.
