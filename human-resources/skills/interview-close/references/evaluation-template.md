# Evaluation Template — Reference Guide

This reference provides the standard evaluation structure, scoring rules, evidence requirements, and guided feedback interaction patterns used by the interview-close skill.

Section 3 is the plugin's **canonical scoring scale**. Every other file that mentions the 1–5 scale (the interview-prep scoring rubric and question templates, the interview-close SKILL.md, the seniority matrix template, METHODOLOGY.md) points here. Change the scale here and nowhere else.

---

## 1. Standard Evaluation Structure

Every evaluation follows this structure:

1. **Header** — confidentiality line, candidate name, role title, target level, date, interviewer, interview format
2. **Competency Scores Table** — one row per competency with score (or Not assessed), evidence, weight, and the computation columns
3. **Scoring Scale** — a pointer to Section 3 of this file
4. **Strengths Observed** — evidence-backed positive observations
5. **Concerns Raised** — evidence-backed risk areas
6. **Evidence Coverage** — competencies Not assessed, and what a follow-up should cover
7. **Seniority Classification** — level determination from matrix mapping, with the distance table
8. **Recommendation** — hiring recommendation with the target-level gap table and justification, confirmed by the interviewer
9. **Compensation Guidance** — market alignment notes (if applicable)

---

## 2. Competency Scores Table

```markdown
| Competency | Score (1-5 or NA) | Evidence | Weight | Weight used | Weighted |
|------------|-------------------|----------|--------|-------------|----------|
| [From JD]  | [1-5 / Not assessed] | [Cited observation] | [0.0-1.0] | [renormalized] | [Score × Weight used] |
```

### Rules

- Every competency listed in the JD or seniority matrix must have a row.
- The **Weight** column values must sum to 1.0 across all competencies.
- A **Not assessed** competency keeps its row and its weight, but its "Weight used" and "Weighted" cells are empty.
- **Weight used** renormalizes the weights of the assessed competencies: `Weight used_i = Weight_i / SUM(Weight_j for assessed j)`.
- The **Weighted Total** is `SUM(Score_i × Weight used_i)` over the assessed competencies.
- Display the weighted total prominently: **Weighted Total: X.XX / 5.00 (N of M competencies assessed)**
- The computation columns stay in the output, so a reader can check every figure.

---

## 3. Scoring Scale (canonical, absolute 1–5)

The anchors are **absolute**: a score describes what the candidate showed, the same way for every role and level. What changes with the level is the *expected* score, which comes from the seniority matrix. This is what lets the matrix classify seniority.

| Score | Label | Anchor |
|-------|-------|--------|
| 1 | No competence shown | The evidence shows the competency is absent: the candidate could not address the area despite probing, or showed a fundamental misunderstanding. |
| 2 | Basic, with guidance | Performs basic tasks in this area with guidance. Shows awareness, but with gaps in depth, application or consistency; examples lack specificity. |
| 3 | Independent | Handles standard situations in this area on their own. Gives relevant, specific examples of their own work with reasonable depth. |
| 4 | Advanced | Handles complex or ambiguous problems in this area and guides or mentors others. Examples show clear ownership, trade-offs and impact. |
| 5 | Sets direction for others | Sets direction in this area for a team or the organization. Several compelling examples show strategic trade-offs and influence beyond their own work. |
| NA | Not assessed | No evidence was collected: the question was not asked, time ran out, or the interviewer cannot recall a specific moment. This is not a score. |

These anchors match the seniority levels in `seniority-matrix-template.md` Section 2: Junior typically 1–2, Mid 2–3, Senior 3–4, Lead/Principal 4–5.

### Meets, exceeds, below

A competency **meets** the target level when its score is at or above the matrix value for that level, **exceeds** it when the score is higher (or is 5 where 5 is expected), and is **below** it otherwise. The recommendation rules in Section 6 use these terms.

### Scoring Discipline

- **Half scores are not permitted** in the final evaluation. Use whole numbers only.
- **Score the evidence, then compare.** First pick the anchor that matches the evidence; only then look at the expected score for the target level.
- **Avoid central tendency bias.** Do not default to one score for all competencies. Differentiate based on actual evidence.
- **Not assessed is never a 1.** A 1 needs evidence that the competency is absent; no evidence at all is Not assessed.

---

## 4. Evidence Requirement Rules

### Mandatory Evidence

Every score **must** have a cited observation in the Evidence column. The evidence must reference:

- A specific answer, example, or behavior observed during the interview
- The interview question or context that prompted the observation
- Enough detail that another reviewer could understand the basis for the score

### Evidence Quality Criteria

| Quality Level | Example | Acceptable? |
|---------------|---------|-------------|
| **Specific** | "Described migrating a monolith to microservices, reducing deployment time from 2 hours to 15 minutes" | Yes |
| **Behavioral** | "When asked about conflict resolution, described mediating between design and engineering teams on API contracts, resulting in a shared schema" | Yes |
| **Vague** | "Seemed to know about system design" | No — probe further |
| **Absent** | "" (empty) | No — flag immediately |
| **Opinion-only** | "Very impressive candidate" | No — probe for specifics |

### Empty Evidence Handling

If any competency has an empty or vague evidence field:

1. **Flag immediately** to the interviewer: "I notice [Competency] has no supporting evidence. Can you recall a specific moment in the interview that informed your impression?"
2. If the interviewer cannot provide evidence, record the competency as **Not assessed** with the note "No evidence collected in this interview". Do not give it a score.
3. List it under Evidence Coverage with a suggested follow-up (for example a short follow-up call or a question in the next round). It is not a concern about the candidate, and it never lowers the recommendation or the seniority level by itself.

---

## 5. Weighted Scoring

### Assigning Weights

Weights reflect the relative importance of each competency for the specific role:

1. **Extract priority signals from JD** — "must have" requirements get higher weight than "nice to have"
2. **Use a three-tier system** when JD priorities are unclear:
   - Core competencies (essential to the role): weight 0.20–0.30 each
   - Important competencies (significantly impact success): weight 0.10–0.20 each
   - Supporting competencies (contribute but not critical): weight 0.05–0.10 each
3. **Weights must sum to 1.0** — validate before scoring
4. **Present weights to user for confirmation** before computing scores

### Weighted Total Computation

```
Weight used_i  = Weight_i / SUM(Weight_j for assessed j)
Weighted Total = SUM(Score_i × Weight used_i) for assessed i
```

Example with 4 competencies, one Not assessed:

| Competency | Score | Weight | Weight used | Weighted |
|------------|-------|--------|-------------|----------|
| System Design | 4 | 0.30 | 0.375 | 1.50 |
| Coding | 3 | 0.25 | 0.3125 | 0.94 |
| Communication | 4 | 0.25 | 0.3125 | 1.25 |
| Leadership | Not assessed | 0.20 | — | — |
| **Total** | | **1.00** | **1.00** | **3.69 / 5.00 (3 of 4 assessed)** |

### Target-Level Gap

The recommendation compares the scores with the expected scores for the **target level** (the level the role is hired at) in the confirmed seniority matrix:

```
Gap_i            = Score_i − Expected_i(target level)
Weighted gap (G) = SUM(Gap_i × Weight used_i) for assessed i
```

| Competency | Score | Expected (target) | Gap | Weight used | Weighted gap |
|------------|-------|-------------------|-----|-------------|--------------|
| System Design | 4 | 4 | 0 | 0.375 | 0.00 |
| Coding | 3 | 4 | −1 | 0.3125 | −0.31 |
| Communication | 4 | 3 | +1 | 0.3125 | +0.31 |
| **G** | | | | | **0.00** |

Here G = 0.00 and no core competency is more than 1 point below the target level, so the computed category is Hire (Section 6).

Show this table in every evaluation, together with the competency table above and the distance table from `seniority-matrix-template.md` Section 6.

---

## 6. Recommendation Categories

The recommendation is a proposal computed from the interviewer's scores. The interviewer reviews it and confirms or overrides it; a person makes the hiring decision.

| Category | Rule (assessed competencies only) | Definition | Action |
|----------|-----------------------------------|------------|--------|
| **Strong Hire** | No competency below the target level, and the competencies that exceed it carry at least half of the weight used | Candidate clearly exceeds the target level across core areas. | Proceed with offer. Prioritize candidate in pipeline. |
| **Hire** | G ≥ 0, and no core competency more than 1 point below the target level | Candidate meets the target level. Development gaps are manageable. | Proceed with offer. Note development areas for onboarding. |
| **No Hire** | G < 0, or any core competency 2 or more points below the target level | Candidate does not meet the target level in one or more critical areas. | Do not proceed. Provide constructive feedback if requested. |
| **Strong No Hire** | G ≤ −1.0, or two or more core competencies 2 or more points below the target level, or a documented conduct concern | Candidate is clearly below the target level, or a conduct concern was observed. | Do not proceed. Document the specific evidence for compliance. |

Check Strong No Hire first, then No Hire. If neither holds, the candidate meets the Hire rule; the category is Strong Hire when its rule also holds, otherwise Hire.

### Override Rules

- A **documented conduct concern** forces **Strong No Hire** regardless of scores. Conduct concerns are limited to: dishonesty about experience or qualifications, hostility or harassment toward interviewers, and discriminatory remarks. Culture fit, "values alignment", personality and demeanor are not conduct concerns and never trigger this rule.
- **Not assessed** competencies are left out of every rule above. They never force No Hire and never cap the seniority level.
- If Not assessed competencies carry more than half of the original weight, do not compute a category: report "Insufficient evidence — schedule a follow-up interview".
- Any Not assessed competency sets the classification confidence to Low, and the recommendation states "Based on N of M competencies".
- The interviewer may override the computed recommendation, but must document the reason.

---

## 7. Guided Feedback Interaction Patterns

The interview-close skill does not simply accept raw impressions. It guides interviewers through a structured feedback process, converting vague impressions into evidence-backed evaluations.

### Per-Competency Probing Questions

For each competency, ask the interviewer:

1. **Observation prompt**: "For [Competency], what specific examples or behaviors did the candidate demonstrate?"
2. **Depth probe**: "Can you describe a particular answer or moment that stood out — positively or negatively?"
3. **Anchor check**: read the anchors of the two nearest scores in Section 3 and ask: "Which of these two descriptions matches the evidence better?"
4. **Score assignment**: "Based on this evidence, which score fits: 1–5, or Not assessed if this area wasn't covered?"

Compare the score with the target level only after it is assigned, so the expected value does not pull the score toward it.

### Vague-to-Evidence Conversion

When the interviewer provides vague feedback, use these conversion patterns:

| Vague Input | Probing Response |
|-------------|------------------|
| "Seemed senior" | "What specific answers or behaviors gave you that impression? For example, did they discuss system-level thinking, mentoring, or architectural trade-offs?" |
| "Good communicator" | "Can you recall a moment where their communication skills were particularly evident? How did they structure their answers or handle clarifying questions?" |
| "Not technical enough" | "Which technical questions did they struggle with? Were there specific areas where their answers lacked depth, or was it a general impression?" |
| "Great culture fit" | "Culture fit is not scored. Which job-relevant behavior did you observe — for example how they described collaborating, handling disagreement or giving feedback? We can record it under the matching competency." |
| "Didn't seem interested" | "What in the content of their answers or their questions gave you that impression? Demeanor and body language are not evidence: they vary with culture, disability and nerves." |
| "Really smart" | "Which answers demonstrated strong analytical thinking? Can you describe a problem they solved or a concept they explained particularly well?" |
| "Would be a good junior" | "What led you to that level assessment? Which anchors on the scale matched their answers in each area?" |

### Bias Detection Prompts

Monitor for common bias patterns and intervene:

| Pattern | Detection Rule | Intervention |
|---------|---------------|--------------|
| **Low differentiation** | Standard deviation of the assessed scores < 0.5 across 4+ competencies | "I notice the scores are very similar. Most candidates show variation across competencies. Could we revisit each area individually to differentiate?" |
| **Halo/horns effect** | All scores shift after one strong/weak area | "It seems like [strong/weak area] may be influencing the other scores. Let's evaluate each competency based only on the evidence for that specific area." |
| **Recency bias** | Evidence only from last 10 minutes of interview | "The evidence seems to focus on the later part of the interview. Were there notable observations from earlier — the opening questions or technical section?" |
| **Similarity bias** | Evidence references shared background, school, or personal interests | "I notice the positive evidence references [shared trait]. Let's ensure the assessment focuses on job-relevant competencies rather than personal affinity." |
| **Contrast effect** | References to previous candidate | "The assessment seems to compare this candidate to the previous one. Let's evaluate against the anchors and the seniority matrix instead." |
| **Confirmation bias** | All evidence supports a pre-stated conclusion | "The evidence consistently supports [conclusion]. For a balanced assessment, were there any counter-examples or areas where the candidate surprised you?" |

---

## 8. Corporate Template Adaptation

When a corporate evaluation template exists (from **~~knowledge base** or provided by the user):

### Mapping Process

1. **Extract corporate template structure** — identify required fields, sections, and scoring system
2. **Map evaluation data to corporate fields**:
   - Competency scores → corporate scoring fields (convert scale if needed, e.g., 1–5 to 1–10)
   - Not assessed → the corporate template's "not assessed" or "N/A" value, never its lowest score
   - Evidence → corporate justification fields
   - Recommendation → corporate decision field
   - Seniority classification → corporate level assessment field
3. **Handle mismatches**:
   - Corporate template has fields not in evaluation → mark as "N/A — not assessed in this interview"
   - Corporate fields about appearance, body language, culture fit or personal characteristics → leave empty and note "not collected: not job-relevant"; compliance-check reviews the adapted form afterwards
   - Evaluation has data not in corporate template → append as supplementary notes
   - Different scoring scale → apply linear conversion and note the original score

### Scale Conversion Table

| Original (1–5) | Target (1–10) | Target (1–4) | Target (1–3) |
|-----------------|---------------|--------------|--------------|
| 1 | 1–2 | 1 | 1 |
| 2 | 3–4 | 1–2 | 1 |
| 3 | 5–6 | 2–3 | 2 |
| 4 | 7–8 | 3 | 2–3 |
| 5 | 9–10 | 4 | 3 |

When converting, always note the original score alongside the converted value for transparency.

---

## 9. Panel Consolidation

Each interviewer writes their own evaluation file. When two or more exist for the same candidate, the skill can consolidate them. Follow the Post-Interview Calibration steps in the interview-prep scoring rubric (`../../interview-prep/references/scoring-rubric.md` Section 4): independent scores first, compare per competency, review the evidence behind any divergence of 2 or more points, then consensus or the median with a note. In addition:

1. **Inputs** — read every `{candidate}-evaluation-{interviewer}.md` file for the candidate. Leave them unchanged.
2. **Per competency** — list each interviewer's score and evidence. Use only the interviewers who assessed it; the consolidated competency is Not assessed only if nobody assessed it. When the median falls between two scores (an even number of interviewers), ask the panel to choose one of the two from the evidence, since final scores are whole numbers.
3. **Recompute** — the weighted total, the target-level gap, the classification and the recommendation, with the same rules and the same confirmed matrix.
4. **Output** — `{candidate}-evaluation-consolidated.md`, with the per-interviewer scores table, the divergences and how each was resolved, and the recomputed tables. It carries the same confidentiality line and goes through compliance-check before it is saved.
