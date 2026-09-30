# Seniority Matrix Template — Reference Guide

This reference provides the default matrix structure, generation rules, industry benchmarks, and classification algorithm used by the interview-close skill.

---

## 1. Default Matrix Structure

The seniority matrix maps competencies (rows) against seniority levels (columns). Each cell contains the expected score for that competency at that level, on the canonical absolute 1–5 scale in `evaluation-template.md` Section 3 (1 = no competence shown … 5 = sets direction for others).

```markdown
| Competency | Junior (1-2 yrs) | Mid (3-5 yrs) | Senior (5-8 yrs) | Lead/Principal (8+ yrs) |
|------------|-------------------|----------------|-------------------|--------------------------|
| [Competency 1] | [expected 1-5] | [expected 1-5] | [expected 1-5] | [expected 1-5] |
| [Competency 2] | [expected 1-5] | [expected 1-5] | [expected 1-5] | [expected 1-5] |
```

### Matrix Rules

- **Columns** represent seniority levels: Junior, Mid, Senior, Lead/Principal
- **Rows** represent competencies extracted from the JD
- **Cell values** are expected proficiency scores (1–5) at each level
- **Monotonic progression**: scores must be non-decreasing from left (Junior) to right (Lead/Principal) for each competency
- **Not all competencies reach 5**: some competencies plateau at a level (e.g., basic tool proficiency may be 3 at Junior and stay 3 through Lead)
- **Differentiation matters**: at least one cell per row must differ across levels, otherwise the competency does not contribute to level classification

---

## 2. Generating a Matrix from JD Competencies

### Step-by-Step Process

1. **Extract competencies from JD** — identify all technical skills, soft skills, and domain knowledge areas listed in the job description. Group related items (e.g., "Python" and "Django" may become "Python/Django Development").

2. **Assign weights** — use the same weights from the evaluation template. Core competencies get higher weight (0.20–0.30), supporting competencies lower (0.05–0.10).

3. **Define expected proficiency per level** — for each competency, set the expected score (canonical scale, `evaluation-template.md` Section 3) at each seniority level:
   - **Junior**: can perform basic tasks with guidance (typically 1–2)
   - **Mid**: can work independently on standard tasks (typically 2–3)
   - **Senior**: can handle complex problems and mentor others (typically 3–4)
   - **Lead/Principal**: can set direction, design systems, and drive organizational impact (typically 4–5)

4. **Validate monotonic progression** — ensure no competency has a score that decreases from a lower to higher seniority level.

5. **Present to user for confirmation** — the matrix is a proposal, not a final decision. The user must confirm or edit before it is used for classification.
6. **Save the confirmed matrix** — write it to `{role}-seniority-matrix.md` in the output folder (Section 5), so later candidates for the same role are scored against the same matrix.

### Example Generation

Given a JD for "Backend Software Engineer" with competencies: System Design, Go Programming, API Design, Testing, Communication:

| Competency | Junior | Mid | Senior | Lead/Principal |
|------------|--------|-----|--------|----------------|
| System Design | 1 | 2 | 4 | 5 |
| Go Programming | 2 | 3 | 4 | 4 |
| API Design | 1 | 3 | 4 | 5 |
| Testing | 2 | 3 | 3 | 4 |
| Communication | 2 | 3 | 4 | 5 |

---

## 3. Industry Benchmarks by Role Family

Use these benchmarks as starting points when generating matrices. They represent typical expectations and should be adapted to the specific JD.

### Software Engineering

| Competency | Junior | Mid | Senior | Lead/Principal |
|------------|--------|-----|--------|----------------|
| Programming fundamentals | 2 | 3 | 4 | 4 |
| System design / architecture | 1 | 2 | 4 | 5 |
| Code quality / testing | 2 | 3 | 4 | 4 |
| Debugging / troubleshooting | 1 | 3 | 4 | 4 |
| Technical communication | 2 | 3 | 4 | 5 |
| Mentoring / leadership | 1 | 1 | 3 | 5 |
| Cross-functional collaboration | 1 | 2 | 3 | 4 |
| Domain knowledge | 1 | 2 | 3 | 4 |

### Product / Design

| Competency | Junior | Mid | Senior | Lead/Principal |
|------------|--------|-----|--------|----------------|
| User research | 2 | 3 | 4 | 5 |
| Problem framing | 1 | 2 | 4 | 5 |
| Design execution | 2 | 3 | 4 | 4 |
| Prototyping / tooling | 2 | 3 | 4 | 4 |
| Stakeholder management | 1 | 2 | 3 | 5 |
| Data-informed decisions | 1 | 2 | 3 | 4 |
| Strategic thinking | 1 | 1 | 3 | 5 |
| Mentoring / leadership | 1 | 1 | 3 | 5 |

### Operations / Admin

| Competency | Junior | Mid | Senior | Lead/Principal |
|------------|--------|-----|--------|----------------|
| Process execution | 2 | 3 | 4 | 4 |
| Process improvement | 1 | 2 | 4 | 5 |
| Tool proficiency | 2 | 3 | 3 | 3 |
| Reporting / analytics | 1 | 2 | 3 | 4 |
| Stakeholder communication | 2 | 3 | 4 | 5 |
| Project coordination | 1 | 2 | 3 | 4 |
| Policy / compliance | 1 | 2 | 3 | 5 |
| Team leadership | 1 | 1 | 3 | 5 |

### Generic (Role-Agnostic Baseline)

| Competency | Junior | Mid | Senior | Lead/Principal |
|------------|--------|-----|--------|----------------|
| Core technical/functional skill | 2 | 3 | 4 | 5 |
| Problem solving | 1 | 2 | 4 | 5 |
| Communication | 2 | 3 | 4 | 5 |
| Autonomy / ownership | 1 | 2 | 4 | 4 |
| Collaboration | 2 | 3 | 3 | 4 |
| Mentoring / leadership | 1 | 1 | 3 | 5 |
| Strategic thinking | 1 | 1 | 3 | 5 |
| Domain expertise | 1 | 2 | 3 | 4 |

---

## 4. Propose-and-Confirm Workflow

The seniority matrix must be confirmed by the user before it is used for classification. This ensures the matrix reflects the organization's actual expectations, not just generic benchmarks.

### Workflow Steps

1. **Generate draft matrix** — using JD competencies and industry benchmarks as starting points
2. **Present to user with explanation**:
   ```
   Here is the proposed seniority matrix for [Role Title]. Each cell shows
   the expected proficiency (1–5) at each level. Please review:
   - Are the competencies correct and complete?
   - Do the expected scores per level match your organization's standards?
   - Should any competency be added, removed, or reweighted?
   ```
3. **Accept edits** — the user may change any cell value, add/remove competencies, or adjust weights
4. **Lock and save the matrix** — once the user confirms, the matrix is locked for the evaluation. Record in output: "Matrix confirmed by [user] on [date]", and save it as `{role}-seniority-matrix.md` (Section 5)

### Important: Do not proceed to classification with an unconfirmed matrix.

---

## 5. Matrix Consistency Rule

Every candidate for the same role is classified against the same confirmed matrix. The matrix is kept as a file, `{role}-seniority-matrix.md` in the output folder (`{role}` is the sanitized role title, lowercase, hyphens for spaces). It holds no candidate data.

### Consistency Check

1. Look for `{role}-seniority-matrix.md` in the output folder first.
2. If found, present it to the user: "I found the seniority matrix confirmed for [Role Title] on [date]. Should I use it for this evaluation?"
3. If confirmed, use as-is. If the user wants changes, save the edited matrix as the new `{role}-seniority-matrix.md`, add "Revised on [date]: [what changed]" at its top, and note in the evaluation that earlier candidates were scored against the previous version.
4. If not found, use a corporate matrix (from **~~knowledge base** or the user), or generate one from the JD (Section 2). Save it once confirmed.

### File Format

```markdown
# Seniority Matrix — [Role Title]

Confirmed by [user] on [date]. Scale: `evaluation-template.md` Section 3 of the interview-close skill.

| Competency | Weight | Core? | Junior | Mid | Senior | Lead/Principal |
|------------|--------|-------|--------|-----|--------|----------------|
| [Competency 1] | [0.00] | [yes/no] | [1-5] | [1-5] | [1-5] | [1-5] |
```

---

## 6. Classification Algorithm

### Weighted Average Method

1. For each seniority level in the matrix, compute the distance between the candidate's actual scores and the expected scores, over the **assessed** competencies only, with the renormalized weights from `evaluation-template.md` Section 2:

```
Distance(level) = SUM( WeightUsed_i × |ActualScore_i - ExpectedScore_i(level)| ) for assessed competencies i
```

Not assessed competencies are left out of the distance and of every threshold rule below.

2. The candidate's suggested level is the level with the **minimum weighted distance**.

3. If two levels have similar distances (within 0.3), classify at the lower level and note that the candidate is "approaching [higher level]."

### Threshold Rules

After computing the minimum-distance level, apply these threshold rules:

| Rule | Condition | Action |
|------|-----------|--------|
| **Floor rule** | Any core competency scored at 1 (evidence of no competence — never Not assessed) | Cannot be classified above Junior, regardless of other scores |
| **Ceiling validation** | Suggested level is Lead/Principal | Verify at least 2 competencies scored 5 AND no assessed competency below 3 |
| **Gap rule** | Any competency is 2+ points below expected for the suggested level | Flag as "classification risk" — the competency gap may prevent effective performance at this level |
| **Strength override** | Any competency is 2+ points above expected for the suggested level | Note as "strength beyond level" — may indicate readiness for next level in that area |

### Classification Output

Present the classification as:

```markdown
## Seniority Classification

### Classification Result
**Suggested Level:** [Level]
**Confidence:** [High / Medium / Low]
**Rationale:** [1–2 sentences explaining why this level was selected]

### Distance Analysis
| Level | Weighted Distance | Notes |
|-------|-------------------|-------|
| Junior | [X.XX] | |
| Mid | [X.XX] | |
| Senior | [X.XX] | Minimum distance |
| Lead/Principal | [X.XX] | |

Keep this table in the output: it is the computation behind the suggested level.

### Flags
- [Any floor, ceiling, gap, or strength override flags]
```

**Confidence levels:**

| Confidence | Criteria |
|------------|----------|
| **High** | Minimum distance < 0.5 AND next-closest level distance > 1.0 AND no threshold flags |
| **Medium** | Minimum distance 0.5–1.0 OR next-closest level within 0.5 OR one threshold flag |
| **Low** | Minimum distance > 1.0 OR multiple threshold flags OR any competency Not assessed |
