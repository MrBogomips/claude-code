---
name: sow-write
description: "Write professional Statements of Work (SOW) in full (15-section enterprise) or summary (9-section contract extraction) mode. Auto-detects language from input documents, supports English and Italian with language packs. Produces structured markdown with optional research subagents for domain gaps. Use this skill whenever the user wants to write a SOW, create a statement of work, draft a proposal, write a capitolato tecnico, prepare an offerta, or mentions 'scrivi SoW'. Also triggers for 'project proposal', 'scope document', 'service agreement draft', or any request to formalize project scope into a deliverable document."
---

# SOW Write — Statement of Work Generator

## 1. Overview

This skill writes professional Statements of Work from project briefs, PRDs, contracts, meeting notes, or any combination of input documents. It operates in two modes:

- **Full mode** (15 sections) — enterprise SOW for new engagements, detailed technical proposals, or formal bids
- **Summary mode** (9 sections) — contract-extraction SOW for existing agreements, renewals, or scope addenda

The skill auto-detects language from input documents and produces output in the detected language. When language is ambiguous (mixed-language inputs), it asks the user to choose. Language packs provide localized section headers, boilerplate text, and legal terminology.

**Output directory:** `docs/outbox/` (configurable)

**Connector support:** Skills degrade gracefully without connectors. See `CONNECTORS.md` for the full registry.

- If **~~knowledge base** is connected: pull existing project templates and corporate standards
- If **~~document storage** is connected: search for related documents and past SOWs
- If **~~CRM** is connected: pull client context for personalization
- If **~~calendar** is connected: check team availability for scheduling sections
- If **~~email** is connected: share SOW drafts with stakeholders

---

## 2. Pipeline

### Step 1 — Input Analysis

Read all provided documents (notes, PRDs, briefs, contracts, emails, meeting transcripts). For each document:
- Identify document type (brief, contract, RFP, meeting notes, technical spec)
- Extract key entities: parties, dates, deliverables, constraints, budget references
- Detect language (count tokens per language, flag if mixed > 20%)
- Rate input maturity: **rich** (clear scope, parties, timeline) / **partial** (gaps in 2+ critical areas) / **thin** (high-level only)

If connectors are available:
- **~~knowledge base**: search for existing templates matching the project domain
- **~~document storage**: search for related documents (past SOWs for the same client, similar projects)

Save analysis to `docs/outbox/<project-name>-input-analysis.md`.

### Step 2 — Mode Selection

If not specified by the user, recommend a mode based on input analysis:
- Input contains an existing contract or formal agreement → recommend **summary**
- Input is a brief, PRD, or meeting notes → recommend **full**

Ask the user to confirm. Also ask for language if the analysis flagged ambiguity.

### Step 3 — Domain Research (optional)

**Activation criteria:** the user explicitly requests research, OR the Input Analysis flags critical knowledge gaps:
- Undefined technical stack or architecture approach
- Unclear regulatory context (public procurement, GDPR, industry-specific)
- Missing domain terminology or business model
- Vague acceptance criteria with no industry benchmarks

Before dispatching, present the gaps to the user: "I've identified gaps in [topics]. Should I research these before proceeding?"

If approved, dispatch **parallel subagents** (up to 3 concurrently). Each subagent receives:
- A focused research question
- Relevant context extracted from input documents (not the full session history)
- Expected output format: findings, implications for the SOW, recommended approach, sources

Example dispatch:
```
Subagent 1: "Research multi-tenant authentication patterns for B2B SaaS — compare OAuth2, SAML, OIDC. Context: [extracted tech stack notes]"
Subagent 2: "Research GDPR data residency requirements for EU SaaS platforms handling PII. Context: [extracted compliance notes]"
Subagent 3: "Research pricing models for AI-powered SaaS in the [vertical]. Context: [extracted business model notes]"
```

Present research results to the user for review before incorporating.

### Step 4 — Clarification Round

Ask 3-5 targeted questions based on gaps remaining after input analysis and research:
- Missing acceptance criteria → "How will deliverables be accepted?"
- Unclear parties → "Who is the contracting entity?"
- No timeline hints → "Do you have target dates or a preferred duration?"
- Missing budget context → "Is there a budget envelope or should economics be open?"
- Unclear governance → "Who approves change requests?"

Research findings (if step 3 ran) inform these questions — don't ask about topics already resolved by research.

### Step 5 — Structure Proposal

Present the section outline with one-line summaries per section. Use the appropriate template:
- Full mode: `Read references/template-full.md`
- Summary mode: `Read references/template-summary.md`

Load the appropriate language pack: `Read references/language-packs/{lang}.md`

The user approves the outline before writing begins. They may request section reordering, additions, or removals.

### Step 6 — Section Generation

Generate sections progressively, presenting each for review before moving to the next. Load `references/section-guidance.md` for per-section writing advice and quality criteria.

For each section:
1. Load the section template and guidance
2. Generate content using input documents, research findings, and clarification answers
3. Apply language pack for localized headers and boilerplate
4. Present to user for review

**Special handling for Full Mode Section 10 (Economics):**
Insert a placeholder with instruction to run `sow-estimate` to populate:
```markdown
## 10. Economics

> **[Placeholder]** Run `sow-estimate` on this SOW to generate economics from WBS extraction
> and PERT three-point estimation. This section will be populated with:
> - Effort summary per phase (CAPEX/OPEX breakdown)
> - Rate card and resource allocation
> - Payment schedule aligned with milestones
> - Confidence intervals from PERT analysis
```

### Step 7 — Consistency Check

Before final output, verify:
- All deliverables mentioned in Scope appear in the Deliverables table
- All milestones have dates (or date placeholders if timeline is indicative)
- Assumptions are numbered and referenced where relevant
- Exclusions don't contradict scope statements
- Roles in the collaboration section match roles referenced in deliverables
- Cross-references between sections are consistent (e.g., risk IDs in risk section match risk references in scope)

Flag any inconsistencies to the user with specific fix recommendations.

### Step 8 — Output

Save the completed SOW to `docs/outbox/<project-name>-sow-v0.1.0.md`.

Present a summary: section count, word count, language, mode, any placeholders remaining, and suggested next steps (run `sow-review` for quality check, run `sow-estimate` for economics).

---

## 3. Full Mode Sections (15)

| # | Section | Key content |
|---|---------|-------------|
| 1 | Document Control | Version, date, status, signatures, distribution list |
| 2 | Executive Summary | Purpose, business drivers, one-paragraph scope |
| 3 | Context & Objectives | Business context, vision, value proposition, measurable KPIs |
| 4 | Actors & Roles | User roles, stakeholders, RACI matrix |
| 5 | Scope | In-scope, out-of-scope, assumptions, constraints, dependencies |
| 6 | Multi-Phase Breakdown | Per-phase deliverables with acceptance criteria. Phase 1 detailed, later phases indicative |
| 7 | Technical Strategy | Architecture overview, build/buy/integrate decisions, integrations, NFRs |
| 8 | Collaboration Model | Team composition, ceremonies, governance, communication channels |
| 9 | Schedule | Timeline, milestones, critical path, mutual obligations |
| 10 | Economics | **Delegated to `sow-estimate`**. Placeholder with CAPEX/OPEX template |
| 11 | Risk Management | Risk register with P x I scoring, mitigations, contingency |
| 12 | Quality & Acceptance | Standards, testing approach, acceptance criteria, Definition of Done |
| 13 | Change Management | CR process, impact assessment, approval workflow |
| 14 | Other Terms | IP, privacy, confidentiality, warranty, termination |
| 15 | Annexes | Requirements matrix, glossary, references |

---

## 4. Summary Mode Sections (9)

| # | Section | Key content |
|---|---------|-------------|
| 1 | Contract References | Source contract IDs, amendment history, effective dates |
| 2 | Scope | In-scope, out-of-scope, assumptions |
| 3 | Deliverables Table | Deliverable, description, acceptance criteria, owner |
| 4 | Milestones & Billing | Milestone, date, payment amount, cumulative % |
| 5 | SLAs | Metric, target, measurement method, penalty |
| 6 | Team | Role, name, allocation %, billable flag |
| 7 | Governance | CR process, penalties, warranty terms |
| 8 | Contacts | Role, name, email, phone |
| 9 | Notes & Cross-references | Links to parent contract, related SOWs, annexes |

---

## 5. Progressive Disclosure

| Step | Documents to Read |
|------|-------------------|
| Step 1-4 | (no references — in-skill analysis and interaction) |
| Step 5 | `references/template-full.md` OR `references/template-summary.md` + `references/language-packs/{lang}.md` |
| Step 6 | `references/section-guidance.md` (per-section as needed) |
| Step 7-8 | (no additional references — in-skill verification) |

---

## 6. Language Detection

Count language-specific tokens across all input documents. Classification:
- **>80% single language** → auto-select that language
- **60-80% dominant language** → recommend dominant, ask user to confirm
- **<60% any language** → ask user to choose

Supported languages and their packs:
- `en` — `references/language-packs/en.md`
- `it` — `references/language-packs/it.md`

For unsupported languages: generate section headers in the detected language, use English guidance internally, note the limitation to the user.
