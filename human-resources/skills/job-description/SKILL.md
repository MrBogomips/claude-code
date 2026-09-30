---
name: job-description
description: "Use when writing a new job description or job posting — 'write a job description', 'create a JD', 'job posting for', 'descrizione del lavoro', 'annuncio di lavoro', 'scrivi annuncio'. Uses a competency-based framework for technical roles and an outcome-based one for other roles, checks inclusive language and requirement inflation, asks for the pay range the EU requires, and runs compliance-check last; Italian or English output. Not for revising or auditing an existing JD (compliance-check audits it and writes a clean version)."
---

# Job Description — Professional JD Generator

## 1. Overview

This skill writes professional job descriptions for technical and non-technical positions. It applies two distinct frameworks depending on role type:

- **Competency-based framework** (technical roles) — identifies 4-6 core competencies with proficiency levels (foundational, intermediate, advanced, expert) and behavioral indicators
- **Outcome-based framework** (non-technical roles) — frames responsibilities as action + object + purpose with measurable success metrics

The skill auto-detects language from the conversation and produces output in the detected language. Supported languages: English (`en`) and Italian (`it`). When language is ambiguous, the skill asks the user to choose.

**Output file:** `{role}-job-description.md` in the output directory — the output folder the project's CLAUDE.md declares; if none is declared, ask the user (suggest `docs/outbox/`).

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

**Output format:** this skill writes Markdown. If the user needs a Word file, offer in Step 8 to convert the Markdown with a document skill or tool available in the session; if none is available, deliver the Markdown and say so.

**Revising an existing JD:** this skill writes new JDs. To revise an existing one, suggest compliance-check in standalone mode, which audits it and can write a corrected ("clean") version; or, if the user wants a rewrite, use the existing JD as source material for Steps 1–3 here.

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
4. **Compensation and benefits** — ask for the pay range and top benefits. In EU jurisdictions, tell the user that Directive 2023/970 requires the pay range (or initial pay) to reach applicants before the interview, for example in the ad; a JD without it, and without saying how the range will be given, gets a WARNING from compliance-check (see compliance-check's `legal-map.md` Section 3; check the current national transposition)
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

1. **Flag the issue** to the user: "This JD lists [N] required qualifications. A common rule of thumb is to keep required items to about 8: every extra requirement discourages people who meet most but not all of them, and a widely cited HP internal report found that women tend to apply only when they meet all listed requirements."
2. **Recommend specific items to move** from "Required" to "Preferred" — prioritize items that are learnable on the job or not day-one necessities.
3. **Wait for user confirmation** before making changes.

Also check for:
- Years-of-experience inflation (e.g., "10+ years in a technology that is 5 years old")
- Expert-level requirement in more than 3 areas
- Redundant requirements that test the same underlying skill

### Step 7 — Compliance Validation (last check before output)

Run compliance-check on the draft after all the fixes from Steps 5–6. Load compliance-check with the Skill tool and the arguments `embedded jd`, adding the jurisdiction (`italy`, `eu` or `general`) if the user specified one; otherwise it is auto-detected. The call is defined in compliance-check's Section 5. If the Skill tool cannot load it, read `../compliance-check/SKILL.md` and apply its embedded mode.

Process the returned findings:

| Severity | Action |
|----------|--------|
| `CRITICAL` | Must fix before output. Apply the suggested fix and notify the user. |
| `WARNING` | Present to the user with the suggested fix. Apply if the user agrees. |
| `INFO` | Present as recommendations. Apply only if the user requests. |

If compliance-check returns any CRITICAL findings, loop back to fix and re-validate until the draft passes. Any later change to the text, including a WARNING fix the user accepts, is re-validated before output.

### Step 8 — Output

Apply all confirmed fixes from Steps 5-7 and produce the final JD.

Save as `{role}-job-description.md` in the output directory (where `{role}` is the sanitized role title, lowercase, hyphens for spaces).

Present a summary to the user:
- Framework used (competency-based / outcome-based / hybrid)
- Section count and word count
- Language
- Required qualifications count (with green/yellow/red indicator vs. the 8-max threshold)
- Compliance status (Pass / Pass with warnings / Fail — from Step 7)
- Any remaining placeholders (e.g., salary range TBD — in EU jurisdictions, a compliance WARNING until the range is added)
- Suggested next steps: share with hiring manager for review, run pre-screening to create a candidate evaluation questionnaire; offer a Word conversion if the user needs one

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

- [Pay range — in EU jurisdictions, required before the interview]
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

Use the dominant language of the input documents and conversation for output. When the inputs clearly mix languages, recommend the dominant language and ask the user to confirm; when no language dominates, ask the user to choose.

Supported languages:
- `en` — English
- `it` — Italian

For unsupported languages: produce the JD structure in the detected language where possible, use English guidance internally, and note the limitation to the user.
