---
name: interview-prep
description: "Use when an interviewer needs to prepare for a specific candidate's interview from a JD and CV — 'prepare interview for', 'interview questions for', 'prepare me for interviewing', 'preparazione colloquio', 'prepara domande per', 'domande colloquio per'. Produces a position assessment, 4-6 STAR behavioral questions with good and excellent answer anchors and follow-up probes, and a minimal notes template, with a compliance check as the last step. Not for a first screening call or phone screen (pre-screening) or for scoring after the interview (interview-close)."
---

# Interview Prep — Interview Preparation Kit Generator

## 1. Overview

This skill prepares technical interviewers and department evaluators for candidate interviews. It consumes a Job Description and Candidate CV (plus optional pre-screening results and HR notes), performs a deep competency analysis, and produces three output files:

1. **Position Assessment** (`{candidate}-position-assessment.md`) — the interviewer's private briefing on candidate fit: strengths, gaps, risks, and areas to investigate
2. **Question Suggestions** (`{candidate}-interview-questions.md`) — the interview script: 4-6 STAR-method behavioral questions with rationale, good/excellent answer examples, red flags, follow-up probes, and a time allocation table
3. **Interview Notes Template** (`{candidate}-interview-notes.md`) — a minimal template for capturing impressions during the interview: free-text area, two tips, quick score grid, and one closing question

The user persona is a technical interviewer or department evaluator — someone with domain expertise who needs structured preparation, not HR training.

**Output directory:** the output folder the project's CLAUDE.md declares; if none is declared, ask the user.

**Candidate data.** These files hold candidate personal data. Suggest an output folder outside version control; if the chosen folder is inside a git repository, say so and ask the user to confirm. Start every candidate file with the confidentiality line shown in the output templates, with the delete-by date taken from the organization's retention period (ask once if it is unknown). Never save candidate data — names, CV content, answers, notes, scores — to memory; only corporate context may be saved there.

**Connector support:** Skills degrade gracefully without connectors. See `CONNECTORS.md` for the full registry.

- If **~~ATS** is connected: pull candidate CV, application data, job requisition details, and pre-screening results automatically
- If **~~knowledge base** is connected: pull organization-specific competency frameworks, seniority matrices, interview templates, and past interview data for the same role
- If **~~document converter** is connected: convert a DOCX or PDF CV or JD to Markdown before the analysis

If no connectors are available, the skill asks the user to provide JD, CV, and any additional context manually, and proceeds with its built-in reference files.

---

## 2. Pipeline

### Step 1 — Input Collection

Collect the required and optional inputs:

**Required:**
1. **Job Description** — accept as file path, pasted text, or URL. If the JD was produced by the sibling `job-description` skill, it can be referenced directly.
2. **Candidate CV / application** — accept as file path, pasted text, or email content.

If a CV or JD is a DOCX or PDF file: convert it with **~~document converter** when connected; otherwise ask the user to paste the text.

**Optional:**
3. **Pre-screening results** — output from the `pre-screening` skill or equivalent recruiter notes. If available, the skill avoids duplicating questions already answered.
4. **HR notes** — recruiter observations, hiring manager preferences, team context.

If **~~ATS** is connected: search for the candidate profile, job requisition, and any pre-screening results by name or ID. Pull structured data automatically.

If **~~knowledge base** is connected: search for organization-specific competency frameworks, seniority matrices (e.g., expected competency levels by grade), and interview templates for the role's department or level.

**Interview format:** Ask the user:
- Interview format: panel / 1:1 / sequential
- Total interview duration (minutes)
- Number and roles of interviewers (for panel/sequential)

**Seniority matrix:** look for `{role}-seniority-matrix.md` in the output folder (interview-close saves it once a matrix for the role is confirmed). If it exists, use its expected scores for the target level.

**Corporate context with memory:** Check conversation memory for previously stored corporate context (company name, competency frameworks, standard interview formats). If found, apply silently. If new corporate context is provided, save it to memory for future sessions — corporate context only, never candidate data.

**Output format preference:** Check memory for previously stored output format preference (formatting choices, default interview format). If found, apply as default without re-asking.

**Language detection:** Use the dominant language of the input documents and conversation for output. When the inputs clearly mix languages, recommend the dominant language and ask the user to confirm; when no language dominates, ask the user to choose.

### Step 2 — Deep CV-JD Analysis

`Read references/scoring-rubric.md`

Perform a structured competency mapping of the candidate's CV against the JD requirements:

1. **Competency extraction** — parse the JD into 4-6 core competencies. For each competency, set the **expected score** for the target level on the canonical absolute 1–5 scale (defined in the interview-close skill, `evaluation-template.md` Section 3, in `../interview-close/references/`): take it from `{role}-seniority-matrix.md` when it exists; otherwise propose it and state it in the position assessment, so interview-close can confirm or correct it when it builds the matrix.
2. **CV evidence mapping** — for each competency, search the CV for supporting evidence and classify as:
   - **Strength** — CV clearly demonstrates the competency at or above the expected level with specific evidence
   - **Gap** — CV does not address this competency, or evidence suggests a level significantly below expectations
   - **To Investigate** — CV suggests relevant experience but evidence is ambiguous, insufficient, or at an unclear level
3. **Risk identification** — flag job-relevant patterns that warrant a question: claims the CV does not support, over-claimed titles, scope that is unclear for a stated expertise area. CV gaps, career breaks and any protected characteristic are never a risk: do not list them, and do not plan questions about them (see compliance-check's prohibited topics)
4. **Seniority calibration** — if a seniority matrix is available (`{role}-seniority-matrix.md`, or a corporate matrix from **~~knowledge base**), calibrate expectations to the specific grade/level

Present the competency mapping to the user before proceeding.

### Step 3 — Position Assessment

Draft the first document, `{candidate}-position-assessment.md`. Nothing is written until Step 8, after the compliance check.

This is the interviewer's private briefing document. It synthesizes the CV-JD analysis into a structured assessment of candidate fit (see Section 4 for the template).

The assessment does not make a hire/no-hire recommendation — it provides the evidence base for the interviewer to form their own judgment during the interview.

### Step 4 — Question Generation

`Read references/star-method.md`

Generate one primary behavioral question per competency identified in Step 2 (4-6 questions). For each question, produce:

- **The question itself** — STAR-method behavioral question using the appropriate template
- **Rationale** — why this question was selected and which competency it targets
- **Good answer example** — an answer at the expected score for the target level (canonical scale)
- **Excellent answer example** — an answer one point above the expected score (a strong 5 when 5 is expected)
- **Red flags** — specific signals that would indicate concern
- **Follow-up probes** — 1-2 probes for when the initial answer is vague on Action, cannot quantify Result, or conflates team and individual contribution

**Competency selection rules** (one primary question each, 4-6 in total):
- Strengths: choose 1-2 competencies (confirm and explore depth)
- Gaps: choose 2-3 competencies (investigate, give a fair chance to demonstrate)
- To Investigate: choose 1-2 competencies (clarify ambiguous areas)

**Time allocation:** Produce a time allocation table distributing the interview duration across competencies, with higher-priority competencies (gaps and to-investigate areas) receiving more time.

### Step 5 — Interview Notes Template

Draft the third document, `{candidate}-interview-notes.md` (written in Step 8).

**Design philosophy:** Capture signal, not bureaucracy. The template is deliberately minimal — interviewers should spend their cognitive energy listening and probing, not filling out forms. The detailed scoring happens post-interview using the rubric.

The template includes:
- A free-text area for writing impressions during the interview
- Two practical tips for effective note-taking
- A quick score grid (competency x 1-5 scale, plus Not assessed) to fill after the interview
- One closing question: "Which competency needs more evidence before a decision, and what would you ask to get it?"

### Step 6 — Redundancy Check

If pre-screening results were consumed in Step 1:

1. Compare the generated interview questions against the pre-screening questions and answers
2. Remove or rephrase any interview question that substantially duplicates a pre-screening question
3. For pre-screening questions where the candidate gave a partial or flagged answer, design a deeper follow-up rather than repeating the same question
4. Note in the question rationale: "Pre-screening covered [topic] — this question goes deeper on [specific aspect]"

### Step 7 — Compliance Validation (last check before output)

Run compliance-check on the final text of all three documents, after the redundancy check, so that nothing changes after the check. Load compliance-check with the Skill tool and the arguments `embedded position_assessment,interview_questions,other` (the notes template is `other`; the call is defined in compliance-check's Section 5; the jurisdiction is auto-detected). If the Skill tool cannot load it, read `../compliance-check/SKILL.md` and apply its embedded mode.

Review the findings:
- **CRITICAL** findings: automatically fix and regenerate the affected content
- **WARNING** findings: fix where possible, flag remaining items to the user
- **INFO** findings: apply improvements where straightforward

If any content is modified, note the compliance adjustments in the output.

### Step 8 — Output

Produce all three files in the output directory:

1. `{candidate}-position-assessment.md`
2. `{candidate}-interview-questions.md`
3. `{candidate}-interview-notes.md`

Present a summary to the user:
- Number of competencies analyzed
- Fit overview (strengths / gaps / to-investigate counts)
- Number of questions generated with time allocation
- Compliance status (pass / pass with warnings / any adjustments made)
- Interview format confirmation
- Suggested next steps: conduct the interview using the question plan; after the interview, each interviewer uses `interview-close` to turn their notes into their own structured evaluation

---

## 3. Progressive Disclosure

| Step | Documents to Read |
|------|-------------------|
| Step 1 | (no references — in-skill input collection and format negotiation) |
| Step 2 | `references/scoring-rubric.md` |
| Step 3 | (no additional references — in-skill assessment generation from Step 2 analysis) |
| Step 4 | `references/star-method.md` |
| Step 5-6 | (no additional references — in-skill template generation and redundancy check) |
| Step 7 | (no references — invokes compliance-check skill in embedded mode) |
| Step 8 | (no additional references — in-skill output) |

---

## 4. Output Templates

### Position Assessment

```markdown
> Confidential — candidate personal data for the [Role Title] selection. Hiring team only. Delete by [YYYY-MM-DD] (retention policy).

# Position Assessment — [Candidate Name] for [Role Title]

Date: [date] | Target level: [level] | Expected scores: [`{role}-seniority-matrix.md` / proposed here]

## Candidate Profile Summary

[Brief paragraph: current role, years of experience, education highlights, career trajectory]

## Fit Analysis

### Strengths (Pro)

| Competency | Evidence from CV | Expected score | Fit Level |
|------------|-----------------|----------------|-----------|
| [e.g., System Design] | [Specific CV evidence] | [1-5] | Meets / Exceeds the target level |
| ... | ... | ... |

### Gaps & Risks (Con)

| Area | Job-relevant concern | Impact on the role | Mitigable? |
|------|---------|----------|------------|
| [e.g., Team Leadership] | [Specific concern tied to a JD requirement] | High / Medium / Low | Yes — probe in interview / No — structural gap |
| ... | ... | ... | ... |

### Neutral / To Investigate

| Area | What's Unclear | How to Probe |
|------|---------------|--------------|
| [e.g., Cloud Architecture] | [CV mentions AWS but scope unclear] | [Suggested interview question focus] |
| ... | ... | ... |

## Overall Pre-Interview Assessment

[2-3 sentence synthesis: overall impression, key things to confirm or investigate during the interview, any watch-outs]
```

### Interview Questions

```markdown
> Confidential — candidate personal data for the [Role Title] selection. Hiring team only. Delete by [YYYY-MM-DD] (retention policy).

# Interview Questions — [Candidate Name] for [Role Title]

Interview format: [panel / 1:1 / sequential] | Duration: [X min] | Target level: [level]

Scoring: canonical absolute 1–5 scale with Not assessed (interview-close `evaluation-template.md` Section 3). Score each answer against the anchors first, then compare with the expected score below.

## Question Plan (4-6 competencies)

### Competency: [e.g., System Design] — expected score for the target level: [E]

**Question:** "Tell me about a time when you [scenario]..."

**Rationale:** [Why this question — maps to JD requirement X, CV shows Y, pre-screening indicated Z]

**Good answer example:** [What an answer at score E sounds like — specific enough to calibrate the interviewer]

**Excellent answer example:** [What an answer at score E+1 sounds like (a strong 5 when E is 5) — differentiating depth, quantification, strategic thinking]

**Red flags:** [Specific signals that indicate concern — e.g., cannot describe architecture decisions, defers to team, no scale context]

**Follow-up probes:**
- [If vague on Action]: "[probe question]"
- [If cannot quantify Result]: "[probe question]"
- [If team vs. individual unclear]: "[probe question]"

---

[Repeat for each competency]

## Time Allocation

| Competency | Minutes | Priority |
|------------|---------|----------|
| [e.g., System Design] | [X] | High / Medium |
| [e.g., Team Leadership] | [X] | High / Medium |
| ... | ... | ... |
| Opening & closing | [X] | — |
| **Total** | **[X]** | |

## Closing

Suggested closing question for the candidate: "[role-specific question that invites the candidate to ask about the team, technical challenges, or growth opportunities]"
```

### Interview Notes Template

```markdown
> Confidential — candidate personal data for the [Role Title] selection. Hiring team only. Delete by [YYYY-MM-DD] (retention policy).

# Interview Notes — [Candidate Name] for [Role Title]

Date: _______ | Interviewer: _______

## Your Impressions

Write freely during the interview. Focus on what the candidate says and does, not your interpretation. Leave out appearance, demeanor and anything about protected characteristics or personal circumstances the candidate mentions.

> Tip 1: Note specific things the candidate SAID or DID — direct quotes are gold for post-interview scoring.

> Tip 2: If an answer surprises you (positively or negatively), mark it with a star (*). These moments are the strongest signal.

[Leave generous blank space]

## Quick Scores (fill after the interview)

| Competency | 1 | 2 | 3 | 4 | 5 | Not assessed | Notes |
|------------|---|---|---|---|---|--------------|-------|
| [Competency 1] | | | | | | | |
| [Competency 2] | | | | | | | |
| [Competency 3] | | | | | | | |
| [Competency 4] | | | | | | | |
| [Competency 5] | | | | | | | |
| [Competency 6] | | | | | | | |

## Which competency needs more evidence before a decision, and what would you ask to get it?

[Leave space for open-ended reflection]
```

---

## 5. Integration

- **Consumes:** Job Description from the `job-description` skill (or provided directly by the user); pre-screening results from the `pre-screening` skill (optional)
- **Invokes:** `compliance-check` in embedded mode (Step 7) as the last check, on the assessment, the questions and the notes template
- **Reads if present:** `{role}-seniority-matrix.md`, saved by interview-close
- **Produces output for:** `interview-close` skill — the position assessment, question plan, and interview notes are consumed by interview-close to produce the final structured evaluation

---

## 6. Language Detection

Use the dominant language of the input documents and conversation for output. When the inputs clearly mix languages, recommend the dominant language and ask the user to confirm; when no language dominates, ask the user to choose.

Supported languages:
- `en` — English
- `it` — Italian

For unsupported languages: produce the output structure in the detected language where possible, use English for internal guidance, and note the limitation to the user.
