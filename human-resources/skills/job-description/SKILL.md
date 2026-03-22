---
name: job-description
description: "Write professional job descriptions for both technical and non-technical positions. Uses competency-based framework for technical roles (identifying 4-6 core competencies with proficiency levels) and outcome-based framework for non-technical roles (action + object + purpose). Checks inclusive language, flags requirements inflation (>8 requirements), and invokes compliance-check validation before final output. Auto-detects conversation language for Italian/English output. Integrates with **~~knowledge base** for existing JD templates. Use when the user says 'write a job description', 'create a JD', 'job posting for', 'descrizione del lavoro', 'annuncio di lavoro', 'scrivi annuncio', or mentions creating a position listing."
---

# Job Description — Professional JD Generator

## 1. Overview

This skill writes professional job descriptions for technical and non-technical positions. It applies two distinct frameworks depending on role type:

- **Competency-based framework** (technical roles) — identifies 4-6 core competencies with proficiency levels (foundational, intermediate, advanced, expert) and behavioral indicators
- **Outcome-based framework** (non-technical roles) — frames responsibilities as action + object + purpose with measurable success metrics

The skill auto-detects language from the conversation and produces output in the detected language. Supported languages: English (`en`) and Italian (`it`). When language is ambiguous, the skill asks the user to choose.

**Output file:** `{role}-job-description.md`

**Connector support:** Skills degrade gracefully without connectors. See `CONNECTORS.md` for the full registry.

- If **~~knowledge base** is connected: search for existing JD templates, corporate career page guidelines, and brand voice standards
- If no connector is available: ask the user for company context, templates, and brand guidelines manually

---

## 2. Pipeline

### Step 1 — Role Analysis

Gather the essential role parameters through conversation:

1. **Role type**: technical, non-technical, or hybrid
2. **Job title**: proposed title (validate for gender neutrality)
3. **Department / team**: organizational placement
4. **Location**: on-site, hybrid, remote (specify geographic constraints if any)
5. **Reporting line**: title of the direct manager (not the person's name)
6. **Employment type**: full-time, part-time, contract, fixed-term (with duration)

**Corporate context with memory:** Check the user's memory for previously saved information:
- Corporate career page URL or brand guidelines
- Company name, industry, and tone preferences
- Previously used equal opportunity statement
- Standard benefits package

If not found in memory, ask the user. Save new corporate context to memory for future invocations.

**Output format preference:** On first invocation, ask the user which output format they prefer:
- `.md` (markdown, default)
- `.docx` (note: downstream conversion; this skill produces markdown)

Save the preference to memory. On subsequent invocations, use the saved preference without asking.

### Step 2 — Framework Selection

Based on the role type identified in Step 1, select the appropriate framework:

- **Technical role** → `Read references/competency-framework.md` → use the **competency-based** approach. Identify 4-6 core competencies from the domain-specific examples. Assign a required proficiency level (L1-L4) to each.
- **Non-technical role** → `Read references/competency-framework.md` → use the **outcome-based** approach. Frame each responsibility using the action + object + purpose pattern.
- **Hybrid role** → use both: 2-3 technical competencies with proficiency levels, plus outcome-based responsibilities for non-technical aspects.

Present the selected framework and proposed competencies/responsibilities to the user for confirmation before proceeding.

### Step 3 — Requirements Gathering

Collect detailed information for the JD:

1. **Responsibilities** — ask the user for 5-8 key responsibilities (guide them toward the appropriate framework pattern)
2. **Required qualifications** — gather must-have qualifications (enforce the 8-maximum limit during gathering)
3. **Preferred qualifications** — gather nice-to-haves (3-5 items)
4. **Compensation and benefits** — ask for salary range (note legal requirements by jurisdiction) and top benefits
5. **Team and culture context** — concrete details about working environment, team size, methodologies

If **~~knowledge base** is connected: search for existing JDs for similar roles in the organization. Present any matches to the user as starting points or references. Pull corporate benefits boilerplate and equal opportunity statement if available.

If **~~knowledge base** is not available: ask the user directly for any existing JD templates, benefits information, or equal opportunity statements they want to include.

### Step 4 — Draft Generation

Produce the JD following the template structure defined in `references/competency-framework.md` Section 4:

1. **About the Role** — role summary, department, location, reporting line, employment type
2. **Key Responsibilities** — 5-8 items using the selected framework pattern
3. **Required Qualifications** — maximum 8 items with proficiency levels (technical) or outcome-enabling descriptions (non-technical)
4. **Preferred Qualifications** — 3-5 nice-to-haves
5. **What We Offer** — compensation range, benefits, growth opportunities, work environment
6. **Equal Opportunity Statement** — jurisdiction-appropriate statement with reasonable accommodation language

Apply the detected language throughout. Use the corporate brand voice if available from memory or user input.

### Step 5 — Inclusive Language Check

`Read references/inclusive-language-guide.md`

Scan the entire draft against the inclusive language guide. Check for:

1. **Gendered language** — masculine-coded words (ninja, rockstar, competitive, assertive, dominant), gendered pronouns, gendered job titles
2. **Ageist language** — digital native, young and dynamic, recent graduate, seasoned, years-of-experience as hard gate
3. **Ableist language** — non-essential physical requirements, unnecessary medical standards
4. **Exclusionary requirements** — unnecessary degree requirements without alternatives, insider jargon, experience inflation patterns
5. **Textio 5Cs** — verify clarity, conciseness (target 700 words or fewer), competency-focus, culture-signaling (show don't tell), compliance

For each issue found, apply the replacement from the guide automatically. Present a summary of changes to the user:

| Original | Issue | Replacement |
|----------|-------|-------------|
| "Ninja developer" | Masculine-coded, informal | "Experienced developer" |

### Step 6 — Requirements Inflation Check

Count the number of required qualifications in the draft. If the count exceeds 8:

1. **Flag the issue** to the user with the research context: "This JD lists [N] required qualifications. Research shows that listings with more than 8 requirements significantly reduce applicant diversity, as women tend to apply only when meeting 100% of requirements."
2. **Recommend specific items to move** from "Required" to "Preferred" — prioritize items that are learnable on the job or not day-one necessities.
3. **Wait for user confirmation** before making changes.

Also check for:
- Years-of-experience inflation (e.g., "10+ years in a technology that is 5 years old")
- Expert-level requirement in more than 3 areas
- Redundant requirements that test the same underlying skill

### Step 7 — Compliance Validation

Invoke the **compliance-check** skill in embedded mode, passing:

- `text` — the current draft content
- `document_type` — `jd`
- `jurisdiction` — auto-detected from language and content, or as specified by the user

Process the returned findings:

| Severity | Action |
|----------|--------|
| `CRITICAL` | Must fix before output. Apply the suggested fix and notify the user. |
| `WARNING` | Present to the user with the suggested fix. Apply if the user agrees. |
| `INFO` | Present as recommendations. Apply only if the user requests. |

If compliance-check returns any CRITICAL findings, loop back to fix and re-validate until the draft passes.

### Step 8 — Output

Apply all confirmed fixes from Steps 5-7 and produce the final JD.

Save to `{role}-job-description.md` (where `{role}` is the sanitized role title, lowercase, hyphens for spaces).

Present a summary to the user:
- Framework used (competency-based / outcome-based / hybrid)
- Section count and word count
- Language
- Required qualifications count (with green/yellow/red indicator vs. the 8-max threshold)
- Compliance status (Pass / Pass with warnings / Fail — from Step 7)
- Any remaining placeholders (e.g., salary range TBD)
- Suggested next steps: share with hiring manager for review, run pre-screening to create a candidate evaluation questionnaire

---

## 3. Progressive Disclosure

| Step | Documents to Read |
|------|-------------------|
| Step 1 | (no references — in-skill conversation and memory check) |
| Step 2 | `references/competency-framework.md` |
| Step 3 | (no additional references — in-skill requirements gathering) |
| Step 4 | (no additional references — uses framework loaded in Step 2) |
| Step 5 | `references/inclusive-language-guide.md` |
| Step 6 | (no additional references — in-skill quantitative check) |
| Step 7 | (no additional references — invokes compliance-check skill) |
| Step 8 | (no additional references — in-skill output assembly) |

---

## 4. Output Template

```markdown
# [Job Title] — [Department]

## About the Role

[2-3 sentence overview: purpose, impact, team context]

**Location:** [on-site / hybrid / remote — details]
**Reports to:** [Manager title]
**Employment type:** [full-time / part-time / contract]

## Key Responsibilities

- [Responsibility 1 — framework-appropriate format]
- [Responsibility 2]
- ...
- [Responsibility 5-8]

## Required Qualifications

- [Qualification 1 — with proficiency level for technical roles]
- [Qualification 2]
- ...
- [Maximum 8 items]

## Preferred Qualifications

- [Preferred 1]
- [Preferred 2]
- ...
- [3-5 items]

## What We Offer

- [Compensation range]
- [Benefit 1]
- [Benefit 2]
- [Growth/development opportunities]
- [Work environment specifics]

## Equal Opportunity

[Jurisdiction-appropriate equal opportunity statement with reasonable accommodation language]
```

---

## 5. Integration

This skill is the entry point of the HR interview workflow. Its output is consumed by:

- **pre-screening** — uses the JD to generate a candidate evaluation questionnaire aligned with the role's competencies and responsibilities
- **interview-prep** — uses the JD to design structured interview questions mapped to required qualifications and competencies
- **compliance-check** — validates the JD during the pipeline (Step 7) and can re-audit it in standalone mode at any time

The inclusive language guide (`references/inclusive-language-guide.md`) is also referenced by the **compliance-check** skill for enhanced bias detection across all HR document types.

---

## 6. Language Detection

Count language-specific tokens across the conversation. Classification:

- **>80% single language** → auto-select that language for output
- **60-80% dominant language** → recommend dominant, ask user to confirm
- **<60% any language** → ask user to choose

Supported languages:
- `en` — English
- `it` — Italian

For unsupported languages: produce the JD structure in the detected language where possible, use English guidance internally, and note the limitation to the user.
