---
name: interview-close
description: "Use after an interview to turn one interviewer's notes into a scored, evidence-backed evaluation — 'evaluate candidate', 'close interview for', 'interview evaluation', 'fill evaluation', 'valutazione candidato', 'chiudi colloquio', 'scheda valutazione'. Guides the interviewer per competency on one absolute 1–5 scale, flags bias, classifies seniority against a saved matrix and proposes a recommendation the interviewer confirms; writes one file per interviewer and can consolidate a panel. Not for preparing the interview (interview-prep)."
---

# Interview Close — Post-Interview Evaluation Generator

## 1. Overview

This skill produces standardized post-interview evaluations by guiding interviewers through a structured feedback process. It transforms raw impressions and notes into evidence-backed competency scores, classifies the candidate against a seniority matrix, and proposes a hiring recommendation with justification. The interviewer confirms or overrides every computed result; a person makes the hiring decision.

The core interaction is a **guided feedback conversation**: rather than accepting vague impressions, the skill probes each competency area with targeted questions, converts subjective statements into observable evidence, and flags potential bias patterns. This coaching approach produces evaluations that are consistent, comparable across candidates, and defensible.

**Output files** (in the output directory — the output folder the project's CLAUDE.md declares; if none is declared, ask the user):

- `{candidate}-evaluation-{interviewer}.md` — one file per interviewer, so panel members never overwrite each other
- `{candidate}-evaluation-consolidated.md` — optional, when a panel consolidates (Step 10)
- `{role}-seniority-matrix.md` — the confirmed matrix for the role, reused for every candidate (no candidate data)

**Candidate data.** These files hold candidate personal data. Suggest an output folder outside version control; if the chosen folder is inside a git repository, say so and ask the user to confirm. Start every candidate file with the confidentiality line shown in the output template, with the delete-by date taken from the organization's retention period (ask once if it is unknown). Never save candidate data — names, CV content, answers, notes, scores, evaluations — to memory; only corporate context may be saved there.

**Connector support:** Skills degrade gracefully without connectors. See `CONNECTORS.md` for the full registry.

- If **~~ATS** is connected: pull candidate profile, interview schedule, and previous evaluation stages (pre-screening, interview-prep outputs)
- If **~~knowledge base** is connected: pull corporate evaluation templates, seniority matrices, compensation bands, and hiring policies
- If **~~HRIS** is connected: pull organizational level definitions, team composition, and headcount data for seniority calibration
- If **~~document converter** is connected: convert DOCX or PDF inputs (JD, notes, corporate templates) to Markdown

If no connectors are available, the skill asks the user to provide interview notes and relevant context manually and proceeds with its built-in reference files.

---

## 2. Pipeline

### Step 1 — Input Collection

Collect inputs for the evaluation:

1. **Job Description** — accept as file path, pasted text, or URL. The matrix, the weights and the target level come from it. If a file is DOCX or PDF, convert it with **~~document converter** when connected; otherwise ask for the text.
2. **Interview-prep outputs** — if the interview-prep skill was used for this candidate, collect the position assessment, the interview questions (competencies, question plan, answer examples), and the completed interview notes. Accept as file path or pasted text.
3. **Interviewer notes / feedback** — raw impressions, completed scorecards, or free-form notes from **one** interviewer. Accept as file path, pasted text, or verbal input. For a panel, run the skill once per interviewer.
4. **Candidate information** — name, role title, target level, interview date, the interviewer's name, interview format (panel / 1:1 / sequential; in person or video).

If **~~ATS** is connected: search for the candidate profile and pull interview records, previous stage evaluations (pre-screening results, interview-prep script).

If **~~knowledge base** is connected: search for corporate evaluation templates. If found, note for use in Step 7.

**Corporate context with memory:** Check conversation memory for previously stored corporate context (company name, evaluation templates, compensation bands, hiring policies). If found, apply silently. If new corporate context is provided, save it to memory for future sessions — corporate context only, never candidate data.

**Output format preference:** Check memory for previously stored output format preference. If found, apply as default without re-asking.

**Language detection:** Use the dominant language of the input documents and conversation for output. When the inputs clearly mix languages, recommend the dominant language and ask the user to confirm; when no language dominates, ask the user to choose.

### Step 2 — Seniority Matrix Resolution

Resolve the seniority matrix to be used for classification, following this priority (`references/seniority-matrix-template.md` Section 5):

1. **Saved role matrix** — look for `{role}-seniority-matrix.md` in the output folder first. If found, ask: "I found the seniority matrix confirmed for [Role Title] on [date]. Should I use it for this evaluation?"
2. **Corporate matrix** — if a corporate seniority matrix was found via **~~knowledge base** or provided by the user, use it.
3. **Generate from JD** — otherwise, load `references/seniority-matrix-template.md` and generate a proposed matrix from the JD competencies. Present the draft to the user for confirmation/editing.

**Important:** Do not proceed to scoring until the matrix is confirmed by the user. Record: "Matrix confirmed by [user] on [date]." Save a newly confirmed or edited matrix as `{role}-seniority-matrix.md`, with its weights and core competencies.

### Step 3 — Guided Feedback Interaction

This is the core step. Load `references/evaluation-template.md`: its Section 3 is the plugin's canonical absolute 1–5 scale, and Section 7 has the interaction patterns.

For each competency in the matrix:

1. **Read available notes** — check if the interviewer's notes contain observations for this competency.
2. **Observation prompt** — "For [Competency], what specific examples or behaviors did the candidate demonstrate?"
3. **Depth probe** — "Can you describe a particular answer or moment that stood out — positively or negatively?"
4. **Vague-to-evidence conversion** — if the interviewer provides vague feedback (e.g., "seemed senior", "good communicator", "great culture fit"), use the conversion patterns from the evaluation template to probe for specifics. Culture fit, demeanor and body language are not evidence; steer them to a job-relevant competency or leave them out.
5. **Anchor check and score** — read the anchors of the two nearest scores and ask which matches the evidence. If the area was not covered or the interviewer has no specific evidence, record **Not assessed** — never a 1. Compare with the target level only after the score is set.

**Bias detection:** Throughout the interaction, monitor for bias patterns:

- Low differentiation (near-identical scores across 4+ competencies) — prompt differentiation
- Halo/horns effect — prompt independent evaluation per competency
- Recency bias — prompt recall of earlier interview segments
- Similarity bias — redirect from personal affinity to job-relevant competencies
- Contrast effect — redirect from candidate comparison to the anchors and the matrix
- Confirmation bias — prompt counter-examples

Flag detected patterns to the interviewer with a respectful, constructive tone. The goal is awareness, not accusation.

### Step 4 — Score Computation

Populate the competency scores table with the evidence collected in Step 3 (`references/evaluation-template.md` Sections 2 and 5):

1. **Validate evidence completeness** — every scored competency must have a cited observation; a competency without one is Not assessed.
2. **Assign weights** — use the weights from the confirmed matrix or JD priority signals. Present to user for confirmation if not already set.
3. **Renormalize** — divide each assessed competency's weight by the sum of the assessed weights.
4. **Compute the weighted total and the target-level gap** — show both computation tables in the output, not just the results. Display the total as `X.XX / 5.00 (N of M competencies assessed)`.
5. **Compile strengths, concerns and evidence coverage** — evidence-backed strengths and concerns; list Not assessed competencies separately with a suggested follow-up.

### Step 5 — Seniority Classification

Map the candidate's scores against the confirmed seniority matrix (`references/seniority-matrix-template.md` Section 6):

1. **Compute distance** — for each level, the weighted distance over the assessed competencies, with the renormalized weights.
2. **Determine suggested level** — the level with minimum weighted distance.
3. **Apply threshold rules** — floor rule, ceiling validation, gap rule, strength override. Not assessed competencies never trigger them.
4. **Assign confidence** — High / Medium / Low; any Not assessed competency makes it Low.
5. **Generate rationale** — 1–2 sentences explaining the classification with reference to key differentiating competencies.

Show the distance table in the output. Present the classification to the user for review. The user may override with documented justification.

### Step 6 — Recommendation

Compute a proposed recommendation with the rules in `references/evaluation-template.md` Section 6:

1. **Determine the category** — Strong Hire / Hire / No Hire / Strong No Hire, from the target-level gap and the per-competency rules; "Insufficient evidence" when Not assessed competencies carry more than half the weight.
2. **Apply override rules** — a documented conduct concern (dishonesty, hostility or harassment, discriminatory remarks) forces Strong No Hire; culture fit and "values alignment" never do.
3. **Write justification** — a concise, evidence-backed paragraph summarizing why this category was computed. Reference specific competency scores and observations, and state "Based on N of M competencies" when any is Not assessed.
4. **Confirm with the interviewer** — present the computed category; the interviewer confirms it or overrides it with a documented reason.
5. **Compensation guidance** (if applicable) — if compensation bands are available (from **~~HRIS**, **~~knowledge base**, or user input), note the candidate's positioning relative to the band for their classified level.

### Step 7 — Corporate Template Adaptation

If a corporate evaluation template was found in Step 1:

1. **Map evaluation data** to the corporate template structure (see evaluation-template.md Section 8 for mapping rules).
2. **Convert scoring scales** if the corporate template uses a different scale; map Not assessed to the template's N/A, never to its lowest score.
3. **Handle field mismatches** — mark corporate-only fields as "N/A — not assessed", leave fields about appearance, body language or culture fit empty, and append evaluation-only data as supplementary notes.
4. **Prepare the adapted version** alongside the standard evaluation for the user to choose which to finalize.

If no corporate template exists, use the standard evaluation structure from Section 4.

### Step 8 — Compliance Validation (last check before output)

Run compliance-check on the final text — the standard evaluation and, if prepared, the adapted corporate version — so that nothing changes after the check. Load compliance-check with the Skill tool and the arguments `embedded evaluation_form` (the call is defined in compliance-check's Section 5; the jurisdiction is auto-detected). If the Skill tool cannot load it, read `../compliance-check/SKILL.md` and apply its embedded mode.

Review the findings:

- **CRITICAL** findings: automatically fix and flag to the user what was changed
- **WARNING** findings: fix where possible, flag remaining items to the user
- **INFO** findings: apply improvements where straightforward

If any content is modified, note the compliance adjustments in the output. If a fix changes a score or a field, re-run this step on the changed text.

### Step 9 — Output

Save the completed evaluation as `{candidate}-evaluation-{interviewer}.md` in the output directory, in the detected language and confirmed format (`{candidate}` and `{interviewer}` are sanitized names, lowercase, hyphens for spaces).

Present a summary to the user:
- Candidate name, role and interviewer
- Weighted total score and how many competencies were assessed
- Seniority classification with confidence
- Recommendation category (as confirmed by the interviewer)
- Compliance status (pass / pass with warnings / adjustments made)
- Any flags, overrides or Not assessed competencies, with the suggested follow-up
- Suggested next steps: collect the other panel members' evaluations and consolidate (Step 10), proceed to offer (if Hire/Strong Hire), provide feedback (if No Hire)

### Step 10 — Panel Consolidation (optional)

When two or more `{candidate}-evaluation-{interviewer}.md` files exist for the candidate, offer to consolidate them. Follow `references/evaluation-template.md` Section 9: compare the scores per competency, review the evidence behind any divergence of 2 or more points with the panel, recompute with the same matrix and rules, and run Step 8 on the consolidated draft before saving `{candidate}-evaluation-consolidated.md`. The individual files stay unchanged.

---

## 3. Progressive Disclosure

| Step | Documents to Read |
|------|-------------------|
| Step 1–2 | `references/seniority-matrix-template.md` Sections 1–5 (only if no saved or corporate matrix exists) |
| Step 3 | `references/evaluation-template.md` |
| Step 4 | (no additional references — uses evaluation-template.md already loaded) |
| Step 5 | `references/seniority-matrix-template.md` Section 6 (classification algorithm) — load it now if it was not loaded in Step 2 |
| Step 6 | (no additional references — recommendation rules from evaluation-template.md) |
| Step 7 | (no additional references — mapping uses evaluation-template.md already loaded) |
| Step 8 | (no references — invokes compliance-check skill in embedded mode) |
| Step 9 | (no additional references — in-skill output generation) |
| Step 10 | `references/evaluation-template.md` Section 9, and the calibration steps it points to in the interview-prep scoring rubric |

---

## 4. Output Template

```markdown
> Confidential — candidate personal data for the [Role Title] selection. Hiring team only. Delete by [YYYY-MM-DD] (retention policy).

# Interview Evaluation — [Candidate Name] for [Role Title]

Date: [date] | Interviewer: [name] | Format: [panel / 1:1 / sequential] | Target level: [level]

## Competency Scores

Scale: canonical absolute 1–5 with Not assessed (interview-close `evaluation-template.md` Section 3).

| Competency | Score (1-5 or NA) | Evidence | Weight | Weight used | Weighted |
|------------|-------------------|----------|--------|-------------|----------|
| [Competency 1] | [score] | [Specific observation from interview] | [weight] | [renormalized] | [product] |
| [Competency 2] | Not assessed | No evidence collected in this interview | [weight] | — | — |
| ... | ... | ... | ... | ... | ... |

**Weighted Total: [X.XX / 5.00] ([N] of [M] competencies assessed)**

### Target-Level Gap

| Competency | Score | Expected ([target level]) | Gap | Weight used | Weighted gap |
|------------|-------|---------------------------|-----|-------------|--------------|
| [Competency 1] | [score] | [expected] | [gap] | [weight used] | [product] |
| ... | ... | ... | ... | ... | ... |
| **G** | | | | | **[X.XX]** |

## Strengths Observed

- [Evidence-backed strength 1]
- [Evidence-backed strength 2]
- ...

## Concerns Raised

- [Evidence-backed concern 1]
- [Evidence-backed concern 2]
- ...

## Evidence Coverage

- Not assessed: [competencies, or "none"] — suggested follow-up: [question or short call]

## Seniority Classification

### Matrix Used

`{role}-seniority-matrix.md`, confirmed by [user] on [date].

| Competency | Junior | Mid | Senior | Lead/Principal | **Candidate** |
|------------|--------|-----|--------|----------------|---------------|
| [Competency 1] | [exp] | [exp] | [exp] | [exp] | **[actual or NA]** |
| ... | ... | ... | ... | ... | **...** |

### Distance Analysis

| Level | Weighted Distance | Notes |
|-------|-------------------|-------|
| Junior | [X.XX] | |
| Mid | [X.XX] | |
| Senior | [X.XX] | |
| Lead/Principal | [X.XX] | |

### Classification Result

**Suggested Level:** [Level]
**Confidence:** [High / Medium / Low]
**Rationale:** [Why this level was selected, referencing key differentiating competencies]

## Recommendation

**Computed category: [Strong Hire / Hire / No Hire / Strong No Hire / Insufficient evidence]** — confirmed by [interviewer] / overridden to [category] because [reason]

[Evidence-backed justification paragraph referencing specific competency scores, strengths, concerns, and seniority classification. "Based on N of M competencies" when any is Not assessed.]

## Compensation Guidance

[If applicable: candidate positioning relative to compensation band for classified level, market context, any adjustment factors]

## Compliance Notes

[Any compliance findings addressed or flagged during validation]
```

---

## 5. Integration

- **Consumes:** the JD; interview-prep outputs (position assessment, interview questions, interview notes); interviewer notes and raw feedback; `{role}-seniority-matrix.md` from an earlier evaluation for the same role
- **Invokes:** `compliance-check` in embedded mode (Step 8, and Step 10 for a consolidation) as the last check before writing
- **Produces for later runs:** `{role}-seniority-matrix.md`, which interview-prep also reads to set expected scores
- **Final pipeline output:** this skill produces the terminal artifact of the HR interview pipeline — the structured evaluation that informs the hiring decision people make

---

## 6. Language Detection

Use the dominant language of the input documents and conversation for output. When the inputs clearly mix languages, recommend the dominant language and ask the user to confirm; when no language dominates, ask the user to choose.

Supported languages:
- `en` — English
- `it` — Italian

For unsupported languages: produce the evaluation structure in the detected language where possible, use English for internal guidance, and note the limitation to the user.
