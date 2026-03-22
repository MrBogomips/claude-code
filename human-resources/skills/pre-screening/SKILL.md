---
name: pre-screening
description: "Generate pre-filter questionnaires for HR recruiters to send to candidates or use as scripts during phone/video screening calls. Performs CV-vs-JD gap analysis to identify areas needing clarification. Supports two delivery modes: async (candidate self-service) and live (interviewer script with follow-up probes and note-taking). Covers 5 categories: logistics, experience alignment, motivation, competency probes, and candidate questions. Max 12 questions per questionnaire. Invokes compliance-check validation before output. Use when the user says 'screening questions for', 'pre-filter questions', 'candidate screening', 'phone screen script', 'domande di prescreening', 'domande filtro', or 'prepara screening'."
---

# Pre-Screening — Candidate Screening Questionnaire Generator

## 1. Overview

This skill generates pre-screening questionnaires from a Job Description and a candidate's CV. It performs a CV-vs-JD gap analysis to identify areas needing clarification, then produces a structured questionnaire covering five categories with a maximum of 12 questions.

It operates in two delivery modes:

- **Async mode** — a formal, self-explanatory questionnaire sent to the candidate for self-paced completion (email, ATS form, or document)
- **Live mode** — a conversational interviewer script for phone or video screening calls, with follow-up probes, timing cues, note-taking space, and green/red flag indicators

The skill auto-detects language from the conversation and input documents, producing output in the detected language. Supported languages: English (`en`) and Italian (`it`). The user may override with an explicit language choice.

**Output file:** `{candidate}-prescreening.md` in `docs/outbox/`

**Connector support:** Skills degrade gracefully without connectors.

- If **~~ATS** is connected: pull candidate CV, application data, and job requisition details automatically
- If **~~knowledge base** is connected: pull organization-specific screening templates, salary bands, and hiring policies

If no connectors are available, the skill asks the user to provide JD and CV content manually and proceeds with its built-in reference files.

---

## 2. Pipeline

### Step 1 — Input Collection

Collect the two required inputs:

1. **Job Description** — accept as file path, pasted text, or URL. If the JD was produced by the sibling `job-description` skill, it can be referenced directly.
2. **Candidate CV / application** — accept as file path, pasted text, or email content.

If **~~ATS** is connected: search for the candidate profile and job requisition by name or ID. Pull structured data (contact info, application date, CV text, job requisition).

If **~~knowledge base** is connected: search for organization-specific screening templates, salary band data, and hiring policies for the role's department or level.

**Corporate context with memory:** Check conversation memory for previously stored corporate context (company name, standard screening policies, salary bands, hiring process stages). If found, apply silently. If new corporate context is provided, save it to memory for future sessions.

**Output format preference:** Check memory for previously stored output format preference (async vs. live default, specific formatting choices). If found, apply as default without re-asking.

**Language detection:** Count language-specific tokens across all input documents:
- **>80% single language** — auto-select that language for output
- **60-80% dominant language** — recommend dominant, ask user to confirm
- **<60% any language** — ask user to choose

### Step 2 — CV-JD Gap Analysis

Perform a structured comparison of the candidate's CV against the JD requirements:

1. **Requirements extraction** — parse the JD into a list of requirements: mandatory qualifications, preferred qualifications, technical skills, soft skills, logistics (location, availability, work model)
2. **CV mapping** — for each JD requirement, classify the candidate's evidence as:
   - **Match** — CV clearly demonstrates the requirement with specific evidence
   - **Partial match** — CV suggests relevant experience but lacks specifics or is at a lower level
   - **Gap** — CV does not address this requirement
   - **Unclear** — CV mentions something related but the claim is ambiguous or unverifiable from text alone
3. **Logistics unknowns** — identify logistics factors not determinable from the CV: work authorization, availability/start date, salary expectations, location flexibility
4. **Timeline analysis** — identify CV gaps, short tenures, and career trajectory patterns that warrant clarification

Present the gap analysis summary to the user before proceeding to question generation.

### Step 3 — Delivery Mode Selection

Ask the user: **"Should I generate an async questionnaire (sent to the candidate) or a live screening script (for the interviewer)?"**

If memory contains a default delivery mode preference, present it as the default: "Your default is [mode]. Should I use it, or switch to [other mode]?"

Briefly explain the difference if the user seems unfamiliar:
- Async: formal, self-paced, no follow-up probes, includes instructions header
- Live: conversational, includes follow-up probes, timing cues, note-taking space, green/red flag indicators

### Step 4 — Question Generation

`Read references/screening-categories.md`

Generate a maximum of 12 questions distributed across the five categories:

1. **Logistics / Eligibility** (2-4 questions) — derived from logistics unknowns identified in Step 2
2. **Experience Alignment** (3-5 questions) — derived from gaps, partial matches, and unclear claims in Step 2
3. **Motivation** (1-2 questions) — max 2, selected based on role seniority and context
4. **Key Competency Probe** (2-3 questions) — derived from the JD's top competency requirements, calibrated to screening depth
5. **Candidate Questions** (1 prompt) — open-ended engagement prompt

**Question design rules** (from reference file):
- Every question traces to a specific JD requirement or CV gap
- One concept per question
- Open-ended for Categories 2-4; binary acceptable for Category 1
- Standardized base set (CV-specific probes documented as variations)
- Difficulty gradient: logistics first, competency probes last

**Mode-specific formatting:**
- **Async**: formal tone, self-explanatory, word-count guidance, hidden rationale (in evaluation guide only)
- **Live**: conversational tone, follow-up probes per question, green/red flag indicators, note-taking space, timing cues

### Step 5 — Compliance Validation

Invoke the **compliance-check** skill in embedded mode, passing:

- `text` — the generated questionnaire content
- `document_type` — `questionnaire`
- `jurisdiction` — auto-detected from input language and content cues

Review the findings:
- **CRITICAL** findings: automatically fix and regenerate the affected questions
- **WARNING** findings: fix where possible, flag remaining items to the user
- **INFO** findings: apply improvements where straightforward

If any questions are modified, note the compliance adjustments in the output.

### Step 6 — Output

Produce the final questionnaire as `docs/outbox/{candidate}-prescreening.md` in the selected delivery mode format (see Section 4 for templates).

Present a summary to the user:
- Delivery mode used
- Number of questions per category
- CV-JD alignment overview (matches / partial / gaps)
- Compliance status (pass / pass with warnings / any adjustments made)
- Suggested next steps: send to candidate (async) or schedule call (live); after screening, use `interview-prep` to design the next stage

---

## 3. Progressive Disclosure

| Step | Documents to Read |
|------|-------------------|
| Step 1-3 | (no references — in-skill input collection, analysis, and mode selection) |
| Step 4 | `references/screening-categories.md` |
| Step 5 | (no references — invokes compliance-check skill in embedded mode) |
| Step 6 | (no additional references — in-skill output generation) |

---

## 4. Output Templates

### Async Mode

```markdown
# Pre-Screening Questionnaire — [Candidate Name] for [Role Title]

**Date:** [date]
**Instructions:** Please answer the following questions. Estimated completion time: 15-20 minutes. Please submit your responses by [deadline]. For questions, contact [recruiter email].

**Privacy notice:** [Reference to organization's recruitment privacy notice]

## CV-JD Alignment Summary

| Area | Status | Notes |
|------|--------|-------|
| [Requirement 1] | Match / Partial / Gap / Unclear | [Brief note] |
| ... | ... | ... |

## Screening Questions

### Logistics & Eligibility
1. [Question] — *Rationale: [why this question is asked — recruiter-only, excluded from candidate version]*

### Experience Alignment
2. [Question] (please answer in 2-4 sentences) — *Rationale: [maps to JD requirement X]*

### Motivation
3. [Question] — *Rationale: [assesses role-specific interest]*

### Key Competency Probe
4. [Question] (please answer in 3-5 sentences) — *Rationale: [maps to JD competency Y]*

### Your Questions
5. Do you have any questions about the role, team, or company?

## Evaluation Guidance (recruiter only — do not send to candidate)

| # | Question | Green | Yellow | Red |
|---|----------|-------|--------|-----|
| 1 | [Question summary] | [What good looks like] | [Borderline signals] | [Disqualifying signals] |
| ... | ... | ... | ... | ... |

**Suggested pass/fail threshold:** Proceed if zero Red and no more than [N] Yellow signals.
```

### Live Mode

```markdown
# Live Screening Script — [Candidate Name] for [Role Title]

**Date:** [date]
**Interviewer:** _______________
**Suggested duration:** 15-20 minutes

## Opening Script
"Hello [Candidate Name], thank you for taking the time to speak with me today. My name is [Interviewer] and I'm [role] at [Company]. The purpose of this call is to learn more about your background and answer any questions you have about the [Role Title] position. This should take about 15-20 minutes. Shall we begin?"

## CV-JD Alignment Summary (interviewer reference)

| Area | Status | Notes |
|------|--------|-------|
| [Requirement 1] | Match / Partial / Gap / Unclear | [Brief note] |
| ... | ... | ... |

## Screening Questions

### Logistics & Eligibility (~3 min)

#### Q1: [Question — conversational phrasing]
*Rationale (interviewer only): [Why this matters — maps to logistics prerequisite]*
*Follow-up probes: [If answer is vague: "Could you clarify...?" / If partial: "Would you be open to...?"]*
*Green flag: [What good sounds like]*
*Red flag: [What to watch for]*
**Notes:** _________________________________

### Experience Alignment (~5 min)

#### Q2: [Question]
*Rationale (interviewer only): [Maps to JD requirement X, CV shows gap/unclear]*
*Follow-up probes: [If vague: "Can you give a specific example?" / If general: "What was your specific role in that?"]*
*Green flag: [Specific examples, clear ownership, measurable outcomes]*
*Red flag: [Cannot provide specifics, contradicts CV, deflects]*
**Notes:** _________________________________

### Motivation (~3 min)

#### Q3: [Question]
*Rationale (interviewer only): [Assesses genuine interest]*
*Follow-up probes: [If generic: "What specifically about [aspect] interests you?"]*
*Green flag: [Role-specific reasons, company research, aligned enthusiasm]*
*Red flag: [Cannot articulate why, confuses company, misaligned expectations]*
**Notes:** _________________________________

### Key Competency Probe (~5 min)

#### Q4: [Question]
*Rationale (interviewer only): [Maps to JD competency Y]*
*Follow-up probes: [If no STAR: "What was the situation?" / "What did you specifically do?" / "What was the result?"]*
*Green flag: [Structured answer, demonstrates competency at JD level, self-aware]*
*Red flag: [No relevant example, fundamental misunderstanding, contradicts CV]*
**Notes:** _________________________________

### Candidate Questions (~3 min)

#### Q5: "Do you have any questions about the role, the team, or the company?"
*Green flag: [Thoughtful questions showing preparation and genuine interest]*
*Red flag: [Questions revealing misalignment with stated role parameters]*
**Notes:** _________________________________

## Closing Script
"Thank you for your time today, [Candidate Name]. Here's what happens next: [describe next steps and timeline]. Do you have any final questions? Thank you and have a great day."

## Interviewer Assessment (complete after call)

| Category | Rating (Green/Yellow/Red) | Key Observations |
|----------|---------------------------|------------------|
| Logistics | ___ | ___ |
| Experience Alignment | ___ | ___ |
| Motivation | ___ | ___ |
| Competency Probe | ___ | ___ |
| Candidate Questions | ___ | ___ |

**Overall recommendation:** Proceed / Hold / Reject
**Rationale:** _______________________________________________
```

---

## 5. Integration

- **Consumes:** Job Description from the `job-description` skill (or provided directly by the user)
- **Invokes:** `compliance-check` in embedded mode (Step 5) to validate questionnaire content
- **Produces output for:** `interview-prep` skill — the pre-screening results and CV-JD gap analysis inform the design of the next interview stage

---

## 6. Language Detection

Count language-specific tokens across all input documents and conversation context. Classification:

- **>80% single language** — auto-select that language for output
- **60-80% dominant language** — recommend dominant, ask user to confirm
- **<60% any language** — ask user to choose

Supported languages:
- `en` — English
- `it` — Italian

For unsupported languages: produce the questionnaire structure in the detected language where possible, use English for internal guidance, and note the limitation to the user.
