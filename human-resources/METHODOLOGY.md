# HR Interview Workflow — Methodology

> **Purpose:** This document explains the philosophy, theoretical foundations, workflow design, and legal framework behind the Human Resources interview plugin. It is self-contained and intended as a training resource for stakeholders, hiring managers, and HR professionals. No knowledge of the plugin's technical implementation is required.

---

## Table of Contents

1. [Philosophy & Vision](#1-philosophy--vision)
2. [Theoretical Foundations](#2-theoretical-foundations)
3. [The Workflow Pipeline](#3-the-workflow-pipeline)
4. [Design Rationale — Key Decisions](#4-design-rationale--key-decisions)
5. [Usage Scenarios](#5-usage-scenarios)
6. [Legal & Compliance Framework](#6-legal--compliance-framework)
7. [Appendix](#7-appendix)

---

## 1. Philosophy & Vision

### Why Structured Interviewing Matters

Unstructured interviews — the "let's have a chat and see if they're a good fit" approach — are one of the least effective methods for predicting job performance. They feel natural, but they are unreliable. Different interviewers ask different questions, weigh answers differently, and walk away with different impressions of the same candidate. The result is hiring decisions driven by gut feeling, rapport, and cognitive bias rather than evidence.

The research is clear. Schmidt and Hunter's landmark meta-analysis (1998) demonstrated that **structured interviews have the highest predictive validity** for job performance among all commonly used selection methods, and that organizations using structured interviewing achieve **36% higher quality-of-hire** compared to those relying on unstructured approaches. The difference is not marginal — it is the gap between a methodology and a conversation.

### The Problem with Unstructured Interviews

Three risks compound when interviews lack structure:

1. **Bias.** Without a standardized rubric, interviewers default to cognitive shortcuts: the halo effect (one strong impression colors everything), affinity bias (favoring people who look, sound, or think like them), and confirmation bias (seeking evidence that supports a first impression). These biases are not signs of bad intent — they are features of human cognition that require systematic countermeasures.

2. **Inconsistency.** When every interviewer asks different questions, candidate comparisons become meaningless. Daniel Kahneman's research on "noise" (2021) shows that unwanted variability in human judgment is at least as damaging as bias — and far more common. Two equally qualified interviewers, evaluating the same candidate on the same day, routinely arrive at different conclusions when no structure is imposed.

3. **Legal risk.** Unstructured interviews create compliance exposure. When questions are improvised, interviewers may inadvertently ask about protected characteristics — marital status, family plans, health, political views. In the Italian and EU legal context, such questions breach anti-discrimination and data protection law (Section 6) and can result in administrative fines, civil liability, and reputational damage.

### Our Approach: AI-Assisted, Human-Decided

This plugin implements a clear division of labor:

- **The AI prepares.** It generates job descriptions, screening questionnaires, interview questions, scoring rubrics, and evaluation templates — all grounded in research-backed frameworks and validated against compliance requirements.
- **Humans judge.** Every hiring decision is made by people. Interviewers assign every competency score from their own evidence; the AI computes the weighted total, proposes a seniority level and a recommendation category from those scores, and the interviewer reviews and may override them with documented justification. Screening signals and thresholds are suggestions too: a person reviews every Hold or Reject. It provides the structure; the interviewer provides the assessment.

This is not automation of hiring. It is augmentation of the hiring process — removing the mechanical burden of creating compliant, structured documents so that interviewers can focus their cognitive energy where it matters most: listening, probing, and evaluating.

### The Value Proposition

| Dimension | Without Plugin | With Plugin |
|-----------|---------------|-------------|
| **Quality** | Variable question quality; inconsistent evaluation criteria | Research-backed questions; BARS-anchored scoring; competency-mapped evaluation |
| **Compliance** | Depends on individual interviewer awareness | Built-in validation at every stage; Italian/EU law checked automatically |
| **Consistency** | Different process per interviewer | Standardized pipeline; same rubric for every candidate |
| **Time** | Hours drafting JDs, questions, and evaluation forms | Minutes to generate; human review and customization |
| **Training** | Requires extensive interviewer training | Built-in guidance; self-teaching through hr-help skill |

---

## 2. Theoretical Foundations

This section presents the research and frameworks that underpin the plugin's design. Each concept is linked to its practical application within the workflow.

### 2.1 McClelland's Competency Model (1973)

David McClelland's seminal paper "Testing for Competence Rather Than Intelligence" argued that traditional academic credentials and intelligence tests are poor predictors of job performance. What predicts performance is **competence** — the combination of knowledge, skills, and behaviors that a person actually demonstrates in the workplace.

**Key insight:** Define roles by what people need to *do*, not by what degrees they hold.

**Application in the plugin:**
- The **job-description** skill uses a competency-based framework for technical roles, identifying 4-6 core competencies with proficiency levels (foundational, intermediate, advanced, expert) and behavioral indicators.
- Non-technical roles use an outcome-based framework (action + object + purpose) that focuses on results rather than credentials.
- The **interview-prep** skill maps interview questions to specific competencies, ensuring every question targets an observable, job-relevant behavior.

### 2.2 Schmidt & Hunter Meta-Analysis (1998)

Frank Schmidt and John Hunter's meta-analysis "The Validity and Utility of Selection Methods in Personnel Psychology" is the most comprehensive study of hiring method effectiveness. After analyzing 85 years of research across hundreds of studies, they ranked selection methods by predictive validity — how well each method predicts actual on-the-job performance.

**Key findings:**

| Method | Predictive Validity |
|--------|-------------------|
| Work sample tests | 0.54 |
| **Structured interviews** | **0.51** |
| General mental ability tests | 0.51 |
| Unstructured interviews | 0.38 |
| Reference checks | 0.26 |
| Years of experience | 0.18 |
| Years of education | 0.10 |

**Key insight:** Structured interviews are among the most effective selection tools — and significantly more predictive than unstructured interviews, reference checks, or years of experience. The 36% improvement in quality-of-hire comes from applying consistent questions, consistent scoring, and evidence-based evaluation.

**Application in the plugin:**
- The entire pipeline is built around structured interviewing: standardized questions (interview-prep), standardized scoring (BARS rubric), and standardized evaluation (interview-close).
- Pre-screening uses a consistent five-category framework with a 12-question maximum.
- Every skill produces structured output that other skills can consume, maintaining consistency across the pipeline.

### 2.3 The STAR Method

STAR (Situation, Task, Action, Result) is the standard framework for behavioral interviewing. It structures both the questions the interviewer asks and the responses the candidate gives.

| Component | Weight | Purpose |
|-----------|--------|---------|
| **Situation** | ~20% | Context: who, where, when, scale of challenge |
| **Task** | ~10% | The candidate's specific responsibility |
| **Action** | ~60% | What the candidate actually did — decisions, trade-offs, skills applied |
| **Result** | ~10% | Outcome and impact — quantified where possible, with lessons learned |

The Action component receives the most weight because it contains the competency evidence. A candidate who describes a situation and result but glosses over their specific actions has not demonstrated competence — they have described a project they were near.

**Key insight:** Past behavior is the best predictor of future behavior. Asking "Tell me about a time when..." produces evidence-based responses. Asking "What would you do if..." produces rehearsed hypotheticals.

**Application in the plugin:**
- The **interview-prep** skill generates STAR-method behavioral questions customized to each candidate's competency profile, with follow-up probes for when answers are vague on Action or cannot quantify Result.
- The **interview-close** skill evaluates responses against STAR completeness, prompting interviewers for specific behavioral evidence when they provide vague impressions.

### 2.4 BARS — Behaviorally Anchored Rating Scales

BARS ties every point on a numeric rating scale to an observable behavioral description. Instead of asking "Rate the candidate 1-5 on leadership" (which means different things to different interviewers), BARS defines what each level looks like.

The plugin uses **one absolute 1–5 scale**, defined in a single place: [the interview-close evaluation template, Section 3](skills/interview-close/references/evaluation-template.md). It runs from 1 = no competence shown to 5 = sets direction for others, and adds **Not assessed** for a competency with no evidence (left out of the weighted total, never scored as a 1). The anchors are the same for every role; the seniority matrix says which score each level is expected to reach, which is what lets it classify seniority.

**Key insight:** Without behavioral anchors, a "3" means "average" to one interviewer and "acceptable" to another. BARS eliminates this ambiguity and improves inter-rater reliability — different interviewers scoring the same answer arrive at the same number because the number is defined by behavior, not feeling.

**Application in the plugin:**
- The **interview-close** skill uses the scale for all competency scoring, requiring cited evidence for every score assigned.
- The scoring rubric is loaded during interview-prep so interviewers can calibrate before the interview; each question's good and excellent answer examples are set at the expected score for the target level and one point above it.
- Bias detection in interview-close monitors for low differentiation (near-identical scores across competencies) and prompts the interviewer to revisit their evidence.

### 2.5 Kahneman's "Noise" (2021)

Daniel Kahneman, Olivier Sibony, and Cass Sunstein's book *Noise: A Flaw in Human Judgment* distinguishes between **bias** (a systematic deviation in one direction) and **noise** (unwanted variability in judgments). Their research demonstrates that noise is often a larger problem than bias in organizational decision-making — and that people are largely unaware of it.

In hiring, noise manifests as: two interviewers scoring the same candidate differently for no systematic reason; the same interviewer scoring differently depending on the time of day, their mood, or who they interviewed before (the contrast effect).

**Key insight:** Standardization is the primary defense against noise. When every interviewer uses the same questions, the same rubric, and the same scoring framework, the variability in judgments decreases — not because individuality is suppressed, but because irrelevant variation is removed.

**Application in the plugin:**
- The standardized pipeline (the same base screening questions and competency framework, the same rubric, the same evaluation template and seniority matrix for every candidate for a role) directly implements Kahneman's prescription.
- The compliance-check skill validates that documents are consistent across candidates.
- The interview-close skill's bias detection includes checks for contrast effect and recency bias — both forms of noise.

### 2.6 Textio 5Cs — Inclusive Language Framework

Textio's research on job posting language identifies five principles for writing inclusive, high-performing job descriptions — the "5Cs":

| Principle | Meaning |
|-----------|---------|
| **Clarity** | Simple, direct language; no jargon or insider terms |
| **Conciseness** | Target 700 words or fewer; longer posts reduce applicant diversity |
| **Competency focus** | Define roles by competencies, not credentials or years of experience |
| **Culture signaling** | Show what working here is like with concrete details, not buzzwords |
| **Compliance** | Gender-neutral language, equal opportunity statements, reasonable accommodations |

Research by Textio and others (including the frequently cited HP internal study) shows that women tend to apply only when they meet 100% of listed requirements, while men typically apply at 60%. This means that **requirements inflation** — listing many more required qualifications than the role needs — disproportionately reduces female applicants, not because women are less qualified, but because the signaling effect of excessive requirements differs by gender. The plugin uses about 8 required items as a rule of thumb, not a research threshold.

**Application in the plugin:**
- The **job-description** skill flags more than 8 required qualifications (a rule of thumb) and explains why.
- Inclusive language checking scans for gendered, ageist, ableist, and exclusionary phrasing — with automatic replacements and a summary of changes.
- The 5Cs are applied as a quality checklist during JD generation.

---

## 3. The Workflow Pipeline

### 3.1 Pipeline Overview

The plugin implements a loosely coupled pipeline of six skills. Four skills form the main workflow sequence; two skills operate as cross-cutting services available at any stage.

```
                           THE HR INTERVIEW WORKFLOW
 ┌─────────────────────────────────────────────────────────────────────┐
 │                                                                     │
 │   ┌─────────────┐    ┌───────────────┐    ┌───────────────┐        │
 │   │     job-     │    │     pre-      │    │   interview-  │        │
 │   │ description  │───>│  screening    │───>│     prep      │──┐     │
 │   │             │    │               │    │               │  │     │
 │   └──────┬──────┘    └───────┬───────┘    └───────┬───────┘  │     │
 │          │                   │                    │          │     │
 │          │    Output:        │    Output:         │  Output: │     │
 │          │    {role}-job-    │    {candidate}-    │  - position    │
 │          │    description.md │    prescreening*   │    assessment  │
 │          │                   │                    │  - questions   │
 │          │                   │                    │  - notes       │
 │          │                   │                    │  template │     │
 │          │                   │                    │          │     │
 │          │                   │                    │     [ INTERVIEW ]
 │          │                   │                    │     [ HAPPENS  ]
 │          │                   │                    │     [ HERE     ]
 │          │                   │                    │          │     │
 │          │                   │                    │          v     │
 │          │                   │                    │  ┌─────────────┐│
 │          │                   │                    │  │  interview- ││
 │          │                   │                    └─>│    close    ││
 │          │                   │                       │             ││
 │          │                   │                       └──────┬──────┘│
 │          │                   │                              │      │
 │          │                   │                     Output:  │      │
 │          │                   │                     {candidate}-    │
 │          │                   │                     evaluation-*.md │
 │  ........│...................│..............................│......│
 │  :       v                   v                              v     :│
 │  :  ┌─────────────────────────────────────────────────────────┐   :│
 │  :  │              compliance-check                           │   :│
 │  :  │       (validation layer — embedded at every stage)      │   :│
 │  :  └─────────────────────────────────────────────────────────┘   :│
 │  :                                                                :│
 │  :  ┌─────────────────────────────────────────────────────────┐   :│
 │  :  │              hr-help                                    │   :│
 │  :  │       (guidance layer — available anytime)               │   :│
 │  :  └─────────────────────────────────────────────────────────┘   :│
 │  :................................................................:│
 │                                                                     │
 └─────────────────────────────────────────────────────────────────────┘
```

**Data flow summary:**

```
job-description ──JD──> pre-screening ──JD + CV gap analysis──> interview-prep
                                                                      │
                                        interview questions + rubric + │
                                        notes template                 │
                                                                      v
                                              interviewer notes ──> interview-close
                                                                      │
                                                                      v
                                              one evaluation per interviewer
                                              (+ optional panel consolidation)
```

### 3.2 Stage-by-Stage Explanation

---

#### Stage 1: Job Description

| Aspect | Detail |
|--------|--------|
| **WHEN** | At the start of the hiring process, when a new position needs to be defined and its job posting written. To revise an existing posting, audit it with compliance-check in standalone mode, which can also write a corrected version. |
| **WHO** | HR professional, hiring manager, or recruiter. |
| **WHAT it produces** | `{role}-job-description.md` — a professional job description with competency framework, inclusive language, and compliance validation. |
| **WHY this step matters** | The JD is the foundation. Everything downstream — screening criteria, interview questions, evaluation rubrics — derives from the role definition. A weak JD produces a weak pipeline. |

**Key design decisions:**
- **Dual framework approach.** Technical roles use a competency-based framework (4-6 competencies with proficiency levels L1-L4). Non-technical roles use an outcome-based framework (action + object + purpose). Hybrid roles use both. This prevents the common mistake of forcing non-technical roles into a competency mold or technical roles into vague outcome language.
- **Requirements inflation guard.** More than 8 required qualifications (a rule of thumb) triggers a recommendation to move the extra items to "Preferred."
- **Pay range.** The skill asks for the pay range; in EU jurisdictions a JD without one gets a compliance WARNING, because the Pay Transparency Directive requires it before the interview.
- **Built-in inclusive language check.** Scans for gendered, ageist, ableist, and exclusionary language against the Textio 5Cs framework. Applies replacements and presents a change summary.
- **Compliance validation.** Invokes compliance-check in embedded mode as the last step before output. Critical findings must be resolved; warnings are presented to the user.

---

#### Stage 2: Pre-Screening

| Aspect | Detail |
|--------|--------|
| **WHEN** | After a JD exists and candidate applications begin arriving. Used to filter candidates before investing in a full interview. |
| **WHO** | Recruiter or HR coordinator conducting initial candidate outreach. |
| **WHAT it produces** | A structured questionnaire in either async mode (`{candidate}-prescreening.md`, sent to the candidate, plus a separate recruiter guide `{candidate}-prescreening-guide.md`) or live mode (`{candidate}-prescreening-script.md`, the interviewer script for phone/video screening). The role-level base questions are kept in `{role}-prescreening-base.md`. |
| **WHY this step matters** | Pre-screening bridges the gap between a paper application and a full interview. The CV-vs-JD gap analysis identifies what needs clarification, so the screening targets the right areas instead of asking generic questions. |

**Key design decisions:**
- **CV-JD gap analysis.** Before generating questions, the skill maps every JD requirement to the candidate's CV evidence, classifying each as match, partial match, gap, or unclear. Experience questions are then targeted at the requirements the CV does not show. A "gap" is always a missing requirement, never a period without work: CV gaps are never analyzed, rated or used to screen anyone out, because they stand in for pregnancy, illness, disability and caregiving. At most one optional, open career-path question is asked, the same for everyone.
- **Role-level base set.** Logistics, motivation, competency probe and candidate-question categories are written once per role to `{role}-prescreening-base.md` and reused, so every candidate for the role gets the same base questions. Only the experience-alignment questions vary with the CV.
- **Two delivery modes.** Async mode produces a formal, self-paced questionnaire. Live mode produces a conversational interviewer script with follow-up probes, timing cues, and green/red flag indicators. The mode is selected per use case, not hardcoded.
- **12-question maximum.** Distributed across five categories: logistics (2-4), experience alignment (3-5), motivation (1-2), competency probe (2-3), and candidate questions (1). This prevents screening fatigue while ensuring coverage.
- **Evaluation guidance.** The async mode writes a recruiter-only evaluation guide, in a separate file from the questionnaire sent to the candidate, with green/yellow/red indicators for each question — so the recruiter knows what good looks like, not just what to ask. Salary is compared only with the band maximum and availability only with the hiring timeline. The indicators and the suggested threshold are suggestions: a person reviews every Hold or Reject.
- **Privacy.** The async questionnaire carries the privacy notice, and the live script opens with a privacy line.

---

#### Stage 3: Interview Prep

| Aspect | Detail |
|--------|--------|
| **WHEN** | After pre-screening is complete (or when a candidate goes directly to interview). Used to prepare the interviewer before the interview happens. |
| **WHO** | Technical interviewer, department evaluator, or hiring manager — someone with domain expertise who needs structured preparation. |
| **WHAT it produces** | Three files: (1) `{candidate}-position-assessment.md` — the interviewer's private briefing on candidate fit; (2) `{candidate}-interview-questions.md` — 4-6 STAR-method behavioral questions with rationale, answer examples, and follow-up probes; (3) `{candidate}-interview-notes.md` — a minimal template for capturing impressions during the interview. |
| **WHY this step matters** | An unprepared interviewer defaults to gut-feel questioning. Interview-prep gives them a competency map, targeted questions, and calibrated expectations — so they walk into the room knowing what to look for and how to score it. |

**Key design decisions:**
- **Deep CV-JD competency analysis.** Goes beyond the pre-screening gap analysis to set the expected score per competency for the target level (from the role's saved seniority matrix when one exists) and map CV evidence to strengths, gaps, and to-investigate areas. CV gaps and career breaks are never listed as risks.
- **STAR-method question generation.** Every question follows behavioral interviewing best practices. Each question includes a rationale (why this question for this candidate), a good answer example (at the expected score for the target level), an excellent answer example (one point above it), red flags, and follow-up probes.
- **Question allocation strategy.** One primary question per competency, with the competencies chosen deliberately: 1-2 strengths (confirm depth), 2-3 gaps (investigate fairly), 1-2 unclear areas (clarify ambiguity). This ensures the interview focuses where it adds the most information.
- **Minimal notes template.** Deliberately simple: free-text area, two practical tips, a quick score grid (with Not assessed), and one closing question ("Which competency needs more evidence before a decision?"). Complex note-taking forms distract interviewers from listening, and a "would you want them on your team?" question invites similarity bias.
- **Redundancy check.** If pre-screening results are available, the skill avoids duplicating previously asked questions, instead designing deeper follow-ups on areas where pre-screening answers were partial or flagged. The compliance check runs after it, on the final text.

---

#### Stage 4: Interview Close

| Aspect | Detail |
|--------|--------|
| **WHEN** | After the interview is conducted. The interviewer has notes (ideally using the template from interview-prep). |
| **WHO** | The interviewer (or each panel member individually), guided by the skill through a structured feedback conversation. |
| **WHAT it produces** | `{candidate}-evaluation-{interviewer}.md` — one evaluation per interviewer, with competencies scored on the canonical scale, evidence citations, the computation tables, seniority classification, and a proposed recommendation the interviewer confirms. Optionally `{candidate}-evaluation-consolidated.md` for a panel, and `{role}-seniority-matrix.md`, the confirmed matrix reused for every candidate for the role. |
| **WHY this step matters** | The evaluation is the terminal artifact of the pipeline — it is what hiring decisions are based on. Without structured evaluation, interviewers write vague paragraphs ("strong candidate, good culture fit") that are not comparable across candidates and not defensible under scrutiny. |

**Key design decisions:**
- **Guided feedback interaction.** Rather than accepting a simple scorecard, the skill probes each competency through a structured conversation: observation prompt, depth probe, vague-to-evidence conversion, anchor check, and score assignment. A competency with no evidence is recorded as Not assessed: it is left out of the weighted total, lowers the confidence, and never forces a No Hire. This coaching approach converts raw impressions into evidence-backed evaluations.
- **Bias detection.** Monitors for common cognitive biases during the evaluation: halo/horns effect, recency bias, similarity bias, contrast effect, and confirmation bias. Flags patterns with a respectful, constructive tone — the goal is awareness, not accusation.
- **Seniority classification.** Maps candidate scores against the role's seniority matrix (saved from an earlier evaluation, corporate, or generated and confirmed) using a weighted distance algorithm. The classification includes a confidence level (High/Medium/Low) and a rationale referencing key competencies.
- **Evidence-backed recommendation.** The proposed recommendation (Strong Hire / Hire / No Hire / Strong No Hire) compares the scores with the expected scores for the target level and is justified with specific competency scores and observations. Only a documented conduct concern (dishonesty, hostility, discriminatory remarks) overrides the scores; culture fit never does. The interviewer confirms or overrides the recommendation.
- **One file per interviewer.** Panel members never overwrite each other's evaluation. An optional consolidation step compares their scores and resolves divergences through an evidence review.
- **Candidate data.** Candidate files start with a confidentiality and retention line, belong in a folder outside version control, and are never copied into memory.

---

#### Cross-Cutting: Compliance Check

| Aspect | Detail |
|--------|--------|
| **WHEN** | Invoked by every pipeline stage as its last step before output (embedded mode), after every other change to the draft. Also available as a standalone audit tool at any time, including to revise an existing JD. |
| **WHO** | In embedded mode: transparent to the user, runs as part of the pipeline. In standalone mode: HR professional, legal/compliance team, or anyone reviewing an existing HR document. |
| **WHAT it produces** | Embedded: a list of findings (severity + location + suggested fix) returned to the calling skill. Standalone: a compliance audit report saved to the output directory. |
| **WHY this step matters** | Compliance errors are expensive — legally, financially, and reputationally. By validating at every stage, the plugin catches issues when they are cheap to fix (draft stage) rather than after a document is sent to candidates or used in an interview. |

**Four analysis layers:**
1. **Prohibited topics detection** — flags direct and indirect references to protected categories
2. **Biased language detection** — gendered, ageist, ableist, or exclusionary phrasing
3. **GDPR data handling** — data minimization, transparency, retention, special category data risks
4. **Structural compliance** — document-type-specific rules (e.g., equal opportunity statements in JDs, scoring rubrics in evaluations)

---

#### Cross-Cutting: HR Help

| Aspect | Detail |
|--------|--------|
| **WHEN** | Anytime. When a user needs guidance on which skill to use, how the pipeline works, or what HR best practices apply. |
| **WHO** | Anyone interacting with the plugin — from first-time users to experienced HR professionals. |
| **WHAT it produces** | Conversational guidance. No file output. |
| **WHY this step matters** | The plugin is self-teaching. Rather than requiring users to read documentation or attend training, hr-help adapts to the user's expertise level and provides contextual guidance. |

**Adaptive interaction model:**
- **Expert** — direct, concise answers; references frameworks by name
- **Practitioner** — step-by-step guidance with light methodology
- **Newcomer** — Socratic coaching with examples and definitions

---

## 4. Design Rationale — Key Decisions

### 4.1 Loosely Pipelined Architecture

The six skills are independent but composable. Each skill can operate standalone with manual input, and each produces richer output when upstream artifacts are available.

**Why this matters:**

- **Partial adoption.** An organization can adopt the job-description skill without committing to the full pipeline. A hiring manager who already has a JD can start at pre-screening. An interviewer who does not use the plugin for preparation can still use interview-close for structured evaluation. This lowers the barrier to adoption — teams can enter the pipeline at any point.
- **Resilience.** If one stage's output is unavailable (the JD was written externally, the pre-screening was done by a different team), the next stage degrades gracefully rather than failing. Skills ask the user for missing input and proceed with what they have.
- **Incremental improvement.** The loosely coupled design means that each skill can be updated, replaced, or extended independently. Improving the compliance-check rules does not require changing the job-description skill.

The pipeline is a recommendation, not a requirement. The skills are designed to be most powerful in sequence, but they earn their value individually.

### 4.2 Compliance as Cross-Cutting Concern

The compliance-check skill is not just another step in the pipeline — it is a cross-cutting concern that operates in two fundamentally different modes:

- **Embedded mode:** Invoked by every other skill as the last step before producing output, through the Skill tool with the arguments `embedded <document_type>`. The calling skill passes its draft text, receives a list of findings (CRITICAL, WARNING or INFO), and applies fixes based on severity. Running last means the checked text is the text that is written.
- **Standalone mode:** Invoked directly by the user to audit any existing HR document. Produces a full compliance report with findings, severity levels, legal citations, and suggested fixes.

**Why dual-use?** Because compliance is not something you do once at the end — it is a constraint that must be satisfied at every stage. A job description with discriminatory language pollutes the entire downstream pipeline: the screening questions inherit the bias, the interview questions reinforce it, and the evaluation perpetuates it. By validating at every stage, issues are caught where they originate.

The standalone mode exists because many organizations already have HR documents that predate the plugin. Auditing existing materials is as important as generating new ones correctly.

### 4.3 Language Detection Over Selection

The plugin auto-detects language from the conversation and input documents rather than asking the user to select a language. When the user writes in Italian, the output is in Italian. When they write in English, the output is in English.

**Why detection over selection?**

- **Natural interaction.** Forcing a language choice adds friction and breaks conversational flow. In a bilingual workplace (common in Italian companies with international operations), the user may switch languages naturally — the plugin follows.
- **Document-aware.** When a JD is provided in Italian and the user writes in English, the skill detects the dominant language and asks for confirmation rather than guessing. This handles the common case where an Italian document is being discussed in English.
- **Judgment-based.** When one language clearly dominates, it is selected automatically; when the inputs clearly mix languages, the dominant language is recommended for confirmation; when none dominates, the user chooses. This avoids both over-confidence and over-asking.

### 4.4 Corporate Context with Memory

Every skill checks conversation memory for previously stored corporate context — company name, evaluation templates, compensation bands, equal opportunity statements, brand guidelines. When the user provides new information, it is saved for future sessions. Role-level artifacts that must be identical across candidates — the seniority matrix and the pre-screening base set — are kept as files in the output folder instead.

**Candidate data is never saved to memory.** Names, CV content, answers, notes, scores and evaluations stay in the candidate files, which carry a confidentiality and retention line and belong in a folder outside version control.

**The freshness heuristic:**

- **Durable context** (company name, industry, brand voice, equal opportunity statement) is saved indefinitely and applied across sessions. These change rarely.
- **Stale context** (salary bands, specific templates, hiring policies) should be confirmed periodically. The plugin applies saved context but remains receptive to updates.

**Why ask-once-remember?** HR professionals interact with the plugin repeatedly — for every new position, every new candidate. Asking for the company's equal opportunity statement every time would be unacceptable. Memory transforms the plugin from a stateless tool into a context-aware assistant that learns the organization's standards and applies them automatically.

### 4.5 Evidence-Backed Evaluation

A core design principle runs through every evaluation artifact: **every score must be backed by cited evidence.** No number stands alone.

This means:
- In interview-close, every competency score requires a specific candidate statement or observed behavior as justification.
- In compliance-check, every finding must cite a specific law, GDPR article, or named best practice. Findings without citations are discarded.
- In pre-screening evaluation guidance, every green/yellow/red indicator describes what specific signals to look for.

**Why this matters for bias reduction:** When interviewers must cite evidence for their scores, they cannot rely on "gut feel" or "culture fit" — they must point to something the candidate said or did. This constraint does not eliminate bias, but it makes bias visible. A biased score becomes harder to defend when the evidence field is empty or contradicts the number.

### 4.6 Interview Notes Philosophy

The interview-notes template produced by interview-prep is deliberately minimal: a free-text area, two practical tips, a quick score grid, and one closing question about which competency needs more evidence.

**Why minimal templates outperform complex forms:**

Complex note-taking forms — with checkboxes per competency, rating scales during the interview, and mandatory fields — distract interviewers from their primary job: listening. An interviewer filling out a form is not making eye contact, is not catching nuances, and is not formulating follow-up questions.

The minimal template captures signal: what the candidate said (free text), what surprised the interviewer (starred moments), and a quick post-interview score grid. The detailed, evidence-backed evaluation happens afterward in the interview-close stage, when the interviewer can reflect without time pressure.

This is a deliberate trade-off: less structure during the interview for more thoughtful structure after it.

### 4.7 Guided Feedback Interaction

The interview-close skill does not simply accept a scorecard. It guides the interviewer through a structured feedback conversation:

1. **Observation prompt** — "For [Competency], what specific examples or behaviors did the candidate demonstrate?"
2. **Depth probe** — "Can you describe a particular answer or moment that stood out?"
3. **Vague-to-evidence conversion** — When the interviewer says "seemed senior" or "good communicator," the skill probes for the specific behavior that created that impression. "Culture fit", demeanor and body language are steered back to job-relevant behavior.
4. **Anchor check** — "Which of these two anchors matches the evidence better?" The expected score for the target level is looked at only after scoring.
5. **Score assignment** — a score on the 1-5 scale, or Not assessed when the area was not covered.

**Why coaching interviewers matters:** Most interviewers are domain experts, not assessment professionals. They know what good engineering or good marketing looks like, but they may not know how to articulate it in a structured, comparable way. The guided interaction converts intuitive expertise into documented evidence — without requiring the interviewer to have formal assessment training.

This is also where bias detection operates: monitoring for low differentiation, halo/horns patterns, recency bias, and other cognitive shortcuts. The coaching approach makes bias awareness a natural part of the conversation, not a separate training module.

---

## 5. Usage Scenarios

### Scenario A: Full Pipeline — New Position from Scratch

**Context:** An Italian tech company needs to hire a Senior Backend Engineer. No existing JD.

**Step-by-step walkthrough:**

1. **Invoke job-description.** The recruiter describes the role: "Senior backend engineer, remote, reporting to the Engineering Manager, full-time." The skill asks about competencies, department context, and benefits. It selects the competency-based framework and identifies 5 core competencies (e.g., System Design at L3, API Design at L3, Testing at L2, Python at L3, Collaboration at L2). The draft is generated in Italian, checked for inclusive language, validated against compliance-check. Output: `senior-backend-engineer-job-description.md`.

2. **Invoke pre-screening** with the JD and a candidate's CV. The skill performs a CV-JD gap analysis, identifying matches (Python, API Design), gaps (limited system design evidence), and unknowns (availability, salary expectations). The recruiter selects live mode. Output: `candidate-a-prescreening-script.md` — a 12-question phone screening script with follow-up probes and green/red flags — and `senior-backend-engineer-prescreening-base.md`, the base questions reused for the next candidates.

3. **Conduct the phone screening** using the live script. The recruiter completes the interviewer assessment section.

4. **Invoke interview-prep** with the JD, CV, and pre-screening results. The skill performs a deep competency analysis, identifies that system design is the key area to investigate (pre-screening answer was partial), and generates 5 STAR questions. The system design question gets the most time allocation. Output: three files — position assessment, interview questions, and notes template.

5. **Conduct the interview** using the question plan. The interviewer uses the minimal notes template, capturing key quotes and starring a particularly strong answer about API versioning.

6. **Invoke interview-close** with the JD, the interview-prep outputs and the interviewer's notes. The skill guides the interviewer through a competency-by-competency evaluation. For system design, the interviewer initially says "they were okay" — the skill probes for specific evidence, and the interviewer recalls a detailed example about designing a message queue architecture. Final score: 4, once the example is matched to the "advanced" anchor. Testing was never asked for lack of time, so it is Not assessed: left out of the total, with a follow-up question suggested. The skill classifies the candidate at the Senior level with Low confidence (one competency not assessed) and computes "Hire", which the interviewer confirms. Output: `candidate-a-evaluation-interviewer-1.md` and the confirmed `senior-backend-engineer-seniority-matrix.md`.

---

### Scenario B: Mid-Stream — JD Already Exists

**Context:** A company has a JD for a Marketing Manager that was written externally. They want to screen three candidates.

**Step-by-step walkthrough:**

1. **Skip job-description.** The user provides the existing JD directly.

2. **(Optional) Invoke compliance-check in standalone mode** to audit the existing JD. The skill identifies two warnings: "young and dynamic team" (ageist language) and no equal opportunity statement. The user updates the JD with the suggested fixes.

3. **Invoke pre-screening** three times — once per candidate, each time with the JD and the candidate's CV. The first run writes the role's base questions; the other two reuse them, and only the experience-alignment questions change with each CV. The recruiter selects async mode for all three.

4. **Invoke interview-prep** for the two candidates who pass screening. The skill reuses the same JD competency framework but produces candidate-specific questions based on each individual's CV and pre-screening results.

5. **Continue with interview and interview-close** as in Scenario A.

**Key point:** The pipeline adapts to mid-stream entry. Pre-screening does not require a plugin-generated JD — it accepts any JD. The output quality is the same; the only difference is that the compliance status of the JD depends on whether it was validated.

---

### Scenario C: Standalone Compliance Audit

**Context:** A company's legal team wants to review their standard interview questionnaire for compliance before a regulatory review.

**Step-by-step walkthrough:**

1. **Invoke compliance-check in standalone mode.** The user provides the interview questionnaire (paste or file path).

2. The skill classifies the document as an interview script and detects Italian language, setting jurisdiction to Italy.

3. **Layer 1 (Prohibited Topics):** Flags a question "In che anno ti sei laureato?" (What year did you graduate?) as a WARNING — age proxy through graduation year. Suggests replacement: "Possiedi la laurea in [disciplina]?" (Do you hold a degree in [discipline]?).

4. **Layer 2 (Biased Language):** Flags "Il candidato ideale è un leader nato" (The ideal candidate is a born leader) as INFO — gendered language ("nato" is masculine). Suggests: "La persona ideale dimostra capacità di leadership."

5. **Layer 3 (GDPR):** Flags the absence of a privacy notice reference. Severity: WARNING.

6. **Layer 4 (Structural):** Notes that no scoring rubric is referenced. Severity: WARNING.

7. Output: `interview-questionnaire-compliance-audit.md` with all findings, legal citations, and suggested fixes. Overall status: Pass with warnings.

**Key point:** This scenario uses only one skill. The user does not need to adopt the full pipeline to get value from compliance validation.

---

### Scenario D: Multiple Candidates — Reuse JD and Questions

**Context:** A startup is hiring for the same role (Product Designer) across three candidates who are all interviewing this week.

**Step-by-step walkthrough:**

1. **Invoke job-description** once. Output: `product-designer-job-description.md`.

2. **Invoke pre-screening** three times (one per candidate). The base questions are the same for all three; only the experience-alignment questions target each candidate's CV.

3. **Invoke interview-prep** three times. Each produces a candidate-specific position assessment, question set, and notes template. While the competency framework is consistent (ensuring fair comparison), the specific questions adapt to each candidate's profile.

4. **Conduct three interviews** using the respective prep kits.

5. **Invoke interview-close** for each interviewer of each candidate. The seniority matrix is confirmed during the first evaluation, saved as `product-designer-seniority-matrix.md`, and reused (consistency rule) for the rest. All evaluations use the same absolute scale, the same competency weights, and the same matrix — making them directly comparable.

**Key point:** The plugin maintains consistency (same base screening questions, same framework, same rubric, same matrix) while adapting to individual candidates (experience questions and interview questions targeted at each CV). This is the core promise of structured interviewing — fair comparison through standardized process.

---

### Scenario E: Non-Technical Role

**Context:** An Italian company needs to hire an Office Manager.

**Step-by-step walkthrough:**

1. **Invoke job-description.** The skill identifies this as a non-technical role and selects the outcome-based framework. Instead of competencies with proficiency levels, it frames responsibilities as outcomes: "Coordinare le attività di accoglienza e gestione degli spazi per garantire un ambiente di lavoro funzionale e accogliente" (Coordinate reception activities and space management to ensure a functional and welcoming work environment). Success metrics are defined (response time, stakeholder satisfaction score).

2. **Invoke pre-screening.** The CV-JD gap analysis focuses on outcome-relevant experience. The motivation category gets 2 questions, because interest in an in-person, service-oriented role is one of the JD's requirements.

3. **Invoke interview-prep.** The STAR questions adapt to non-technical competencies. Instead of "Tell me about a system you designed," the questions target interpersonal scenarios: "Mi racconti un'occasione in cui ha dovuto gestire richieste contrastanti da parte di diversi colleghi. Come ha stabilito le priorità?" (Tell me about a time when you had to manage conflicting requests from different colleagues. How did you prioritize?). Answer examples reference office management contexts, not engineering.

4. **Invoke interview-close.** The seniority matrix is built from the outcome-based JD. Competencies might include: Stakeholder Management, Administrative Organization, Problem Resolution, Communication. The same absolute anchors apply; the evidence comes from the office context.

**Key point:** The pipeline adapts its framework, language, and examples to non-technical roles without requiring the user to configure anything. The selection is automatic based on role type analysis.

---

## 6. Legal & Compliance Framework

### 6.1 Italian Labor Law Summary

> Not legal advice. The legal content of this plugin comes from reviewer analysis, not from counsel; verify it with counsel before relying on it.

Which statute covers which protected ground is recorded in one place, [the compliance-check legal map](skills/compliance-check/references/legal-map.md): race and ethnic origin, religion or belief, disability, age, sexual orientation, sex and gender (including marital and family status and pregnancy), political opinion and trade-union membership, nationality, and targeted disability hiring. The article-level detail is in [the Italian labor law reference](skills/compliance-check/references/italian-labor-law.md), with its enforcement and penalty tables.

**Article 8 of the Workers' Statute (L. 300/1970)** establishes the fundamental **relevance test**: it is forbidden for the employer to investigate a worker's political opinions, religious beliefs, or trade union membership — or any facts not relevant to assessing professional aptitude.

**Pay transparency.** EU Directive 2023/970 requires the pay range to reach applicants before the interview, bans questions about current or past pay, and requires gender-neutral vacancy notices. Its transposition deadline was 7 June 2026; check the current national transposition status. In the plugin, a pay-history question is CRITICAL and a JD without a pay range is a WARNING in EU jurisdictions.

**AI-assisted screening.** A decision based solely on automated processing is restricted by GDPR Art. 22, and the AI Act classifies AI systems used to filter or evaluate candidates as high-risk, which requires human oversight and disclosure. The plugin drafts and suggests; people decide, and the privacy-notice template includes a disclosure line.

### 6.2 EU / GDPR Requirements for Candidate Data

The **General Data Protection Regulation (Regulation 2016/679)** applies to all candidate data processing. Key principles:

| Principle | GDPR Article | Practical Implication |
|-----------|-------------|----------------------|
| **Lawful basis** | Art. 6 | Legitimate interest for standard recruitment; consent for talent pool storage |
| **Transparency** | Art. 12-14 | Candidates must receive a privacy notice before data collection |
| **Data minimization** | Art. 5(1)(c) | Collect only what is necessary for the recruitment decision |
| **Purpose limitation** | Art. 5(1)(b) | Data collected for a vacancy cannot be reused without compatible purpose or fresh consent |
| **Storage limitation** | Art. 5(1)(e) | Unsuccessful candidates: 6-12 months; talent pool: max 24 months with consent |
| **Special category data** | Art. 9 | Processing prohibited for: racial/ethnic origin, political opinions, religious beliefs, trade union membership, health data, sexual orientation |

**Candidate rights:** Access (Art. 15), rectification (Art. 16), erasure (Art. 17), restriction (Art. 18), portability (Art. 20), objection (Art. 21). Response deadline: 30 calendar days.

### 6.3 Prohibited Topics Quick Reference

The full list, with safe alternatives, is in [the compliance-check prohibited topics reference](skills/compliance-check/references/prohibited-topics.md); the statute for each ground is in the legal map.

| Category | Rule |
|----------|------|
| Race / Ethnicity / National Origin | Cannot ask about origin, birthplace, or mother tongue ("madrelingua") |
| Religion / Personal Beliefs | Cannot investigate religious practices or beliefs |
| Age | Cannot ask age, graduation year, or proximity to retirement |
| Sex / Gender / Sexual Orientation | Cannot ask about gender identity or sexual orientation |
| Marital / Family Status | Cannot ask about marriage, children, or childcare |
| Pregnancy | Expressly prohibited — cannot ask current or planned |
| Disability / Health | Cannot ask about disabilities, medications, or sick leave |
| Political Opinions | Expressly forbidden — cannot investigate political views |
| Trade Union Membership | Expressly forbidden — cannot ask about union affiliation |
| Career gaps (proxy) | Cannot ask the reason for a gap or treat it as a risk; at most one optional, open career-path question |
| Pay history (EU) | Cannot ask about current or past pay; state the pay range, then ask for expectations |

### 6.4 Safe Alternatives

| Do NOT Ask | Ask Instead |
|------------|-------------|
| "Where are you originally from?" | "Are you legally authorized to work in Italy?" |
| "What is your mother tongue?" | "Which languages do you speak at a professional level?" |
| "What year did you graduate?" | "Do you hold [specific qualification]?" |
| "Are you married? Do you have children?" | "This role requires [specific schedule]. Can you meet these requirements?" |
| "Are you pregnant or planning to have children?" | *(No alternative needed — omit entirely)* |
| "Do you have any disabilities?" | "Can you perform the essential functions of this role with or without reasonable accommodations?" |
| "Do you observe religious holidays?" | "Are you available to work on [specific dates]?" |
| "Are you a union member?" | *(No alternative needed — omit entirely)* |
| "What are your political views?" | *(No alternative needed — omit entirely)* |
| "How many sick days did you take last year?" | *(No alternative needed — omit entirely)* |
| "What were you doing between [date] and [date]?" | *(Optional, for everyone)* "Is there anything about your career path that your CV does not show and that you would like us to know?" |
| "What is your current salary?" | "The range for this role is [range]. What are your salary expectations?" |

### 6.5 Candidate Rights Under Italian Law

Candidates have strong protections:

1. **Right to refuse** illegal questions without negative consequences in the selection process.
2. **Right to provide false answers** to illegal questions — Italian case law (Cassazione Civile) establishes that a candidate who lies in response to an unlawful question is protected because the employer had no right to ask.
3. **Right to report** discriminatory practices to the Tribunale del Lavoro, the Consigliera di Parità (Equality Adviser), the Garante per la Protezione dei Dati Personali, or the Ispettorato Nazionale del Lavoro.
4. **Shifted burden of proof** — once a candidate establishes facts suggesting discrimination, the employer must prove the treatment was not discriminatory (see the Italian labor law reference, Section 5).

---

## 7. Appendix

### 7.1 Glossary

| Term | Definition |
|------|-----------|
| **BARS** | Behaviorally Anchored Rating Scales — a scoring method that ties each numeric rating to a specific behavioral description, improving consistency and inter-rater reliability. |
| **Behavioral interviewing** | An interviewing approach where questions ask candidates to describe real past experiences, based on the principle that past behavior predicts future performance. |
| **Competency** | A combination of knowledge, skills, and behaviors required for effective job performance. Defined with proficiency levels (L1-L4) in this plugin. |
| **Competency-based framework** | A job description approach that identifies 4-6 core competencies with proficiency levels and behavioral indicators. Used for technical roles. |
| **Embedded mode** | The operating mode where compliance-check is invoked by another skill as a validation step, returning structured findings without producing a file. |
| **Gap analysis** | The process of comparing a candidate's CV against a JD's requirements, classifying each requirement as match, partial match, gap, or unclear. |
| **Halo/Horns effect** | A cognitive bias where a strong (halo) or weak (horns) impression on one competency inflates or deflates scores on all other competencies. |
| **Inter-rater reliability** | The degree to which different interviewers assign the same score to the same candidate response. Higher with BARS and structured scoring. |
| **Noise** | Unwanted variability in human judgment — different people (or the same person at different times) reaching different conclusions from the same evidence. |
| **Outcome-based framework** | A job description approach that frames responsibilities as action + object + purpose with measurable success metrics. Used for non-technical roles. |
| **Predictive validity** | The degree to which a selection method predicts actual job performance. Structured interviews have a predictive validity of 0.51. |
| **Not assessed** | The status of a competency for which the interview collected no evidence. It is left out of the weighted total and lowers the confidence; it is never a score of 1. |
| **Progressive disclosure** | A design pattern where reference documents are loaded only when needed, not all at once, reducing context window consumption. |
| **Requirements inflation** | The practice of listing more required qualifications than the role needs (the plugin's rule of thumb: about 8), which disproportionately discourages applications from underrepresented groups. |
| **Seniority matrix** | A table mapping expected competency scores to seniority levels (Junior, Mid, Senior, Lead/Principal), used for candidate classification in interview-close and saved per role as `{role}-seniority-matrix.md`. |
| **STAR method** | Situation, Task, Action, Result — a framework for structuring behavioral interview questions and evaluating the completeness of candidate responses. |
| **Standalone mode** | The operating mode where compliance-check is invoked directly by the user to audit an existing document, producing a full compliance report. |
| **Structured interview** | An interview where all candidates are asked the same questions in the same order, scored against the same rubric. Predictive validity of 0.51, versus 0.38 for unstructured interviews. |

### 7.2 Scoring Scale — Full Definitions

The anchors are defined once, in [the interview-close evaluation template, Section 3](skills/interview-close/references/evaluation-template.md): 1 = no competence shown, 2 = basic with guidance, 3 = independent, 4 = advanced and guides others, 5 = sets direction for others, plus Not assessed. The same section defines "meets", "exceeds" and "below" the target level; Section 6 of that file gives the recommendation rules.

### 7.3 STAR Method Quick Reference

```
 ┌──────────────────────────────────────────────────────────────┐
 │                     THE STAR METHOD                          │
 │                                                              │
 │   S ─ SITUATION (~20%)                                       │
 │       "Tell me about a time when..."                         │
 │       Listen for: who, where, when, scale of challenge       │
 │                                                              │
 │   T ─ TASK (~10%)                                            │
 │       "What was your specific responsibility?"               │
 │       Listen for: "I was responsible for..."                 │
 │       (distinguishes individual from team contribution)      │
 │                                                              │
 │   A ─ ACTION (~60%)  ← This is where competency lives       │
 │       "What did you actually do?"                            │
 │       Listen for: decisions, trade-offs, skills applied,     │
 │       obstacles overcome, tools and methods used             │
 │                                                              │
 │   R ─ RESULT (~10%)                                          │
 │       "What was the outcome?"                                │
 │       Listen for: metrics, before/after, lessons learned,    │
 │       what they would do differently                         │
 │                                                              │
 │   Follow-up probes:                                          │
 │   • Vague Action → "What was your specific role in that?"    │
 │   • No metrics   → "How did you measure the success?"        │
 │   • "We" answers → "When you say 'we,' what was your part?"  │
 └──────────────────────────────────────────────────────────────┘
```

### 7.4 Bibliography

| Reference | Citation |
|-----------|----------|
| McClelland, D.C. (1973) | "Testing for Competence Rather Than for Intelligence." *American Psychologist*, 28(1), 1-14. Established that competencies predict job performance better than credentials or intelligence tests. |
| Schmidt, F.L. & Hunter, J.E. (1998) | "The Validity and Utility of Selection Methods in Personnel Psychology: Practical and Theoretical Implications of 85 Years of Research Findings." *Psychological Bulletin*, 124(2), 262-274. The definitive meta-analysis on hiring method effectiveness; structured interviews show 0.51 predictive validity vs. 0.38 for unstructured. |
| Kahneman, D., Sibony, O. & Sunstein, C.R. (2021) | *Noise: A Flaw in Human Judgment.* New York: Little, Brown Spark. Demonstrates that unwanted variability (noise) in human judgment is as damaging as bias, and that standardization is the primary defense. |
| Textio (2020-present) | Research on inclusive job posting language and the 5Cs framework (Clarity, Conciseness, Competency focus, Culture signaling, Compliance). See: textio.com/products/recruiting. |
| HP Internal Study (reported widely) | Internal research finding that women apply for jobs only when meeting 100% of listed requirements, while men apply at 60%. Frequently cited in talent acquisition literature on requirements inflation and gender disparity in applicant pools. |
| Italian and EU statutes | Listed, with the ground each covers, in [the compliance-check legal map](skills/compliance-check/references/legal-map.md): D.Lgs. 198/2006, D.Lgs. 215/2003, D.Lgs. 216/2003, L. 300/1970, D.Lgs. 286/1998, L. 68/1999, D.Lgs. 276/2003, D.Lgs. 196/2003. |
| EU Directive 2023/970 | Pay Transparency Directive — pay range before the interview, no pay-history questions, gender-neutral vacancy notices. Check the current national transposition. |
| Regulation (EU) 2024/1689 | AI Act — AI systems used in recruitment and candidate evaluation are high-risk (Annex III, point 4). |
| GDPR — Regulation (EU) 2016/679 | General Data Protection Regulation. Key articles for recruitment: 5 (data principles), 6 (lawful basis), 9 (special category data), 12-14 (transparency), 15-21 (data subject rights), 35 (DPIA), 83 (penalties). |
| EU Directives 2000/43/EC, 2000/78/EC, 2006/54/EC | Racial Equality, Employment Equality and Gender Equality Directives — see the legal map for the grounds each covers. |

---

*This document is part of the Human Resources plugin for Claude Code. For skill-specific implementation details, see the individual SKILL.md files. For interactive guidance, invoke the hr-help skill.*
