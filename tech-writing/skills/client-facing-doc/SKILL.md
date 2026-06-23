---
name: client-facing-doc
description: "Convert internal or reserved technical documentation (assessments, estimations, AI-assisted drafts, internal notes) into a polished, client-facing deliverable. Silently removes all confidential content — costs, rates, budgets, effort estimates, estimation work breakdowns, resource assumptions, internal planning, AI prompts and intermediate artifacts, drafts, TODOs, internal references — while preserving and improving the customer-relevant technical substance (architecture, scope, NFRs, constraints, design decisions, dependencies, externally-communicable risks). Produces the deliverable in docs/outbox/ and a separate redaction audit in .aidocs/ for verification. Auto-detects language (English/Italian). Use when the user says 'make this client-facing', 'customer-ready version', 'redact this internal document', 'externalize this assessment', 'prepare this for the client', 'rendi questo documento condivisibile', 'versione per il cliente', 'documento per il cliente', or 'sanitizza questo documento interno'."
---

# Client-Facing Doc — Internal-to-External Document Converter

## 1. Overview

This skill transforms internal or reserved technical documentation into a professional,
client-facing deliverable suitable for technical stakeholders — solution and enterprise architects,
technical leads, engineering and IT managers, project sponsors, and technical customer
representatives.

It performs two jobs at once:

1. **Confidential removal** — it strips every piece of content that is inappropriate for external
   distribution (cost and effort estimates, rates, budgets, internal planning, AI artifacts, drafts,
   internal notes and references), treating any doubtful item as confidential.
2. **Customer-grade rewrite** — it preserves and improves the technical substance the customer needs,
   rewriting fragmented or AI-summarized content into coherent consultative prose so the result reads
   as if it had been authored for the customer from the start.

**Interaction model: one approval checkpoint, then automated.** Before generation, the skill presents
an **audience-aware section plan** — which source sections it proposes to *include* (rewritten for the
customer) and which to *remove* (confidential or internal-only) — for the user to confirm or adjust
(Step 2). Once the plan is approved, execution is automated: within the included sections, removal of
fine-grained confidential snippets happens silently in a single pass, and anything ambiguous is
removed. Verification happens **after** the fact through a separate redaction audit, so a leak can be
caught before the document is shared.

**Outputs:**
- **Client deliverable** → `docs/outbox/<doc-name>-client-v<N>.md`
- **Redaction audit** (verification trail, never shared) → `.aidocs/<doc-name>-redaction-audit.md`

The original source document is never modified.

The skill auto-detects language from the input and produces output in the detected language.
Supported languages: English (`en`) and Italian (`it`). The user may override with an explicit choice.

**Connector support:** Skills degrade gracefully without connectors. See `CONNECTORS.md` for the
full registry.

- If **~~knowledge base** is connected: pull the corporate style guide, terminology glossary, and
  naming standards to standardize terminology and expand acronyms consistently.

If no connector is available, the skill proceeds with its built-in style guide and states what a
knowledge base connection would add.

---

## 2. Pipeline

### Step 1 — Input Ingestion & Normalization

Read all provided source documents. If a source is not Markdown (PDF, DOCX, PPTX, XLSX, HTML), convert
it to Markdown first using the `markitdown` MCP tool (`convert_to_markdown`). Do not attempt manual
extraction when the tool is available.

Detect language by counting language-specific tokens across the input. Classification thresholds
match the house convention:
- **>80% single language** → auto-select that language
- **60–80% dominant language** → recommend the dominant language, ask the user to confirm
- **<60% any language** → ask the user to choose

Establish a working `<doc-name>` (slug derived from the source title or filename) for output naming.

### Step 2 — Section Plan Proposal (Audience-Aware)

`Read references/confidential-taxonomy.md` and `Read references/preserve-checklist.md`

**Audience for this skill: external — the document is going to the customer.** Map the source's
section structure (its headings and major content blocks) and, against that audience, classify each
section:

- **Include** — sections carrying customer-relevant substance (architecture, scope, NFRs, design
  decisions, dependencies, integration, deployment, externally-communicable risks). These will be
  preserved and rewritten.
- **Remove** — sections that are confidential or internal-only for an external audience (cost/effort
  estimates, internal planning, AI artifacts, drafts, internal notes). These will be dropped entirely.
- **Partial** — sections that mix both; mark which substance is kept and which detail is stripped.

Present this plan to the user as two short lists (Include / Remove, with Partial noted) plus a
one-line rationale per removed section, then **ask the user to confirm or adjust** before proceeding.
The user may move a section between Include and Remove, or split a Partial. Treat the confirmed plan
as the structural contract for the rest of the pipeline.

> If the source has no discernible section structure (a flat note), propose an Include/Remove plan
> over its major content blocks instead.

### Step 3 — Confidential Detection & Removal

`Read references/confidential-taxonomy.md`

Working within the sections the user kept, scan against every category in the taxonomy and **silently
remove** all matches —
both clear-cut items and any item where there is *doubt* about its suitability for a customer
audience. Removal must be clean: never leave a placeholder, redaction marker, ellipsis, or note that
references the removal or its reason in the client text.

For each removal, append an entry to an in-memory **audit buffer**:
- `location` — section/heading or approximate position in the source
- `snippet` — a short excerpt of the removed content (enough to identify it)
- `category` — the taxonomy category it matched
- `reason` — why it is unsuitable for external distribution

### Step 4 — Preservation & Restructuring

`Read references/preserve-checklist.md`

Keep all customer-relevant technical substance. Then improve the document's structure:
- Reorganize sections for a logical reading order
- Improve titles and headings
- Remove redundancies and resolve inconsistencies
- Standardize terminology (use the **~~knowledge base** glossary if connected)
- Expand condensed or AI-summarized fragments and bullet stubs into coherent technical prose
- Convert fragmented notes into well-developed descriptions

Do not invent technical facts. Expansion means rendering existing content as complete prose with
appropriate context and rationale — not adding claims the source does not support.

### Step 5 — Style Rewrite

`Read references/style-guide.md` and `Read references/language-packs/{lang}.md`

Apply the consultative enterprise voice defined in the style guide:
- Complete sentences with contextual explanation and rationale; logical transitions between sections
- Expand acronyms on first use unless universally recognized; eliminate organization-specific
  abbreviations and internal jargon
- No marketing language, no AI-style summarization, no unnecessary verbosity, no bullet-only
  explanations where prose is warranted
- No meta-references to the conversion, to AI, to internal revisions, or to removed content

Use the language pack for localized section labels and boilerplate.

### Step 6 — Verification Self-Check (Security Boundary)

Re-scan the **generated output** for residual confidential markers before writing anything. This is
the last line of defense against a leak. Flag and remove (logging each to the audit buffer):
- Currency symbols and rate/price patterns (`€`, `$`, `£`, `k/day`, `/day`, `/hour`, `per diem`)
- Effort/estimate patterns: `\b\d+\s*(gg|pd|dev-days|man-days|person-days|giorni/uomo)\b`
- Internal-status terms: `TODO`, `FIXME`, `WIP`, `draft`/`bozza`, `internal`/`interno`/`riservato`,
  `confidential`/`riservato`
- AI/process leakage: prompt fragments, "as an AI", chain-of-thought phrasing ("let me think",
  "step 1: I will"), references to AI tools or generated artifacts
- References to internal or unpublished documents ("see internal deck", "per the estimation sheet")

If any match survives into the output, remove it and record it. The document must read as if
originally authored for the customer.

### Step 7 — Output

Write the client deliverable to `docs/outbox/<doc-name>-client-v<N>.md` (start at `v1`; increment the
suffix if the target already exists, per the document-collision convention).

Write the redaction audit to `.aidocs/<doc-name>-redaction-audit.md` using
`references/audit-template.md`, populated from the audit buffer.

Present a summary to the user:
- Removals by category (count)
- Residual-scan result (clean / items caught in Step 6)
- Word count and detected language
- Path to both output files
- An offer to convert the deliverable to DOCX via `document-skills:docx` or the `links-gc-xdoc` skill

---

## 3. Progressive Disclosure

| Step | Documents to Read |
|------|-------------------|
| Step 1 | (no references — ingestion, conversion via `markitdown`, language detection) |
| Step 2 | `references/confidential-taxonomy.md` + `references/preserve-checklist.md` (audience-aware section plan) |
| Step 3 | `references/confidential-taxonomy.md` |
| Step 4 | `references/preserve-checklist.md` |
| Step 5 | `references/style-guide.md` + `references/language-packs/{lang}.md` |
| Step 6 | (no references — in-skill residual scan) |
| Step 7 | `references/audit-template.md` |

---

## 4. Self-Check Rules

Before writing output, the skill validates itself:

1. **No-leak guarantee** — the client deliverable contains zero items from the confidential taxonomy.
   The Step 6 residual scan must run on the final text, not the source.
2. **No meta-references** — the deliverable contains no mention of the conversion, AI, internal
   revisions, drafts, removed content, or this skill. It reads as an original customer document.
3. **Every audit entry is categorized** — each entry in the redaction audit cites a taxonomy
   category and a reason. Uncategorized removals are not recorded as confident removals; re-examine.
4. **Treat doubt as confidential** — if suitability for a customer audience is uncertain, the item is
   removed, not kept. This rule is mandatory and overrides any preference to retain detail.
5. **Preserve without inventing** — restructuring and prose expansion must not introduce technical
   claims, figures, or commitments absent from the source.
6. **Audit stays internal** — the redaction audit is written only to `.aidocs/` and is never included
   in, linked from, or referenced by the client deliverable.
7. **Section plan honored** — the deliverable includes exactly the sections the user kept in Step 2 and
   none of the sections marked for removal. Deviations from the confirmed plan are not allowed without
   re-confirming with the user.

---

## 5. Language Detection

Count language-specific tokens across the input. Classification:

- **>80% single language** → auto-select that language for output
- **60–80% dominant language** → recommend the dominant language, ask the user to confirm
- **<60% any language** → ask the user to choose

Supported languages:
- `en` — English (`references/language-packs/en.md`)
- `it` — Italian (`references/language-packs/it.md`)

For unsupported languages: produce section labels in the detected language, apply the English style
guidance internally, and note the limitation to the user.
