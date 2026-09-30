---
name: compliance-check
description: "Use when an HR document needs a legal, bias or GDPR check — 'check compliance', 'review for bias', 'legal check', 'check this JD', 'audit this evaluation', 'controlla conformità', 'verifica discriminazioni'. Audits job descriptions, screening questionnaires, interview questions, position assessments and evaluation forms against Italian and EU anti-discrimination law, GDPR and the EU Pay Transparency Directive, and returns CRITICAL/WARNING/INFO findings with citations. The other HR skills call it as their last step (embedded mode). Not legal advice."
---

# Compliance Check — HR Document Compliance Validator

## 1. Overview

This skill reviews HR documents for legal compliance, bias, and discriminatory language. It validates job descriptions, screening questionnaires, interview questions, position assessments, and evaluation forms against Italian labor law, EU/GDPR requirements, the EU Pay Transparency Directive, and inclusive language best practices.

Its legal content comes from reviewer analysis, not from counsel. It is not legal advice: say so in every standalone report, and advise the user to verify findings with counsel before relying on them.

It operates in two modes:

- **Embedded mode** — invoked by the other HR skills (job-description, pre-screening, interview-prep, interview-close) as the last step before they write their output, through the call defined in Section 5. Receives draft text, returns a structured list of findings. No file output, no questions to the user.
- **Standalone mode** — audits any existing HR document provided by the user, and can produce a corrected ("clean") version, which is how an existing JD is revised. Produces a full compliance audit report saved to the output directory — the output folder the project's CLAUDE.md declares; if none is declared, ask the user (suggest `docs/outbox/`). When the audited document is about a named candidate, suggest a folder outside version control instead, and start the report with the confidentiality line used by the candidate skills (see Section 4).

The skill applies four analysis layers in sequence:

1. **Prohibited Topics Detection** — flags direct and indirect references to legally protected categories
2. **Biased Language Detection** — identifies gendered, ageist, ableist, or exclusionary phrasing
3. **GDPR Data Handling** — checks data minimization, transparency, retention, and special category data risks
4. **Structural Compliance** — validates document-type-specific rules (e.g., scoring rubrics in evaluations, equal opportunity statements in JDs)

The skill auto-detects language from the conversation and input documents, producing output in the detected language. Supported languages: English (`en`) and Italian (`it`). The user may override with an explicit language choice.

**Connector support:** Skills degrade gracefully without connectors. See `CONNECTORS.md` for the full registry.

- If **~~knowledge base** is connected: pull organization-specific compliance policies, past audit results, and jurisdiction-specific rule extensions
- If **~~document converter** is connected: convert a DOCX or PDF document to Markdown before the audit (standalone mode)

If no connector is available, the skill proceeds with its built-in reference files and states what additional context a knowledge base connection would provide.

---

## 2. Pipeline

### Step 1 — Input Analysis

Analyze the input to determine operating parameters:

- **Mode detection**: if the skill was loaded with arguments that start with `embedded` (the call in Section 5), operate in **embedded** mode and take the document type and jurisdiction from the arguments. In every other case, including a direct user request, operate in **standalone** mode
- **Document type identification** (standalone mode): classify the input as one of:
  - Job description (JD)
  - Screening questionnaire
  - Interview questions / script
  - Position assessment (pre-interview briefing on a candidate)
  - Evaluation form
  - Other HR document (apply general rules)
- **Jurisdiction detection**: infer jurisdiction from language, legal references, and content cues:
  - Italian-language content or references to Italian law → Italy jurisdiction (applies Italian + EU + general rules)
  - EU context without Italian specifics → EU jurisdiction (applies EU + general rules)
  - No jurisdiction cues → General best practices (flag that jurisdiction-specific analysis is limited)
- **Language detection**: Use the dominant language of the input documents and conversation for output. When the inputs clearly mix languages, recommend the dominant language and ask the user to confirm; when no language dominates, ask the user to choose. In embedded mode, do not ask: use the dominant language, or English when none dominates.

If **~~knowledge base** is connected: search for organization-specific compliance policies and previous audit results for similar document types.

If the document is a DOCX or PDF file: convert it with **~~document converter** when connected; otherwise ask the user to paste the text or provide a Markdown or text version.

### Step 2 — Layer 1: Prohibited Topics Detection

`Read references/prohibited-topics.md` and `references/legal-map.md`

`references/legal-map.md` is the one map from protected ground to statute. Take every citation for a ground from it, rather than from memory or from the other reference files.

Scan the document for:

1. **Direct prohibited questions** — exact matches or close synonyms of questions listed in the prohibited topics reference (e.g., "Are you pregnant?", "Sei sposata?")
2. **Indirect/proxy questions** — questions that elicit protected information through proxies (e.g., "What year did you graduate?" as an age proxy, "Where are you originally from?" as an ethnicity proxy)
3. **Mandatory disclosure of special category data** — fields or requirements that force candidates to reveal protected characteristics
4. **Unnecessary personal data collection** — data points that fail the relevance test of Art. 8 L. 300/1970
5. **Proxies used as criteria** — a CV gap, a career break or a volunteered protected reason treated as a risk, a red flag or a reason to screen out; any question about the reason for a gap beyond one optional, open question
6. **Pay history** (EU jurisdictions) — any question about current or past pay (`references/legal-map.md` Section 3)

For each finding, record: location in document, the specific text, the prohibited category, the applicable law (from `references/legal-map.md`), and severity (CRITICAL for direct violations and pay-history questions in EU jurisdictions, WARNING for proxy/indirect issues).

### Step 3 — Layer 2: Biased Language Detection

Use built-in bias detection rules from `references/prohibited-topics.md` (gendered/ageist/ableist sections and validation rules).

Also load the **job-description** skill's inclusive language guide (the `inclusive-language-guide.md` file in `../job-description/references/`) for broader replacement suggestions. If the file is not present, proceed with the built-in rules only.

Scan for:

1. **Gendered language** — masculine-defaulting pronouns, gendered job titles without inclusive alternatives (e.g., "he will manage", "cameriere" or "sviluppatore" without the feminine form)
2. **Ageist language** — terms that imply age preference (e.g., "young and dynamic", "digital native", "junior with 10+ years experience", "militesente")
3. **Ableist language** — terms that unnecessarily exclude (e.g., "must be physically fit" without occupational justification, "stand for 8 hours" when not essential, "automunito" for a role that involves no driving)
4. **Exclusionary requirements** — "native speaker" or "madrelingua" instead of "fluent/proficient", "bella presenza", "residente in zona", unnecessary nationality references, cultural fit language that masks homogeneity preference

Severity:
- **CRITICAL** — a masculine-only or feminine-only job title in an Italian-jurisdiction ad, or wording that states a sex, an age range or a nationality as a requirement (`references/legal-map.md` Sections 1 and 3)
- **WARNING** — proxies and requirements whose legitimacy depends on context (e.g., "madrelingua", "bella presenza", "automunito"); the Italian lexicon rows in the inclusive language guide carry their severity
- **INFO** — wording improvements that reveal no protected ground

For each finding, record: location, the specific text, the bias category, severity, the ground's statute from `references/legal-map.md` (or the named best practice), and a concrete replacement suggestion.

### Step 4 — Layer 3: GDPR Data Handling

`Read references/gdpr-guidelines.md`

Check the document against GDPR recruitment rules:

1. **Data minimization** — does the document collect only data necessary for the recruitment purpose?
2. **Transparency** — does the document reference or include a privacy notice? Is the candidate informed about data processing?
3. **Special category data** — does any field or question risk collecting Art. 9 data?
4. **Retention** — if retention is mentioned, is a specific period defined?
5. **Automated decision-making** — if scoring, ranking or a pass/fail threshold is implied, is human oversight mentioned? If AI-assisted tools are used, are they disclosed?
6. **Consent** — if talent pool or future consideration is mentioned, is separate consent obtained?

For each finding, record: location, the specific issue, the GDPR article violated, severity, and suggested fix.

### Step 5 — Layer 4: Structural Compliance

Apply document-type-specific structural rules. Load `references/italian-labor-law.md` for jurisdiction-specific structural requirements.

**Job Descriptions:**
- Gender-neutral language and job title throughout (D.Lgs. 198/2006 Art. 27(2)(b); Directive 2023/970 Art. 5(3))
- Pay range stated, or the JD says how it will be given before the interview — EU jurisdictions only; missing is a WARNING (Directive 2023/970 Art. 5(1))
- Equal opportunity statement present
- Reasonable accommodation statement present
- Requirements justified by genuine occupational need
- No age ranges or experience-as-age-proxy

**Screening Questionnaires** (candidate-facing forms and live scripts):
- Privacy notice included or referenced — a candidate-facing form that collects answers without one is CRITICAL; a live script needs a spoken privacy line
- Only permitted fields collected (name, contact, qualifications, experience, right-to-work, availability, salary expectations)
- No pay-history question (EU: CRITICAL) and no question about the reason for a CV gap beyond one optional, open question (WARNING)
- Talent pool opt-in with separate consent text (if applicable)
- No prohibited fields (photo, date of birth, nationality, marital status)
- Any pass/fail threshold states that a person reviews every decision

**Interview Questions:**
- All questions tied to job competencies
- Scoring rubric referenced or included
- No questions from the prohibited topics list
- Structured format (not free-form only)

**Position Assessments:**
- Every strength, gap and risk tied to job-relevant evidence from the CV
- No CV gap, career break or protected characteristic listed as a risk
- No hire or no-hire recommendation

**Evaluation Forms:**
- Pre-defined, job-relevant evaluation criteria
- Structured rating scale with justification fields
- No fields for appearance, body language, culture fit, personal observations, or special category notes
- Consistent application design (same form for all candidates)

**Other HR documents:** apply Layers 1–3 and the general rules only.

For each finding, record: location, the structural gap, applicable rule/law, severity, and suggested fix.

### Step 6 — Report Generation

**Embedded mode:** Return a structured findings list. Each finding is an object with fields:

- `location` — where in the document the issue occurs (section, line, field name)
- `issue` — description of the compliance problem
- `law` — the statute article, GDPR article, or named best practice the finding rests on (required; see Self-Check Rules)
- `severity` — `CRITICAL`, `WARNING`, or `INFO`
- `suggested_fix` — actionable correction

No file is produced. The calling skill receives the list and decides how to act on it.

**Standalone mode:** Produce a compliance audit report saved as `{document-name}-compliance-audit.md` in the output directory using the output template (see Section 4).

Present a summary to the user: total issues by severity, overall status, and recommended next steps. End with the reminder that the findings are not legal advice.

### Step 7 — Clean Version (standalone only, if requested)

If the user requests a corrected version, produce a clean copy of the original document with all fixes applied:

- CRITICAL issues: fully corrected
- WARNING issues: corrected with best-practice language
- INFO issues: improved where straightforward

Save as `{document-name}-clean.md` in the output directory. Highlight changes with inline comments so the user can review what was modified and why.

---

## 3. Progressive Disclosure

| Step | Documents to Read |
|------|-------------------|
| Step 1 | If **~~document converter** is connected and the document is DOCX or PDF: convert it to Markdown |
| Step 2 | `references/prohibited-topics.md`, `references/legal-map.md` |
| Step 3 | Built-in bias rules from `references/prohibited-topics.md` (already loaded); optionally the **job-description** skill's inclusive language guide (if available at runtime) |
| Step 4 | `references/gdpr-guidelines.md` |
| Step 5 | `references/italian-labor-law.md` |
| Step 6-7 | (no additional references — in-skill report generation) |

---

## 4. Output Templates

### Standalone Audit Report

```markdown
[Only when the document is about a named candidate:]
> Confidential — candidate personal data for the [Role Title] selection. Hiring team only. Delete by [YYYY-MM-DD] (retention policy).

# Compliance Audit — [Document Name]
Date: [date] | Jurisdiction: [Italy / EU / General]

> Not legal advice. These findings come from automated analysis; verify them with counsel before relying on them.

## Summary
- Issues found: [count by severity]
- Overall status: [Pass / Pass with warnings / Fail]

## Issues

### CRITICAL — Must fix
| # | Location | Issue | Law/Principle | Suggested Fix |
|---|----------|-------|---------------|---------------|

### WARNING — Should fix
| # | Location | Issue | Law/Principle | Suggested Fix |
|---|----------|-------|---------------|---------------|

### INFO — Consider
| # | Location | Issue | Rationale | Suggestion |
|---|----------|-------|-----------|------------|

## Clean Version
(Full document with all fixes applied, if requested)

## Legal References
(List of all laws, directives, and GDPR articles cited in the findings)
```

### Overall Status Logic

| Condition | Status |
|-----------|--------|
| Zero CRITICAL and zero WARNING | **Pass** |
| Zero CRITICAL and one or more WARNING | **Pass with warnings** |
| One or more CRITICAL | **Fail** |

---

## 5. Embedded Mode Interface

### Contract

A calling skill runs compliance-check as its last step, after every other change to its draft (rewrites, redundancy checks, corporate template adaptation), so that the checked text is the text it writes. It loads this skill with the Skill tool and these arguments:

```
embedded <document_type>[,<document_type>...] [<jurisdiction>]
```

- **Text** — the draft the calling skill has in the conversation at that moment. When there are several documents, the caller names each one before the call.
- `document_type` — one or more of: `jd`, `questionnaire`, `interview_questions`, `position_assessment`, `evaluation_form`, `other` (general rules only). With several types, prefix each finding's `location` with the document it belongs to.
- `jurisdiction` — (optional) one of: `italy`, `eu`, `general`. If omitted, auto-detected from content.

If the Skill tool cannot load compliance-check, the caller reads `../compliance-check/SKILL.md` (relative to its own skill directory) and applies the embedded mode itself.

### Response Format

The skill returns a list of finding objects:

```json
[
  {
    "location": "Section 3, paragraph 2",
    "issue": "Question 'Are you married?' directly asks about marital status",
    "law": "D.Lgs. 198/2006 Art. 27(2)(a); L. 300/1970 Art. 8",
    "severity": "CRITICAL",
    "suggested_fix": "Remove the question entirely — marital status is not relevant to professional aptitude"
  },
  {
    "location": "Requirements section",
    "issue": "'Madrelingua italiana' is a proxy for ethnic or national origin",
    "law": "D.Lgs. 215/2003 Art. 2(1)(b); D.Lgs. 286/1998 Art. 43",
    "severity": "WARNING",
    "suggested_fix": "Replace with 'Italiano fluente (livello C1/C2)'"
  }
]
```

### Severity Definitions

| Severity | Meaning | Action Required |
|----------|---------|-----------------|
| `CRITICAL` | Direct breach of statute or GDPR — including a gendered job title in an Italian ad, a candidate-facing form that collects data without a privacy notice, and a pay-history question in an EU jurisdiction | Must be fixed before the document can be used |
| `WARNING` | A proxy, indirect discrimination, a missing safeguard, or a case that depends on context — including a missing pay range in an EU JD | Should be fixed; the calling skill decides whether to block or warn |
| `INFO` | Wording improvement or minor enhancement | Recommended but not blocking |

These three levels are the only ones. The severity tables in the reference files give examples for each layer and use the same three levels.

---

## 6. Self-Check Rules

Before returning any findings, the skill validates its own output:

1. **Every flag must cite a specific law or principle** — no finding is emitted without a legal reference (statute article, GDPR article, or named best practice). Statutes for a protected ground come from `references/legal-map.md`. Findings without citations are discarded.
2. **Suggestions must be actionable** — every `suggested_fix` must provide concrete replacement text or a specific action (e.g., "Remove this field", "Replace X with Y"). Vague advice like "consider revising" is not acceptable.
3. **Context-dependent items are WARNING, not CRITICAL** — if an issue depends on context that the skill cannot fully determine (e.g., whether a physical requirement is a genuine occupational need), classify it as WARNING with an explanation of what context would resolve it.
4. **No false positives on legitimate occupational requirements** — before flagging a requirement as discriminatory, check whether the document provides an occupational justification. If justified, downgrade to INFO with a note to verify the justification.
5. **Jurisdiction consistency** — do not cite Italian law for documents operating under a non-Italian jurisdiction. Apply only the relevant legal framework.

---

## 7. Language Detection

Use the dominant language of the input documents and conversation for output. When the inputs clearly mix languages, recommend the dominant language and ask the user to confirm; when no language dominates, ask the user to choose. In embedded mode, do not ask: use the dominant language, or English when none dominates.

Supported languages:
- `en` — English
- `it` — Italian

For unsupported languages: produce the audit report structure in English, note the limitation to the user, and flag that jurisdiction-specific analysis may be incomplete.
