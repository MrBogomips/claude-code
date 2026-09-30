# Screening Categories Reference

This reference defines the five question categories for pre-screening questionnaires, delivery mode guidance, evaluation criteria, question design principles, and the job-relevant signals to discuss.

**Role-level base set.** Categories 1, 3, 4 and 5 are the same for every candidate for a role: they are written once to `{role}-prescreening-base.md` and reused. Only Category 2 is generated from each CV.

---

## 1. Question Categories

### Category 1 — Logistics / Eligibility (role-level)

Questions that verify basic prerequisites before investing time in deeper evaluation. These are binary or near-binary filters, the same for every candidate for the role.

**Example questions:**

1. "Are you legally authorized to work in [country] without sponsorship?" — Verifies right-to-work status upfront.
2. "This role requires [on-site presence in City / hybrid 3 days / fully remote]. Does this arrangement work for you?" — Confirms location and work-model compatibility.
3. "What is your earliest possible start date?" — Checks availability against the hiring timeline.
4. "The gross annual pay range for this role is [range]. What are your salary expectations?" — Surfaces misalignment early. State the range first: in EU jurisdictions the range must reach the candidate before the interview, and questions about current or past pay are banned (compliance-check's `legal-map.md` Section 3). Never ask about current or past pay.

### Category 2 — Experience Alignment (per candidate)

Questions that probe the candidate's CV claims against the JD requirements. Focus on requirements the CV does not show, unclear claims, and specifics. This is the only category generated from each CV.

**Example questions:**

1. "Your CV shows [N years] in [domain], but the role requires hands-on experience with [specific technology/method]. Can you describe a project where you used [specific technology/method] and your role in it?" — Verifies depth behind a general claim.
2. *(Optional, the same wording for every candidate)* "Is there anything about your career path that your CV does not show and that you would like us to know?" — Gives the candidate room to add context. It is the only question that may touch a CV gap. It is marked optional, it is never scored, and the recruiter records only job-relevant skills or experience the answer mentions — never a reason such as health, pregnancy, disability or caring for a relative. Do not ask about a specific gap or its dates.
3. "The JD emphasizes [requirement X]. Which of your previous roles gave you the most relevant experience for this, and what was the outcome?" — Forces a concrete mapping from CV to JD.

### Category 3 — Motivation (role-level)

Questions that assess genuine interest in the role and the organization. Keep this category short (max 2 questions) to avoid performative answers.

**Example questions:**

1. "What specifically attracted you to this role compared to other opportunities you may be considering?" — Gauges role-specific interest versus generic job-seeking.
2. "What do you know about [Company] and what aspect of our work interests you most?" — Tests whether the candidate has done basic research and has authentic interest.

### Category 4 — Key Competency Probe (role-level)

Light-touch questions derived directly from the JD's key competencies. These are not deep technical assessments — they verify baseline competency and communication ability.

**Example questions:**

1. "The role involves [key competency from JD, e.g., 'leading cross-functional teams']. Describe a recent situation where you demonstrated this and what the result was." — STAR-format prompt for the top JD competency.
2. "How would you approach [a realistic scenario derived from the JD] in your first 90 days?" — Tests practical thinking and planning ability.
3. "[Technical/domain question calibrated to the JD's minimum requirements]." — Verifies baseline knowledge without deep-dive assessment.

### Category 5 — Candidate Questions (role-level)

Open space for the candidate to ask questions. This category has no scored questions — it serves engagement and employer branding.

**Example prompts:**

1. "Do you have any questions about the role, the team, or the company that would help you evaluate this opportunity?" — Standard open prompt.
2. "Is there anything about the role description that was unclear or that you would like more detail on?" — Invites clarification and signals transparency.

---

## 2. Async vs. Live Mode Guidance

### Async Mode (candidate self-service)

The questionnaire is sent to the candidate (email, ATS form, or document) for self-paced completion.

**Tone and structure:**
- Formal, professional language
- Each question must be fully self-explanatory — no assumption of real-time clarification
- Rationale for each question is hidden from the candidate (included only in the evaluation guide for the recruiter)
- Include a brief instructions header: estimated completion time, deadline, how to submit, contact for questions

**Formatting rules:**
- Number all questions sequentially
- Provide word-count guidance for open questions (e.g., "Please answer in 2-4 sentences")
- Group questions by category with clear section headers
- Include a privacy notice reference at the top
- Keep the recruiter's evaluation guide in a separate file (`{candidate}-prescreening-guide.md`), so the file sent to the candidate contains nothing for the recruiter only

### Live Mode (interviewer script)

The questionnaire serves as a script for a phone or video screening call.

**Tone and structure:**
- Conversational language — questions read naturally when spoken aloud
- Include follow-up probes for each question (if the answer is vague or incomplete)
- Include timing cues: suggested duration per category and total call time (15-20 minutes)
- Provide note-taking space after each question (blank lines or fields)
- Include green flag and red flag indicators for each question to guide real-time assessment

**Formatting rules:**
- Interviewer-only rationale in italics (not to be read aloud)
- Follow-up probes indented under the main question
- Green/red flag indicators as bullet points under each question
- Opening script (greeting, purpose of call, privacy line, agenda) and closing script (next steps, timeline, thank you). The privacy line says what the answers are used for and where the privacy notice is

---

## 3. Pass/Fail Criteria per Category

These signals guide the recruiter; they do not decide. A person reviews every Hold or Reject, and no candidate is rejected on a threshold alone (GDPR Art. 22; compliance-check's `legal-map.md` Section 4). Each salary and availability rule is stated only here.

### Category 1 — Logistics / Eligibility

| Signal | Meaning | Action |
|--------|---------|--------|
| **Green** | Authorized to work; earliest start date within the hiring timeline; location compatible; salary expectation at or below the band maximum | Proceed |
| **Yellow** | Salary expectation up to 20% above the band maximum; earliest start later than the hiring timeline, including any delay from a standard notice period under the applicable CCNL; open to relocation but not confirmed | Note and discuss with hiring manager |
| **Red** | No work authorization and no sponsorship path; salary expectation more than 20% above the band maximum with no flexibility; hard refusal on location/model; earliest start after the latest start date the hiring manager can accept, for a reason other than a standard notice period | Discuss with the hiring manager; a person decides |

Measure salary only against the **band maximum** (not the midpoint) and availability only against the **hiring timeline** for the vacancy. A standard CCNL notice period is never Red. If no band or timeline was provided, mark the signal "not assessed" instead of guessing.

### Category 2 — Experience Alignment

| Signal | Meaning | Action |
|--------|---------|--------|
| **Green** | Clear, specific examples mapping CV claims to JD requirements | Proceed |
| **Yellow** | Relevant experience exists but is tangential; claims are general without specifics | Proceed with note: verify in technical interview |
| **Red** | Cannot provide concrete examples for key requirements; answers contradict information the candidate provided (CV, application, earlier answers) | Discuss with the hiring manager; a person decides |

A CV gap is never a signal of any color, and the optional career-path question is never rated.

### Category 3 — Motivation

| Signal | Meaning | Action |
|--------|---------|--------|
| **Green** | Articulates specific, role-relevant reasons; demonstrates company research; enthusiasm aligned with actual role scope | Proceed |
| **Yellow** | Generic motivation ("looking for growth"); minimal company knowledge but genuine interest; focus on compensation only | Note: explore further in interview |
| **Red** | Cannot articulate why this role; confuses company with competitor; motivation contradicts role reality (e.g., wants solo work for a team-lead role) | Discuss with the hiring manager; a person decides |

### Category 4 — Key Competency Probe

| Signal | Meaning | Action |
|--------|---------|--------|
| **Green** | Provides structured answer (situation, action, result); demonstrates competency at or above JD level; shows self-awareness | Proceed |
| **Yellow** | Answer is relevant but lacks specifics; competency demonstrated at lower level than JD requires; theoretical rather than practical | Proceed with note: deep-dive in technical interview |
| **Red** | Cannot provide any relevant example; answer reveals fundamental misunderstanding of the competency; contradicts CV claims | Discuss with the hiring manager; a person decides |

### Category 5 — Candidate Questions

| Signal | Meaning | Action |
|--------|---------|--------|
| **Green** | Asks thoughtful questions about role, team, growth, challenges; questions show preparation | Positive signal — note topics raised |
| **Yellow** | No questions or only procedural questions (timeline, next steps) | Neutral — not a disqualifier |
| **Red** | Questions reveal misalignment (e.g., asks about remote work when role is on-site and this was already stated) | Note the misalignment — discuss with hiring manager. Category 5 is never counted in the pass/fail threshold |

### Suggested Threshold

"Proceed when Categories 1–4 have no Red and no more than [N] Yellow signals." Category 5 is not counted. The threshold is a suggestion for the recruiter: a person reviews every Hold or Reject before the candidate is told.

---

## 4. Question Design Principles

1. **Maximum 12 questions per questionnaire.** Beyond 12, candidate fatigue reduces response quality and completion rates.

2. **Every question must trace to a JD requirement.** No question exists for curiosity — each must map to a specific requirement, competency, or logistical prerequisite from the JD.

3. **Standardize across candidates.** All candidates for the same role receive the same base questions: Categories 1, 3, 4 and 5 come from `{role}-prescreening-base.md`, written on the first run for the role and reused after that. Only Category 2 varies with the CV, and it is documented alongside the standard set.

4. **One concept per question.** Compound questions ("Tell me about your experience with X and how you would approach Y") produce muddy answers. Split them.

5. **Calibrate to the screening stage.** Pre-screening is a filter, not a deep assessment. Questions should be answerable in 2-4 sentences. Reserve complex scenarios for interview-prep.

6. **Use open-ended questions for Categories 2-4.** Yes/no questions are appropriate for Category 1 (logistics) but not for assessing experience, motivation, or competency.

7. **Avoid leading questions.** "Don't you think X is important?" reveals the expected answer. Use neutral framing: "How do you approach X?"

8. **Include difficulty gradient.** Start with easier logistics questions, progress to experience alignment, then competency probes. This builds candidate comfort and provides a natural warm-up.

---

## 5. Signals to Discuss

Every signal below is tied to a job-relevant factor. None refers to a protected characteristic or to a proxy for one: CV gaps, career breaks and the reasons for them are never a signal (compliance-check's `prohibited-topics.md`, "Career Gaps and Breaks"). Salary and availability are judged only by the Category 1 table in Section 3. A signal starts a conversation with the hiring manager; it never rejects a candidate by itself.

### Consistency
- Answers that contradict information the candidate provided (CV, application form, earlier answers)
- Frequent short tenures (<6 months) across multiple roles, when the candidate's own account gives no context (contract work excluded)

### Expectations
- Expectations that suggest the candidate views the role as a temporary step (e.g., "I need something while I wait for [other opportunity]")

### Logistics Blockers
- No current work authorization and the organization does not sponsor
- Hard location constraints incompatible with the role model

### Communication Signals
- Inability to provide specific examples for claimed experience (vague generalities only)
- Answers that contradict information on the CV
- Disengagement indicators: very short answers to all questions, no questions asked, dismissive tone about the process

### Role Fit Signals
- Motivation focused entirely on factors the role does not offer (e.g., pure management for an IC role)
- Fundamental misunderstanding of the role scope after it has been explained
