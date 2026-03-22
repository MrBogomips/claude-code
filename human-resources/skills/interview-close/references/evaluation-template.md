# Evaluation Template — Reference Guide

This reference provides the standard evaluation structure, scoring rules, evidence requirements, and guided feedback interaction patterns used by the interview-close skill.

---

## 1. Standard Evaluation Structure

Every evaluation follows this structure:

1. **Header** — candidate name, role title, date, interviewer(s), interview format
2. **Competency Scores Table** — one row per competency with score, evidence, and weight
3. **Scoring Scale** — 1–5 BARS (Behaviorally Anchored Rating Scale)
4. **Strengths Observed** — evidence-backed positive observations
5. **Concerns Raised** — evidence-backed risk areas
6. **Seniority Classification** — level determination from matrix mapping
7. **Recommendation** — hiring decision with justification
8. **Compensation Guidance** — market alignment notes (if applicable)

---

## 2. Competency Scores Table

```markdown
| Competency | Score (1-5) | Evidence | Weight |
|------------|-------------|----------|--------|
| [From JD]  | [1-5]       | [Cited observation] | [0.0-1.0] |
```

### Rules

- Every competency listed in the JD or seniority matrix must have a row.
- The **Weight** column values must sum to 1.0 across all competencies.
- The **Weighted Total** is computed as: `SUM(Score_i * Weight_i)` for all competencies.
- Display the weighted total prominently: **Weighted Total: X.XX / 5.00**

---

## 3. Scoring Scale (1–5 BARS)

| Score | Label | Definition |
|-------|-------|------------|
| 1 | No evidence | Candidate showed no relevant knowledge, skill, or behavior. Could not address the competency area. |
| 2 | Below expectations | Candidate demonstrated basic awareness but significant gaps in depth, application, or consistency. Responses lacked specificity. |
| 3 | Meets expectations | Candidate demonstrated competency at the level expected for the target role. Provided adequate examples with reasonable depth. |
| 4 | Exceeds expectations | Candidate demonstrated competency above target level. Provided strong examples with clear impact, ownership, and transferable patterns. |
| 5 | Exceptional | Candidate demonstrated mastery. Provided multiple compelling examples showing depth, breadth, leadership, and innovation in this area. |

### Scoring Discipline

- **Half scores are not permitted.** Use whole numbers only.
- **The middle score (3) is the anchor.** It means "meets expectations for this role at this level." Scores above or below must be justified relative to this anchor.
- **Avoid central tendency bias.** Do not default to 3 for all competencies. Differentiate based on actual evidence.

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
| **Specific** | "Described migrating a monolith to microservices at Company X, reducing deployment time from 2 hours to 15 minutes" | Yes |
| **Behavioral** | "When asked about conflict resolution, described mediating between design and engineering teams on API contracts, resulting in a shared schema" | Yes |
| **Vague** | "Seemed to know about system design" | No — probe further |
| **Absent** | "" (empty) | No — flag immediately |
| **Opinion-only** | "Very impressive candidate" | No — probe for specifics |

### Empty Evidence Handling

If any competency has an empty or vague evidence field:

1. **Flag immediately** to the interviewer: "I notice [Competency] has no supporting evidence. Can you recall a specific moment in the interview that informed your impression?"
2. If the interviewer cannot provide evidence, record: "No observable evidence during this interview session" and set score to 1 (No evidence).
3. Note the gap in the Concerns section.

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
Weighted Total = SUM(Score_i × Weight_i) for all i
```

Example with 4 competencies:

| Competency | Score | Weight | Weighted |
|------------|-------|--------|----------|
| System Design | 4 | 0.30 | 1.20 |
| Coding | 3 | 0.25 | 0.75 |
| Communication | 4 | 0.25 | 1.00 |
| Leadership | 3 | 0.20 | 0.60 |
| **Total** | | **1.00** | **3.55 / 5.00** |

---

## 6. Recommendation Categories

| Category | Weighted Total Range | Definition | Action |
|----------|---------------------|------------|--------|
| **Strong Hire** | ≥ 4.0 AND no competency below 3 | Candidate clearly exceeds expectations across core areas. Strong evidence of impact and growth potential. | Proceed with offer. Prioritize candidate in pipeline. |
| **Hire** | ≥ 3.0 AND no core competency below 2 | Candidate meets expectations for the role. Adequate evidence across required areas with manageable development gaps. | Proceed with offer. Note development areas for onboarding. |
| **No Hire** | < 3.0 OR any core competency at 1 | Candidate does not meet expectations in one or more critical areas. Gaps would require significant investment to close. | Do not proceed. Provide constructive feedback if requested. |
| **Strong No Hire** | < 2.0 OR multiple core competencies at 1 OR integrity/values concern | Candidate is clearly below requirements, or concerns about values alignment or professional integrity were observed. | Do not proceed. Document specific concerns for compliance. |

### Override Rules

- A single **1 (No evidence)** on a core competency forces a maximum recommendation of **No Hire**, regardless of weighted total.
- An integrity or values concern (dishonesty, hostility, discrimination) forces **Strong No Hire** regardless of scores.
- The interviewer may override the algorithmic recommendation, but must document the reason.

---

## 7. Guided Feedback Interaction Patterns

The interview-close skill does not simply accept raw impressions. It guides interviewers through a structured feedback process, converting vague impressions into evidence-backed evaluations.

### Per-Competency Probing Questions

For each competency, ask the interviewer:

1. **Observation prompt**: "For [Competency], what specific examples or behaviors did the candidate demonstrate?"
2. **Depth probe**: "Can you describe a particular answer or moment that stood out — positively or negatively?"
3. **Comparison anchor**: "Compared to what you'd expect from a [target level] in this competency, how did the candidate perform?"
4. **Score assignment**: "Based on this evidence, where would you place the candidate on the 1–5 scale?"

### Vague-to-Evidence Conversion

When the interviewer provides vague feedback, use these conversion patterns:

| Vague Input | Probing Response |
|-------------|------------------|
| "Seemed senior" | "What specific answers or behaviors gave you that impression? For example, did they discuss system-level thinking, mentoring, or architectural trade-offs?" |
| "Good communicator" | "Can you recall a moment where their communication skills were particularly evident? How did they structure their answers or handle clarifying questions?" |
| "Not technical enough" | "Which technical questions did they struggle with? Were there specific areas where their answers lacked depth, or was it a general impression?" |
| "Great culture fit" | "What aspects of their values or working style aligned with the team? Can you cite a specific answer or interaction that demonstrated this?" |
| "Didn't seem interested" | "What signals gave you that impression? Was it their questions, body language, or the content of their answers?" |
| "Really smart" | "Which answers demonstrated strong analytical thinking? Can you describe a problem they solved or a concept they explained particularly well?" |
| "Would be a good junior" | "What led you to that level assessment? Were there specific areas where they showed potential but lacked depth? What would you expect from a mid-level candidate instead?" |

### Bias Detection Prompts

Monitor for common bias patterns and intervene:

| Pattern | Detection Rule | Intervention |
|---------|---------------|--------------|
| **All scores extreme** (all 5s or all 1s) | Standard deviation of scores < 0.5 across 4+ competencies | "I notice all scores are very similar. Most candidates show variation across competencies. Could we revisit each area individually to differentiate?" |
| **Halo/horns effect** | All scores identical, or all scores shift after one strong/weak area | "It seems like [strong/weak area] may be influencing the other scores. Let's evaluate each competency based only on the evidence for that specific area." |
| **Recency bias** | Evidence only from last 10 minutes of interview | "The evidence seems to focus on the later part of the interview. Were there notable observations from earlier — the opening questions or technical section?" |
| **Similarity bias** | Evidence references shared background, school, or personal interests | "I notice the positive evidence references [shared trait]. Let's ensure the assessment focuses on job-relevant competencies rather than personal affinity." |
| **Contrast effect** | References to previous candidate | "The assessment seems to compare this candidate to the previous one. Let's evaluate against the role requirements and seniority matrix instead." |
| **Confirmation bias** | All evidence supports a pre-stated conclusion | "The evidence consistently supports [conclusion]. For a balanced assessment, were there any counter-examples or areas where the candidate surprised you?" |

---

## 8. Corporate Template Adaptation

When a corporate evaluation template exists (from ~~knowledge base or provided by the user):

### Mapping Process

1. **Extract corporate template structure** — identify required fields, sections, and scoring system
2. **Map evaluation data to corporate fields**:
   - Competency scores → corporate scoring fields (convert scale if needed, e.g., 1–5 to 1–10)
   - Evidence → corporate justification fields
   - Recommendation → corporate decision field
   - Seniority classification → corporate level assessment field
3. **Handle mismatches**:
   - Corporate template has fields not in evaluation → mark as "N/A — not assessed in this interview"
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
