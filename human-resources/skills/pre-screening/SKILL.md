---
name: pre-screening
description: "Use when a recruiter needs screening questions or a phone-screen script for one candidate before the interviews — 'screening questions for', 'phone screen script', 'pre-filter questions', 'candidate screening', 'colloquio telefonico', 'primo colloquio', 'call conoscitiva', 'domande di prescreening', 'domande filtro'. Compares the CV with the JD and writes an async questionnaire or a live call script (max 12 questions, a role-level base set reused for every candidate, compliance-checked last). Not for full interview preparation (interview-prep) or post-interview evaluation (interview-close)."
---

# Pre-Screening — Candidate Screening Questionnaire Generator

## 1. Overview

This skill generates pre-screening questionnaires from a Job Description and a candidate's CV. It compares the CV with the JD requirements to find what needs clarification, then produces a structured questionnaire covering five categories with a maximum of 12 questions. Four of the five categories are a **role-level base set**, the same for every candidate; only Category 2 (experience alignment) is written from each CV.

It operates in two delivery modes:

- **Async mode** — a formal, self-explanatory questionnaire sent to the candidate for self-paced completion (email, ATS form, or document), with the recruiter's evaluation guide in a separate file
- **Live mode** — a conversational interviewer script for phone or video screening calls, with follow-up probes, timing cues, note-taking space, and green/red flag indicators

The skill auto-detects language from the conversation and input documents, producing output in the detected language. Supported languages: English (`en`) and Italian (`it`). The user may override with an explicit language choice.

**Output files** (in the output directory — the output folder the project's CLAUDE.md declares; if none is declared, ask the user):

- `{role}-prescreening-base.md` — the role-level base set (Categories 1, 3, 4, 5), written on the first run for the role and reused after that; it holds no candidate data
- Async mode: `{candidate}-prescreening.md` (sent to the candidate) and `{candidate}-prescreening-guide.md` (recruiter only)
- Live mode: `{candidate}-prescreening-script.md` (interviewer only)

**Candidate data.** These files hold candidate personal data. Suggest an output folder outside version control; if the chosen folder is inside a git repository, say so and ask the user to confirm. Start every internal candidate file (the guide and the live script) with the confidentiality line shown in the output templates, with the delete-by date taken from the organization's retention period (ask once if it is unknown); the file sent to the candidate carries the privacy notice instead. Never save candidate data — names, CV content, answers, notes, ratings — to memory; only corporate context may be saved there.

**Connector support:** Skills degrade gracefully without connectors.

- If **~~ATS** is connected: pull candidate CV, application data, and job requisition details automatically
- If **~~knowledge base** is connected: pull organization-specific screening templates, salary bands, and hiring policies
- If **~~document converter** is connected: convert a DOCX or PDF CV or JD to Markdown before the analysis

If no connectors are available, the skill asks the user to provide JD and CV content manually and proceeds with its built-in reference files.

---

## 2. Pipeline

### Step 1 — Input Collection

Collect the required inputs:

1. **Job Description** — accept as file path, pasted text, or URL. If the JD was produced by the sibling `job-description` skill, it can be referenced directly.
2. **Candidate CV / application** — accept as file path, pasted text, or email content.

If a CV or JD is a DOCX or PDF file: convert it with **~~document converter** when connected; otherwise ask the user to paste the text.

Also collect, when available (from the user or **~~knowledge base**):

3. **Salary band maximum** and the pay range to state to candidates
4. **Hiring timeline** — the target start date and the latest start date the hiring manager can accept

Without them, the related Category 1 signals are marked "not assessed" rather than guessed.

If **~~ATS** is connected: search for the candidate profile and job requisition by name or ID. Pull structured data (contact info, application date, CV text, job requisition).

If **~~knowledge base** is connected: search for organization-specific screening templates, salary band data, and hiring policies for the role's department or level.

**Corporate context with memory:** Check conversation memory for previously stored corporate context (company name, standard screening policies, salary bands, hiring process stages). If found, apply silently. If new corporate context is provided, save it to memory for future sessions — corporate context only, never candidate data.

**Output format preference:** Check memory for previously stored output format preference (async vs. live default, specific formatting choices). If found, apply as default without re-asking.

**Language detection:** Use the dominant language of the input documents and conversation for output. When the inputs clearly mix languages, recommend the dominant language and ask the user to confirm; when no language dominates, ask the user to choose.

### Step 2 — CV-JD Alignment Analysis

Perform a structured comparison of the candidate's CV against the JD requirements:

1. **Requirements extraction** — parse the JD into a list of requirements: mandatory qualifications, preferred qualifications, technical skills, soft skills, logistics (location, availability, work model)
2. **CV mapping** — for each JD requirement, classify the candidate's evidence as:
   - **Match** — CV clearly demonstrates the requirement with specific evidence
   - **Partial match** — CV suggests relevant experience but lacks specifics or is at a lower level
   - **Gap** — CV does not address this requirement
   - **Unclear** — CV mentions something related but the claim is ambiguous from text alone
3. **Logistics unknowns** — note the logistics factors the CV does not settle; the role-level Category 1 questions cover them

A "gap" here is always a JD requirement the CV does not show — never a period without work. Dates and CV gaps are not analyzed, rated or turned into questions: a gap stands in for pregnancy, illness, disability or caregiving, which the plugin may not use (compliance-check's `prohibited-topics.md`, "Career Gaps and Breaks").

Present the alignment summary to the user before proceeding to question generation.

### Step 3 — Delivery Mode Selection

Ask the user: **"Should I generate an async questionnaire (sent to the candidate) or a live screening script (for the interviewer)?"**

If memory contains a default delivery mode preference, present it as the default: "Your default is [mode]. Should I use it, or switch to [other mode]?"

Briefly explain the difference if the user seems unfamiliar:
- Async: formal, self-paced, no follow-up probes, includes instructions header; the recruiter's guide is a separate file
- Live: conversational, includes follow-up probes, timing cues, note-taking space, green/red flag indicators

### Step 4 — Question Generation

`Read references/screening-categories.md`

**Base set first.** Look for `{role}-prescreening-base.md` in the output folder (`{role}` is the sanitized role title, lowercase, hyphens for spaces).

- **Found:** reuse its Categories 1, 3, 4 and 5 unchanged, so every candidate for the role gets the same questions. If the user wants to change them, update the base file only after they confirm that the change applies to all later candidates, and add "Revised on [date]: [what changed]" at its top.
- **Not found:** generate Categories 1, 3, 4 and 5 from the JD, show them to the user, and save the confirmed set as `{role}-prescreening-base.md`, with the question text, the rationale, the Green/Yellow/Red guidance and the live-mode probes.

Then generate Category 2 from this CV, so the total stays at 12 questions or fewer:

1. **Logistics / Eligibility** (2-4 questions, base set) — right to work, work model, earliest start date, salary expectations after stating the pay range
2. **Experience Alignment** (3-5 questions, per candidate) — derived from the JD requirements the CV shows as partial, missing or unclear in Step 2, plus at most one optional, open career-path question with the same wording for every candidate
3. **Motivation** (1-2 questions, base set) — max 2, selected based on role seniority and context
4. **Key Competency Probe** (2-3 questions, base set) — derived from the JD's top competency requirements, calibrated to screening depth
5. **Candidate Questions** (1 prompt, base set) — open-ended engagement prompt

**Question design rules** (from reference file):
- Every question traces to a specific JD requirement
- One concept per question
- Open-ended for Categories 2-4; binary acceptable for Category 1
- Never ask about current or past pay, or about a specific CV gap or its reason
- Difficulty gradient: logistics first, competency probes last

**Mode-specific formatting:**
- **Async**: formal tone, self-explanatory, word-count guidance; rationale and signals only in the separate guide file
- **Live**: conversational tone, privacy line in the opening script, follow-up probes per question, green/red flag indicators, note-taking space, timing cues

### Step 5 — Compliance Validation (last check before output)

Run compliance-check on the final text of every file, including the base set when it is new or changed. Load compliance-check with the Skill tool and the arguments `embedded questionnaire,evaluation_form` (the questionnaire or live script is `questionnaire`; the recruiter guide is `evaluation_form`; the call is defined in compliance-check's Section 5; the jurisdiction is auto-detected). If the Skill tool cannot load it, read `../compliance-check/SKILL.md` and apply its embedded mode.

Review the findings:
- **CRITICAL** findings: automatically fix and regenerate the affected questions
- **WARNING** findings: fix where possible, flag remaining items to the user
- **INFO** findings: apply improvements where straightforward

If any questions are modified, note the compliance adjustments in the output. A fix to a base-set question is saved to `{role}-prescreening-base.md` too.

### Step 6 — Output

Write the files for the selected delivery mode (see Section 4 for templates):

- Async: `{candidate}-prescreening.md` (to send) and `{candidate}-prescreening-guide.md` (recruiter only)
- Live: `{candidate}-prescreening-script.md`
- `{role}-prescreening-base.md`, when it was created or revised in this run

Present a summary to the user:
- Delivery mode used, and whether the base set was reused, created or revised
- Number of questions per category
- CV-JD alignment overview (matches / partial / gaps)
- Compliance status (pass / pass with warnings / any adjustments made)
- Reminder: the signals and the threshold are suggestions; a person reviews every Hold or Reject
- Suggested next steps: send the questionnaire to the candidate (async) or schedule the call (live); after screening, use `interview-prep` to design the next stage

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

### Async Mode — Questionnaire (sent to the candidate)

```markdown
# Pre-Screening Questionnaire — [Candidate Name] for [Role Title]

**Date:** [date]
**Instructions:** Please answer the following questions. Estimated completion time: 15-20 minutes. Please submit your responses by [deadline]. For questions, contact [recruiter email].

**Privacy notice:** We use your answers only to assess your application for this role. [Link to, or attached copy of, the organization's recruitment privacy notice], which explains how we handle your data and how long we keep it.

**Pay range for this role:** [gross annual range, as stated in the job description]

## Screening Questions

### Logistics & Eligibility
1. [Question]

### Experience Alignment
2. [Question] (please answer in 2-4 sentences)
3. *(Optional)* Is there anything about your career path that your CV does not show and that you would like us to know?

### Motivation
4. [Question]

### Key Competency Probe
5. [Question] (please answer in 3-5 sentences)

### Your Questions
6. Do you have any questions about the role, team, or company?
```

### Async Mode — Evaluation Guide (recruiter only, separate file)

```markdown
> Confidential — candidate personal data for the [Role Title] selection. Hiring team only. Delete by [YYYY-MM-DD] (retention policy).

# Pre-Screening Evaluation Guide — [Candidate Name] for [Role Title]

Questionnaire: `{candidate}-prescreening.md` | Base set: `{role}-prescreening-base.md` ([reused / created / revised on date])

## CV-JD Alignment Summary

| Area | Status | Notes |
|------|--------|-------|
| [Requirement 1] | Match / Partial / Gap / Unclear | [Brief note] |
| ... | ... | ... |

## Signals per Question

| # | Question | Rationale | Green | Yellow | Red |
|---|----------|-----------|-------|--------|-----|
| 1 | [Question summary] | [Why asked — maps to JD requirement X] | [What good looks like] | [Borderline signals] | [Signals to discuss with the hiring manager] |
| 3 | Optional career-path question | Gives room for context | — not rated — | — | — |
| ... | ... | ... | ... | ... | ... |

**Suggested threshold:** Proceed when Categories 1–4 have no Red and no more than [N] Yellow signals; Category 5 is not counted. This is a suggestion: a person reviews every Hold or Reject, and no candidate is rejected on the threshold alone.

Record only job-relevant information from the answers. If a candidate mentions health, pregnancy, disability, family or another personal circumstance, do not record it.
```

### Live Mode — Screening Script (interviewer only)

```markdown
> Confidential — candidate personal data for the [Role Title] selection. Hiring team only. Delete by [YYYY-MM-DD] (retention policy).

# Live Screening Script — [Candidate Name] for [Role Title]

**Date:** [date]
**Interviewer:** _______________
**Suggested duration:** 15-20 minutes
**Base set:** `{role}-prescreening-base.md` ([reused / created / revised on date])

## Opening Script
"Hello [Candidate Name], thank you for taking the time to speak with me today. My name is [Interviewer] and I'm [role] at [Company]. The purpose of this call is to learn more about your background and answer any questions you have about the [Role Title] position. We'll use what you tell me only to assess your application for this role; our privacy notice, [which we sent you / at link], explains how we handle your data and how long we keep it. This should take about 15-20 minutes. Shall we begin?"

## CV-JD Alignment Summary (interviewer reference)

| Area | Status | Notes |
|------|--------|-------|
| [Requirement 1] | Match / Partial / Gap / Unclear | [Brief note] |
| ... | ... | ... |

## Screening Questions

### Logistics & Eligibility (~3 min)

#### Q1: [Question — conversational phrasing; for salary, state the pay range first]
*Rationale (interviewer only): [Why this matters — maps to logistics prerequisite]*
*Follow-up probes: [If answer is vague: "Could you clarify...?" / If partial: "Would you be open to...?"]*
*Green flag: [What good sounds like]*
*Red flag: [What to discuss with the hiring manager]*
**Notes:** _________________________________

### Experience Alignment (~5 min)

#### Q2: [Question]
*Rationale (interviewer only): [Maps to JD requirement X, CV shows it as partial/missing/unclear]*
*Follow-up probes: [If vague: "Can you give a specific example?" / If general: "What was your specific role in that?"]*
*Green flag: [Specific examples, clear ownership, measurable outcomes]*
*Red flag: [Cannot provide specifics, contradicts CV, deflects]*
**Notes:** _________________________________

#### Q3 (optional): "Is there anything about your career path that your CV doesn't show and that you'd like us to know?"
*Not rated. Record only job-relevant skills or experience; never record a personal reason (health, pregnancy, disability, family).*
**Notes:** _________________________________

### Motivation (~3 min)

#### Q4: [Question]
*Rationale (interviewer only): [Assesses genuine interest]*
*Follow-up probes: [If generic: "What specifically about [aspect] interests you?"]*
*Green flag: [Role-specific reasons, company research, aligned enthusiasm]*
*Red flag: [Cannot articulate why, confuses company, misaligned expectations]*
**Notes:** _________________________________

### Key Competency Probe (~5 min)

#### Q5: [Question]
*Rationale (interviewer only): [Maps to JD competency Y]*
*Follow-up probes: [If no STAR: "What was the situation?" / "What did you specifically do?" / "What was the result?"]*
*Green flag: [Structured answer, demonstrates competency at JD level, self-aware]*
*Red flag: [No relevant example, fundamental misunderstanding, contradicts CV]*
**Notes:** _________________________________

### Candidate Questions (~3 min)

#### Q6: "Do you have any questions about the role, the team, or the company?"
*Green flag: [Thoughtful questions showing preparation and genuine interest]*
*Red flag: [Questions revealing misalignment with stated role parameters — not counted in the threshold]*
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
| Candidate Questions | ___ (not counted) | ___ |

**Interviewer's recommendation:** Proceed / Hold / Reject — a suggestion for the hiring manager; a person reviews every Hold or Reject before the candidate is told
**Rationale:** _______________________________________________
```

---

## 5. Integration

- **Consumes:** Job Description from the `job-description` skill (or provided directly by the user)
- **Invokes:** `compliance-check` in embedded mode (Step 5) as the last check, on the questionnaire or script and on the recruiter guide
- **Produces output for:** `interview-prep` skill — the pre-screening results and CV-JD alignment inform the design of the next interview stage

---

## 6. Language Detection

Use the dominant language of the input documents and conversation for output. When the inputs clearly mix languages, recommend the dominant language and ask the user to confirm; when no language dominates, ask the user to choose.

Supported languages:
- `en` — English
- `it` — Italian

For unsupported languages: produce the questionnaire structure in the detected language where possible, use English for internal guidance, and note the limitation to the user.
