---
name: interview-prep
description: "Prepare technical interviewers and department evaluators for candidate interviews. Produces three output files: a position assessment analyzing candidate fit (strengths, gaps, risks), a question suggestions document with STAR-method behavioral questions (including rationale, good/excellent answer examples, and follow-up probes per competency), and a minimal interview-notes template for capturing impressions during the interview. Performs deep CV-vs-JD analysis across 4-6 competencies. Invokes compliance-check validation before output. Use when the user says 'prepare interview for', 'interview questions for', 'prepare me for interviewing', 'preparazione colloquio', 'domande colloquio per', 'prepara domande per', or mentions preparing for a candidate interview."
---

# Interview Prep — Interview Preparation Kit Generator

## 1. Overview

This skill prepares technical interviewers and department evaluators for candidate interviews. It consumes a Job Description and Candidate CV (plus optional pre-screening results and HR notes), performs a deep competency analysis, and produces three output files:

1. **Position Assessment** (`{candidate}-position-assessment.md`) — the interviewer's private briefing on candidate fit: strengths, gaps, risks, and areas to investigate
2. **Question Suggestions** (`{candidate}-interview-questions.md`) — the interview script: 4-6 STAR-method behavioral questions with rationale, good/excellent answer examples, red flags, follow-up probes, and a time allocation table
3. **Interview Notes Template** (`{candidate}-interview-notes.md`) — a minimal template for capturing impressions during the interview: free-text area, two tips, quick score grid, and one closing question

The user persona is a technical interviewer or department evaluator — someone with domain expertise who needs structured preparation, not HR training.

**Output directory:** `docs/outbox/` (configurable)

**Connector support:** Skills degrade gracefully without connectors. See `CONNECTORS.md` for the full registry.

- If **~~ATS** is connected: pull candidate CV, application data, job requisition details, and pre-screening results automatically
- If **~~knowledge base** is connected: pull organization-specific competency frameworks, seniority matrices, interview templates, and past interview data for the same role

If no connectors are available, the skill asks the user to provide JD, CV, and any additional context manually, and proceeds with its built-in reference files.

---

## 2. Pipeline

### Step 1 — Input Collection

Collect the required and optional inputs:

**Required:**
1. **Job Description** — accept as file path, pasted text, or URL. If the JD was produced by the sibling `job-description` skill, it can be referenced directly.
2. **Candidate CV / application** — accept as file path, pasted text, or email content.

**Optional:**
3. **Pre-screening results** — output from the `pre-screening` skill or equivalent recruiter notes. If available, the skill avoids duplicating questions already answered.
4. **HR notes** — recruiter observations, hiring manager preferences, team context.

If **~~ATS** is connected: search for the candidate profile, job requisition, and any pre-screening results by name or ID. Pull structured data automatically.

If **~~knowledge base** is connected: search for organization-specific competency frameworks, seniority matrices (e.g., expected competency levels by grade), and interview templates for the role's department or level.

**Interview format:** Ask the user:
- Interview format: panel / 1:1 / sequential
- Total interview duration (minutes)
- Number and roles of interviewers (for panel/sequential)

**Corporate context with memory:** Check conversation memory for previously stored corporate context (company name, seniority matrix, competency frameworks, standard interview formats). If found, apply silently. If new corporate context is provided, save it to memory for future sessions.

**Output format preference:** Check memory for previously stored output format preference (formatting choices, default interview format). If found, apply as default without re-asking.

**Language detection:** Count language-specific tokens across all input documents:
- **>80% single language** — auto-select that language for output
- **60-80% dominant language** — recommend dominant, ask user to confirm
- **<60% any language** — ask user to choose

### Step 2 — Deep CV-JD Analysis

`Read references/scoring-rubric.md`

Perform a structured competency mapping of the candidate's CV against the JD requirements:

1. **Competency extraction** — parse the JD into 4-6 core competencies. For each competency, define the expected level using the BARS scale (what does a "4" look like for this role at this seniority?).
2. **CV evidence mapping** — for each competency, search the CV for supporting evidence and classify as:
   - **Strength** — CV clearly demonstrates the competency at or above the expected level with specific evidence
   - **Gap** — CV does not address this competency, or evidence suggests a level significantly below expectations
   - **To Investigate** — CV suggests relevant experience but evidence is ambiguous, insufficient, or at an unclear level
3. **Risk identification** — flag patterns that warrant attention: CV gaps, short tenures, career trajectory inconsistencies, over-claimed titles, missing progression in stated expertise areas
4. **Seniority calibration** — if a seniority matrix is available (from memory or ~~knowledge base), calibrate expectations to the specific grade/level

Present the competency mapping to the user before proceeding.

### Step 3 — Position Assessment

Produce the first output file: `docs/outbox/{candidate}-position-assessment.md`

This is the interviewer's private briefing document. It synthesizes the CV-JD analysis into a structured assessment of candidate fit (see Section 4 for the template).

The assessment does not make a hire/no-hire recommendation — it provides the evidence base for the interviewer to form their own judgment during the interview.

### Step 4 — Question Generation

`Read references/star-method.md`

Generate 4-6 behavioral questions, one per competency identified in Step 2. For each question, produce:

- **The question itself** — STAR-method behavioral question using the appropriate template
- **Rationale** — why this question was selected and which competency it targets
- **Good answer example** (score 4) — what a solid, convincing answer sounds like
- **Excellent answer example** (score 5) — what an exceptional, differentiated answer sounds like
- **Red flags** — specific signals that would indicate concern
- **Follow-up probes** — 1-2 probes for when the initial answer is vague on Action, cannot quantify Result, or conflates team and individual contribution

**Question allocation rules:**
- Strengths: 1-2 questions (confirm and explore depth)
- Gaps: 2-3 questions (investigate, give fair chance to demonstrate)
- To Investigate: 1-2 questions (clarify ambiguous areas)

**Time allocation:** Produce a time allocation table distributing the interview duration across competencies, with higher-priority competencies (gaps and to-investigate areas) receiving more time.

### Step 5 — Interview Notes Template

Produce the third output file: `docs/outbox/{candidate}-interview-notes.md`

**Design philosophy:** Capture signal, not bureaucracy. The template is deliberately minimal — interviewers should spend their cognitive energy listening and probing, not filling out forms. The detailed scoring happens post-interview using the rubric.

The template includes:
- A free-text area for writing impressions during the interview
- Two practical tips for effective note-taking
- A quick score grid (competency x 1-5 scale) to fill after the interview
- One closing question: "Would you want this person on your team? Why / why not?"

### Step 6 — Compliance Validation

Invoke the **compliance-check** skill in embedded mode, passing:

- `text` — the generated position assessment and interview questions
- `document_type` — `interview_questions`
- `jurisdiction` — auto-detected from input language and content cues

Review the findings:
- **CRITICAL** findings: automatically fix and regenerate the affected content
- **WARNING** findings: fix where possible, flag remaining items to the user
- **INFO** findings: apply improvements where straightforward

If any content is modified, note the compliance adjustments in the output.

### Step 7 — Redundancy Check

If pre-screening results were consumed in Step 1:

1. Compare the generated interview questions against the pre-screening questions and answers
2. Remove or rephrase any interview question that substantially duplicates a pre-screening question
3. For pre-screening questions where the candidate gave a partial or flagged answer, design a deeper follow-up rather than repeating the same question
4. Note in the question rationale: "Pre-screening covered [topic] — this question goes deeper on [specific aspect]"

### Step 8 — Output

Produce all three files in `docs/outbox/`:

1. `{candidate}-position-assessment.md`
2. `{candidate}-interview-questions.md`
3. `{candidate}-interview-notes.md`

Present a summary to the user:
- Number of competencies analyzed
- Fit overview (strengths / gaps / to-investigate counts)
- Number of questions generated with time allocation
- Compliance status (pass / pass with warnings / any adjustments made)
- Interview format confirmation
- Suggested next steps: conduct the interview using the question plan; after the interview, use `interview-close` to consolidate notes into a structured evaluation

---

## 3. Progressive Disclosure

| Step | Documents to Read |
|------|-------------------|
| Step 1 | (no references — in-skill input collection and format negotiation) |
| Step 2 | `references/scoring-rubric.md` |
| Step 3 | (no additional references — in-skill assessment generation from Step 2 analysis) |
| Step 4 | `references/star-method.md` |
| Step 5-8 | (no additional references — in-skill template generation, compliance invocation, and output) |

---

## 4. Output Templates

### Position Assessment

```markdown
# Position Assessment — [Candidate Name] for [Role Title]

Date: [date]

## Candidate Profile Summary

[Brief paragraph: current role, years of experience, education highlights, career trajectory]

## Fit Analysis

### Strengths (Pro)

| Competency | Evidence from CV | Fit Level |
|------------|-----------------|-----------|
| [e.g., System Design] | [Specific CV evidence] | Strong / Exceeds expectations |
| ... | ... | ... |

### Gaps & Risks (Con)

| Area | Concern | Severity | Mitigable? |
|------|---------|----------|------------|
| [e.g., Team Leadership] | [Specific concern] | High / Medium / Low | Yes — probe in interview / No — structural gap |
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
# Interview Questions — [Candidate Name] for [Role Title]

Interview format: [panel / 1:1 / sequential] | Duration: [X min]

## Question Plan (4-6 competencies)

### Competency: [e.g., System Design]

**Question:** "Tell me about a time when you [scenario]..."

**Rationale:** [Why this question — maps to JD requirement X, CV shows Y, pre-screening indicated Z]

**Good answer example:** [What a score-4 answer sounds like — specific enough to calibrate the interviewer]

**Excellent answer example:** [What a score-5 answer sounds like — differentiating depth, quantification, strategic thinking]

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
# Interview Notes — [Candidate Name] for [Role Title]

Date: _______ | Interviewer: _______

## Your Impressions

Write freely during the interview. Focus on what the candidate says and does, not your interpretation.

> Tip 1: Note specific things the candidate SAID or DID — direct quotes are gold for post-interview scoring.

> Tip 2: If an answer surprises you (positively or negatively), mark it with a star (*). These moments are the strongest signal.

[Leave generous blank space]

## Quick Scores (fill after the interview)

| Competency | 1 | 2 | 3 | 4 | 5 | Notes |
|------------|---|---|---|---|---|-------|
| [Competency 1] | | | | | | |
| [Competency 2] | | | | | | |
| [Competency 3] | | | | | | |
| [Competency 4] | | | | | | |
| [Competency 5] | | | | | | |
| [Competency 6] | | | | | | |

## Would you want this person on your team? Why / why not?

[Leave space for open-ended reflection]
```

---

## 5. Integration

- **Consumes:** Job Description from the `job-description` skill (or provided directly by the user); pre-screening results from the `pre-screening` skill (optional)
- **Invokes:** `compliance-check` in embedded mode (Step 6) to validate assessment and questions
- **Produces output for:** `interview-close` skill — the position assessment, question plan, and interview notes are consumed by interview-close to produce the final structured evaluation

---

## 6. Language Detection

Count language-specific tokens across all input documents and conversation context. Classification:

- **>80% single language** — auto-select that language for output
- **60-80% dominant language** — recommend dominant, ask user to confirm
- **<60% any language** — ask user to choose

Supported languages:
- `en` — English
- `it` — Italian

For unsupported languages: produce the output structure in the detected language where possible, use English for internal guidance, and note the limitation to the user.
