---
name: compliance-check
description: "Review any HR document (job descriptions, screening questionnaires, interview questions, evaluation forms) for legal compliance, bias, and discriminatory language. Operates in two modes: embedded (invoked as validation step by other HR skills, returns structured findings) or standalone (audits any existing document, produces a compliance audit report). Jurisdiction-aware for Italy (D.Lgs. 198/2006, 215/2003, 276/2003), EU/GDPR, and general best practices. Detects prohibited topics, biased language (gendered, ageist, ableist), GDPR data handling issues, and structural compliance gaps. Use when the user says 'check compliance', 'review for bias', 'legal check', 'controlla conformita', 'verifica discriminazioni', 'check this JD', or 'audit this evaluation'."
---

# Compliance Check — HR Document Compliance Validator

## 1. Overview

This skill reviews HR documents for legal compliance, bias, and discriminatory language. It validates job descriptions, screening questionnaires, interview questions, and evaluation forms against Italian labor law, EU/GDPR requirements, and inclusive language best practices.

It operates in two modes:

- **Embedded mode** — invoked as a validation step by other HR skills (job-description, pre-screening, interview-prep, interview-close). Receives draft text, returns a structured list of findings. No file output.
- **Standalone mode** — audits any existing HR document provided by the user. Produces a full compliance audit report saved to the outbox directory.

The skill applies four analysis layers in sequence:

1. **Prohibited Topics Detection** — flags direct and indirect references to legally protected categories
2. **Biased Language Detection** — identifies gendered, ageist, ableist, or exclusionary phrasing
3. **GDPR Data Handling** — checks data minimization, transparency, retention, and special category data risks
4. **Structural Compliance** — validates document-type-specific rules (e.g., scoring rubrics in evaluations, equal opportunity statements in JDs)

The skill auto-detects language from the conversation and input documents, producing output in the detected language. Supported languages: English (`en`) and Italian (`it`). The user may override with an explicit language choice.

**Connector support:** Skills degrade gracefully without connectors. See `CONNECTORS.md` for the full registry.

- If **~~knowledge base** is connected: pull organization-specific compliance policies, past audit results, and jurisdiction-specific rule extensions

If no connector is available, the skill proceeds with its built-in reference files and states what additional context a knowledge base connection would provide.

---

## 2. Pipeline

### Step 1 — Input Analysis

Analyze the input to determine operating parameters:

- **Mode detection**: if invoked by another skill via structured call, operate in **embedded** mode; if the user directly requests compliance review, operate in **standalone** mode
- **Document type identification**: classify the input as one of:
  - Job description (JD)
  - Screening questionnaire
  - Interview questions / script
  - Evaluation form
  - Other HR document (apply general rules)
- **Jurisdiction detection**: infer jurisdiction from language, legal references, and content cues:
  - Italian-language content or references to Italian law → Italy jurisdiction (applies Italian + EU + general rules)
  - EU context without Italian specifics → EU jurisdiction (applies EU + general rules)
  - No jurisdiction cues → General best practices (flag that jurisdiction-specific analysis is limited)
- **Language detection**: count language-specific tokens across input. Classification:
  - **>80% single language** → auto-select that language for output
  - **60-80% dominant language** → recommend dominant, ask user to confirm (standalone only; embedded uses dominant)
  - **<60% any language** → ask user to choose (standalone only; embedded defaults to English)

If **~~knowledge base** is connected: search for organization-specific compliance policies and previous audit results for similar document types.

### Step 2 — Layer 1: Prohibited Topics Detection

`Read references/prohibited-topics.md`

Scan the document for:

1. **Direct prohibited questions** — exact matches or close synonyms of questions listed in the prohibited topics reference (e.g., "Are you pregnant?", "Sei sposata?")
2. **Indirect/proxy questions** — questions that elicit protected information through proxies (e.g., "What year did you graduate?" as an age proxy, "Where are you originally from?" as an ethnicity proxy)
3. **Mandatory disclosure of special category data** — fields or requirements that force candidates to reveal protected characteristics
4. **Unnecessary personal data collection** — data points that fail the relevance test of Art. 8 L. 300/1970

For each finding, record: location in document, the specific text, the prohibited category, the applicable law, and severity (CRITICAL for direct violations, WARNING for proxy/indirect issues).

### Step 3 — Layer 2: Biased Language Detection

Use built-in bias detection rules from `references/prohibited-topics.md` (gendered/ageist/ableist sections and validation rules).

When the sibling skill **job-description** provides an inclusive language guide (`../job-description/` → `inclusive-language-guide.md`), load it at runtime for enhanced language analysis with broader replacement suggestions. This is a forward reference resolved at runtime — if the file does not exist, proceed with built-in rules only.

Scan for:

1. **Gendered language** — masculine-defaulting pronouns, gendered job titles without inclusive alternatives (e.g., "he will manage", "cameriere" without "cameriera/e")
2. **Ageist language** — terms that imply age preference (e.g., "young and dynamic", "digital native", "junior with 10+ years experience")
3. **Ableist language** — terms that unnecessarily exclude (e.g., "must be physically fit" without occupational justification, "stand for 8 hours" when not essential)
4. **Exclusionary requirements** — "native speaker" instead of "fluent/proficient", unnecessary nationality references, cultural fit language that masks homogeneity preference

For each finding, record: location, the specific text, the bias category, severity (WARNING for clearly biased language, INFO for improvement suggestions), and a concrete replacement suggestion.

### Step 4 — Layer 3: GDPR Data Handling

`Read references/gdpr-guidelines.md`

Check the document against GDPR recruitment rules:

1. **Data minimization** — does the document collect only data necessary for the recruitment purpose?
2. **Transparency** — does the document reference or include a privacy notice? Is the candidate informed about data processing?
3. **Special category data** — does any field or question risk collecting Art. 9 data?
4. **Retention** — if retention is mentioned, is a specific period defined?
5. **Automated decision-making** — if scoring or ranking is implied, is human oversight mentioned?
6. **Consent** — if talent pool or future consideration is mentioned, is separate consent obtained?

For each finding, record: location, the specific issue, the GDPR article violated, severity, and suggested fix.

### Step 5 — Layer 4: Structural Compliance

Apply document-type-specific structural rules. Load `references/italian-labor-law.md` for jurisdiction-specific structural requirements.

**Job Descriptions:**
- Gender-neutral language throughout (D.Lgs. 198/2006 Art. 27(2))
- Equal opportunity statement present
- Reasonable accommodation statement present
- Requirements justified by genuine occupational need
- No age ranges or experience-as-age-proxy

**Screening Questionnaires:**
- Privacy notice reference included
- Only permitted fields collected (name, contact, qualifications, experience, right-to-work)
- Talent pool opt-in with separate consent text (if applicable)
- No prohibited fields (photo, date of birth, nationality, marital status)

**Interview Questions:**
- All questions tied to job competencies
- Scoring rubric referenced or included
- No questions from the prohibited topics list
- Structured format (not free-form only)

**Evaluation Forms:**
- Pre-defined, job-relevant evaluation criteria
- Structured rating scale with justification fields
- No fields for appearance, personal observations, or special category notes
- Consistent application design (same form for all candidates)

For each finding, record: location, the structural gap, applicable rule/law, severity, and suggested fix.

### Step 6 — Report Generation

**Embedded mode:** Return a structured findings list. Each finding is an object with fields:

- `location` — where in the document the issue occurs (section, line, field name)
- `issue` — description of the compliance problem
- `severity` — `CRITICAL`, `WARNING`, or `INFO`
- `suggested_fix` — actionable correction

No file is produced. The calling skill receives the list and decides how to act on it.

**Standalone mode:** Produce a compliance audit report saved to `docs/outbox/{document-name}-compliance-audit.md` using the output template (see Section 4).

Present a summary to the user: total issues by severity, overall status, and recommended next steps.

### Step 7 — Clean Version (standalone only, if requested)

If the user requests a corrected version, produce a clean copy of the original document with all fixes applied:

- CRITICAL issues: fully corrected
- WARNING issues: corrected with best-practice language
- INFO issues: improved where straightforward

Save to `docs/outbox/{document-name}-clean.md`. Highlight changes with inline comments so the user can review what was modified and why.

---

## 3. Progressive Disclosure

| Step | Documents to Read |
|------|-------------------|
| Step 1 | (no references — in-skill analysis of input and mode detection) |
| Step 2 | `references/prohibited-topics.md` |
| Step 3 | Built-in bias rules from `references/prohibited-topics.md` (already loaded); optionally the **job-description** skill's inclusive language guide (if available at runtime) |
| Step 4 | `references/gdpr-guidelines.md` |
| Step 5 | `references/italian-labor-law.md` |
| Step 6-7 | (no additional references — in-skill report generation) |

---

## 4. Output Templates

### Standalone Audit Report

```markdown
# Compliance Audit — [Document Name]
Date: [date] | Jurisdiction: [Italy / EU / General]

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

Calling skills invoke compliance-check by passing:

- `text` — the draft document content to validate
- `document_type` — one of: `jd`, `questionnaire`, `interview_questions`, `evaluation_form`
- `jurisdiction` — (optional) one of: `italy`, `eu`, `general`. If omitted, auto-detected from content.

### Response Format

The skill returns a list of finding objects:

```json
[
  {
    "location": "Section 3, paragraph 2",
    "issue": "Question 'Are you married?' directly asks about marital status",
    "severity": "CRITICAL",
    "suggested_fix": "Remove the question entirely — marital status is not relevant to professional aptitude"
  },
  {
    "location": "Requirements section",
    "issue": "'Native Italian speaker' is a proxy for national origin discrimination",
    "severity": "WARNING",
    "suggested_fix": "Replace with 'Fluent in Italian (C1/C2 level)'"
  }
]
```

### Severity Definitions

| Severity | Meaning | Action Required |
|----------|---------|-----------------|
| `CRITICAL` | Direct violation of anti-discrimination law or GDPR | Must be fixed before the document can be used |
| `WARNING` | Indirect discrimination risk, proxy question, or best practice violation | Should be fixed; the calling skill decides whether to block or warn |
| `INFO` | Language improvement or minor enhancement | Recommended but not blocking |

---

## 6. Self-Check Rules

Before returning any findings, the skill validates its own output:

1. **Every flag must cite a specific law or principle** — no finding is emitted without a legal reference (statute article, GDPR article, or named best practice). Findings without citations are discarded.
2. **Suggestions must be actionable** — every `suggested_fix` must provide concrete replacement text or a specific action (e.g., "Remove this field", "Replace X with Y"). Vague advice like "consider revising" is not acceptable.
3. **Context-dependent items are WARNING, not CRITICAL** — if an issue depends on context that the skill cannot fully determine (e.g., whether a physical requirement is a genuine occupational need), classify it as WARNING with an explanation of what context would resolve it.
4. **No false positives on legitimate occupational requirements** — before flagging a requirement as discriminatory, check whether the document provides an occupational justification. If justified, downgrade to INFO with a note to verify the justification.
5. **Jurisdiction consistency** — do not cite Italian law for documents operating under a non-Italian jurisdiction. Apply only the relevant legal framework.

---

## 7. Language Detection

Count language-specific tokens across input documents and conversation context. Classification:

- **>80% single language** → auto-select that language for output
- **60-80% dominant language** → recommend dominant, ask user to confirm (standalone mode); use dominant silently (embedded mode)
- **<60% any language** → ask user to choose (standalone mode); default to English (embedded mode)

Supported languages:
- `en` — English
- `it` — Italian

For unsupported languages: produce the audit report structure in English, note the limitation to the user, and flag that jurisdiction-specific analysis may be incomplete.
