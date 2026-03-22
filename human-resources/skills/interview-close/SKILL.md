---
name: interview-close
description: "Produce standardized post-interview evaluations with competency scoring, seniority classification, and hiring recommendations. Guides interviewers through constructive feedback by converting raw impressions into evidence-backed evaluations. Reads interview-notes templates, asks probing questions per competency, detects potential bias patterns, and maps scores to a seniority/skill matrix (corporate or proposed). Supports corporate template adaptation. Invokes compliance-check validation before output. Use when the user says 'close interview for', 'evaluate candidate', 'interview evaluation', 'chiudi colloquio', 'valutazione candidato', 'scheda valutazione', 'fill evaluation', or mentions completing a candidate assessment after an interview."
---

# Interview Close — Post-Interview Evaluation Generator

## 1. Overview

This skill produces standardized post-interview evaluations by guiding interviewers through a structured feedback process. It transforms raw impressions and notes into evidence-backed competency scores, classifies the candidate against a seniority matrix, and generates a hiring recommendation with justification.

The core interaction is a **guided feedback conversation**: rather than accepting vague impressions, the skill probes each competency area with targeted questions, converts subjective statements into observable evidence, and flags potential bias patterns. This coaching approach produces evaluations that are consistent, comparable across candidates, and defensible.

**Output file:** `{candidate}-evaluation.md` in `docs/outbox/`

**Connector support:** Skills degrade gracefully without connectors. See `CONNECTORS.md` for the full registry.

- If **~~ATS** is connected: pull candidate profile, interview schedule, and previous evaluation stages (pre-screening, interview-prep outputs)
- If **~~knowledge base** is connected: pull corporate evaluation templates, seniority matrices, compensation bands, and hiring policies
- If **~~HRIS** is connected: pull organizational level definitions, team composition, and headcount data for seniority calibration

If no connectors are available, the skill asks the user to provide interview notes and relevant context manually and proceeds with its built-in reference files.

---

## 2. Pipeline

### Step 1 — Input Collection

Collect inputs for the evaluation:

1. **Interview-prep outputs** — if the interview-prep skill was used for this role, collect the interview script, competency framework, and scoring rubric. Accept as file path or pasted text.
2. **Interviewer notes / feedback** — raw impressions, completed scorecards, or free-form notes from the interviewer(s). Accept as file path, pasted text, or verbal input.
3. **Candidate information** — name, role title, interview date, interviewer name(s), interview format (panel / 1:1 / video).

If **~~ATS** is connected: search for the candidate profile and pull interview records, previous stage evaluations (pre-screening results, interview-prep script).

If **~~knowledge base** is connected: search for corporate evaluation templates. If found, note for use in Step 8.

**Corporate context with memory:** Check conversation memory for previously stored corporate context (company name, evaluation templates, seniority matrices, compensation bands, hiring policies). If found, apply silently. If new corporate context is provided, save it to memory for future sessions.

**Output format preference:** Check memory for previously stored output format preference. If found, apply as default without re-asking.

**Language detection:** Count language-specific tokens across all input documents:
- **>80% single language** — auto-select that language for output
- **60-80% dominant language** — recommend dominant, ask user to confirm
- **<60% any language** — ask user to choose

### Step 2 — Seniority Matrix Resolution

Resolve the seniority matrix to be used for classification, following this priority:

1. **Corporate matrix** — if a corporate seniority matrix was found via **~~knowledge base** or provided by the user, use it.
2. **Interview-prep matrix (consistency rule)** — if a seniority matrix was created or used during interview-prep for this same role, reuse it. Check conversation memory. Present to user: "I found the seniority matrix used during interview preparation for [Role Title]. Should I use the same matrix for evaluation?"
3. **Generate from JD** — if neither of the above is available, load `references/seniority-matrix-template.md` and generate a proposed matrix from the JD competencies. Present the draft to the user for confirmation/editing.

**Important:** Do not proceed to scoring until the matrix is confirmed by the user. Record: "Matrix confirmed by [user] on [date]."

### Step 3 — Guided Feedback Interaction

This is the core step. Load `references/evaluation-template.md` for interaction patterns and evidence requirements.

For each competency in the matrix:

1. **Read available notes** — check if the interviewer's notes contain observations for this competency.
2. **Observation prompt** — "For [Competency], what specific examples or behaviors did the candidate demonstrate?"
3. **Depth probe** — "Can you describe a particular answer or moment that stood out — positively or negatively?"
4. **Comparison anchor** — "Compared to what you'd expect from a [target level] in this competency, how did the candidate perform?"
5. **Vague-to-evidence conversion** — if the interviewer provides vague feedback (e.g., "seemed senior", "good communicator"), use the conversion patterns from the evaluation template to probe for specifics.
6. **Score assignment** — "Based on this evidence, where would you place the candidate on the 1–5 scale?"

**Bias detection:** Throughout the interaction, monitor for bias patterns:

- All scores extreme (all 5s or all 1s) — prompt differentiation
- Halo/horns effect — prompt independent evaluation per competency
- Recency bias — prompt recall of earlier interview segments
- Similarity bias — redirect from personal affinity to job-relevant competencies
- Contrast effect — redirect from candidate comparison to role requirements
- Confirmation bias — prompt counter-examples

Flag detected patterns to the interviewer with a respectful, constructive tone. The goal is awareness, not accusation.

### Step 4 — Score Computation

Populate the competency scores table with the evidence collected in Step 3:

1. **Validate evidence completeness** — every competency must have a cited observation. Flag any gaps (see evaluation template evidence rules).
2. **Assign weights** — use weights from the seniority matrix or JD priority signals. Present to user for confirmation if not already set.
3. **Compute weighted total** — `SUM(Score_i × Weight_i)` for all competencies. Display as `X.XX / 5.00`.
4. **Compile strengths** — extract evidence-backed positive observations across competencies.
5. **Compile concerns** — extract evidence-backed risk areas, gaps, and development needs.

### Step 5 — Seniority Classification

Map the candidate's scores against the confirmed seniority matrix:

1. **Compute distance** — for each seniority level, calculate the weighted distance between actual scores and expected scores.
2. **Determine suggested level** — the level with minimum weighted distance.
3. **Apply threshold rules** — floor rule, ceiling validation, gap rule, strength override (see seniority-matrix-template.md classification algorithm).
4. **Assign confidence** — High / Medium / Low based on distance spread and threshold flags.
5. **Generate rationale** — 1–2 sentences explaining the classification with reference to key differentiating competencies.

Present the classification to the user for review. The user may override with documented justification.

### Step 6 — Recommendation

Generate a hiring recommendation based on the weighted total, seniority classification, and evaluation evidence:

1. **Determine recommendation category** — Strong Hire / Hire / No Hire / Strong No Hire using the thresholds from the evaluation template.
2. **Apply override rules** — check for single-competency failures, integrity concerns, or interviewer overrides.
3. **Write justification** — a concise, evidence-backed paragraph summarizing why this recommendation is made. Reference specific competency scores and observations.
4. **Compensation guidance** (if applicable) — if compensation bands are available (from **~~HRIS**, **~~knowledge base**, or user input), note the candidate's positioning relative to the band for their classified level.

### Step 7 — Compliance Validation

Invoke the **compliance-check** skill in embedded mode, passing:

- `text` — the complete evaluation draft
- `document_type` — `evaluation_form`
- `jurisdiction` — auto-detected from input language and content cues

Review the findings:

- **CRITICAL** findings: automatically fix and flag to the user what was changed
- **WARNING** findings: fix where possible, flag remaining items to the user
- **INFO** findings: apply improvements where straightforward

If any content is modified, note the compliance adjustments in the output.

### Step 8 — Corporate Template Adaptation

If a corporate evaluation template was found in Step 1:

1. **Map evaluation data** to the corporate template structure (see evaluation-template.md Section 8 for mapping rules).
2. **Convert scoring scales** if the corporate template uses a different scale.
3. **Handle field mismatches** — mark corporate-only fields as "N/A — not assessed" and append evaluation-only data as supplementary notes.
4. **Present the adapted output** alongside the standard evaluation for the user to choose which to finalize.

If no corporate template exists, use the standard evaluation structure from Section 4.

### Step 9 — Output

Save the completed evaluation to `docs/outbox/{candidate}-evaluation.md` in the detected language and confirmed format.

Present a summary to the user:
- Candidate name and role
- Weighted total score
- Seniority classification with confidence
- Recommendation category
- Compliance status (pass / pass with warnings / adjustments made)
- Any flags or overrides applied
- Suggested next steps: share with hiring panel, proceed to offer (if Hire/Strong Hire), provide feedback (if No Hire)

---

## 3. Progressive Disclosure

| Step | Documents to Read |
|------|-------------------|
| Step 1–2 | `references/seniority-matrix-template.md` (only if generating matrix from JD) |
| Step 3 | `references/evaluation-template.md` |
| Step 4–6 | (no additional references — in-skill computation using loaded templates) |
| Step 7 | (no references — invokes compliance-check skill in embedded mode) |
| Step 8 | (no additional references — mapping uses evaluation-template.md already loaded) |
| Step 9 | (no additional references — in-skill output generation) |

---

## 4. Output Template

```markdown
# Interview Evaluation — [Candidate Name] for [Role Title]

Date: [date] | Interviewer(s): [names] | Format: [panel/1:1/video]

## Competency Scores

| Competency | Score (1-5) | Evidence | Weight |
|------------|-------------|----------|--------|
| [Competency 1] | [score] | [Specific observation from interview] | [weight] |
| [Competency 2] | [score] | [Specific observation from interview] | [weight] |
| ... | ... | ... | ... |

**Weighted Total: [X.XX / 5.00]**

### Scoring Scale (1-5 BARS)

| Score | Label | Definition |
|-------|-------|------------|
| 1 | No evidence | No relevant knowledge, skill, or behavior observed |
| 2 | Below expectations | Basic awareness but significant gaps |
| 3 | Meets expectations | Competency at expected level for this role |
| 4 | Exceeds expectations | Above target with clear impact and ownership |
| 5 | Exceptional | Mastery with depth, breadth, and innovation |

## Strengths Observed

- [Evidence-backed strength 1]
- [Evidence-backed strength 2]
- ...

## Concerns Raised

- [Evidence-backed concern 1]
- [Evidence-backed concern 2]
- ...

## Seniority Classification

### Matrix Used

| Competency | Junior | Mid | Senior | Lead/Principal | **Candidate** |
|------------|--------|-----|--------|----------------|---------------|
| [Competency 1] | [exp] | [exp] | [exp] | [exp] | **[actual]** |
| ... | ... | ... | ... | ... | **...** |

### Classification Result

**Suggested Level:** [Level]
**Confidence:** [High / Medium / Low]
**Rationale:** [Why this level was selected, referencing key differentiating competencies]

## Recommendation

**Decision: [Strong Hire / Hire / No Hire / Strong No Hire]**

[Evidence-backed justification paragraph referencing specific competency scores, strengths, concerns, and seniority classification]

## Compensation Guidance

[If applicable: candidate positioning relative to compensation band for classified level, market context, any adjustment factors]

## Compliance Notes

[Any compliance findings addressed or flagged during validation]
```

---

## 5. Integration

- **Consumes:** interview-prep outputs (interview script, competency framework, scoring rubric, seniority matrix); interviewer notes and raw feedback
- **Invokes:** `compliance-check` in embedded mode (Step 7) to validate the evaluation for bias and legal compliance
- **Final pipeline output:** this skill produces the terminal artifact of the HR interview pipeline — the structured evaluation that feeds into hiring decisions

---

## 6. Language Detection

Count language-specific tokens across all input documents and conversation context. Classification:

- **>80% single language** — auto-select that language for output
- **60-80% dominant language** — recommend dominant, ask user to confirm
- **<60% any language** — ask user to choose

Supported languages:
- `en` — English
- `it` — Italian

For unsupported languages: produce the evaluation structure in the detected language where possible, use English for internal guidance, and note the limitation to the user.
