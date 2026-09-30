# Scoring Rubric — Behaviorally Anchored Rating Scale (BARS)

## 1. The 1-5 BARS Scale

Every competency assessed during the interview is scored on the plugin's **canonical absolute 1–5 scale**, defined once in the interview-close skill: `../../interview-close/references/evaluation-template.md` Section 3. Read the anchors there; this file does not restate them. In short: 1 = no competence shown, 2 = basic with guidance, 3 = independent, 4 = advanced and guides others, 5 = sets direction for others, and **Not assessed** when no evidence was collected (never a 1).

The anchors are the same for every role and level. What changes by level is the **expected** score, which comes from the seniority matrix for the role (`{role}-seniority-matrix.md` in the output folder, once interview-close has saved one). A "good" answer for a role is one at the expected score; an "excellent" one is a point above it.

Interviewers must cite specific candidate statements or observed behaviors to justify their score.

### Half-Point Guidance

When a response falls between two levels, interviewers may use half-points (e.g., 3.5) during note-taking, but final calibrated scores use whole numbers. During calibration, round to the score whose anchors best match the evidence.

---

## 2. Per-Competency Scoring

The canonical anchors apply uniformly; the notes below show what each score looks like for common competency types. They follow the same levels: absent, basic with guidance, independent, advanced and guiding others, setting direction.

### Technical Competency

| Score | What It Looks Like |
|-------|-------------------|
| **5** | Sets technical direction for a team or organization: chose between architectures with explicit trade-offs, defined standards others adopted, and quantifies the technical impact (performance, cost, reliability). |
| **4** | Solves complex or ambiguous technical problems on their own and guides others: explains the approach, the alternatives considered and why, and has reviewed or mentored others' work. |
| **3** | Works independently on standard technical tasks: describes their own implementation clearly, with the reasoning behind the main choices. |
| **2** | Handles basic tasks with guidance: can describe what was done, but not the technical reasoning; may confuse related technologies or describe following instructions. |
| **1** | Shows no competence in the area: cannot give a relevant technical example despite probing, or reveals a fundamental misunderstanding. |

### Leadership Competency

| Score | What It Looks Like |
|-------|-------------------|
| **5** | Sets direction for teams or the organization: led through ambiguity or significant change, shaped how others work, and quantifies team outcomes (delivery, retention, growth). |
| **4** | Leads a team or initiative through complex situations: describes how they motivated, guided or developed others, the decisions made and why, and stakeholder perspectives. |
| **3** | Leads independently in standard situations: coordinates work and people for a deliverable, with a clear account of their own role. |
| **2** | Takes on leadership tasks with guidance: describes being in a leadership role but little of their own influence on others. |
| **1** | Shows no leadership competence: cannot give an example, or describes situations that reveal poor leadership judgment (e.g., taking credit for team work, not supporting team members). |

### Communication Competency

| Score | What It Looks Like |
|-------|-------------------|
| **5** | Sets how others communicate: shapes messages for executives, clients or the organization, handles high-stakes conversations, and shows the impact (buy-in secured, conflict resolved, alignment improved). |
| **4** | Adapts style to different audiences in complex situations (technical vs. executive, internal vs. external) and handles difficult conversations with clarity. |
| **3** | Communicates clearly and independently in standard situations: describes the audience, the message and the approach. |
| **2** | Handles routine communication (status updates, emails) with guidance; struggles to give a specific example of tailoring a message. |
| **1** | Shows no competence in the area: cannot give a relevant example despite probing. |

### Domain Expertise

| Score | What It Looks Like |
|-------|-------------------|
| **5** | Sets direction in the domain: uses knowledge of trends, regulation and the competitive landscape to drive strategic decisions with measurable outcomes. |
| **4** | Applies deep domain knowledge to complex problems and advises others: explains the domain's key concepts and challenges and how they shaped a solution. |
| **3** | Applies domain knowledge independently to standard problems, following sound practice. |
| **2** | Knows the domain's basics and applies them with guidance; may confuse key concepts. |
| **1** | Shows no competence in the domain: cannot demonstrate relevant knowledge despite probing. |

---

## 3. Evidence Requirement

**Every score must be justified with specific evidence from the interview.** This is a non-negotiable rule for scoring integrity.

### What Counts as Evidence

| Evidence Type | Example | Strength |
|---------------|---------|----------|
| **Direct quote** | "The candidate said: 'I redesigned the pipeline, reducing processing time from 4 hours to 20 minutes'" | Strongest — exact words leave no room for interpretation |
| **Specific behavior description** | "Candidate described building a circuit breaker pattern with failover to handle provider outages" | Strong — specific enough to verify the competency |
| **Paraphrased claim with context** | "Candidate described leading a team of 8 through a migration project, focusing on their role in stakeholder communication" | Acceptable — sufficient detail to calibrate |
| **General impression** | "Seemed knowledgeable about distributed systems" | **Not acceptable** — too subjective, not anchored to specific statements |

### Scoring Documentation Format

For each competency scored, the interviewer must record:

```
Competency: [name]
Score: [1-5, or Not assessed]
Evidence: [specific candidate statement or behavior that justifies this score]
Follow-up notes: [any additional context from probing]
```

---

## 4. Calibration Guidance

Calibration ensures interviewers interpret the canonical 1-5 scale consistently. Without calibration, the same answer may receive a 3 from one interviewer and a 5 from another.

### Pre-Interview Calibration

Before interviews begin (ideally during the interview-prep stage):

1. **Review the anchors together** — all interviewers read the canonical scale and the per-competency calibration notes
2. **Score a sample answer** — present a written example answer and have each interviewer score independently, then compare and discuss
3. **Agree on the neighboring anchors** — most divergence is between adjacent scores (3 vs. 4 especially); align on what separates "independent" from "advanced and guides others"
4. **Clarify role-level expectations** — a "4" means the same for every role; what differs is the expected score for the target level. Agree on the expected score per competency from the seniority matrix

### Post-Interview Calibration

After all interviewers have completed their assessments:

1. **Independent scoring first** — each interviewer writes their own evaluation (interview-close saves one file per interviewer) before group discussion to prevent anchoring
2. **Compare scores per competency** — identify divergences of 2+ points
3. **Evidence review** — for divergent scores, each interviewer presents their evidence; the group determines which score best fits the evidence
4. **Consensus or majority** — aim for consensus; if not achievable, use the median score with a note explaining the divergence
5. **Document the calibration outcome** — record final scores with the supporting evidence that drove the calibration decision

### Common Calibration Pitfalls

| Pitfall | Description | Mitigation |
|---------|-------------|------------|
| **Score inflation** | Interviewers default to the expected score for the role, rarely using the rest of the scale | Score against the anchors first; compare with the expected score only afterwards |
| **Central tendency** | All scores cluster around one value regardless of answer quality | Review the anchors; ask "which of the two neighboring anchors fits the evidence better?" |
| **Different baselines** | One interviewer compares to ideal, another to minimum | The anchors are the baseline; the matrix, not the interviewer, says what the role needs |
| **Missing evidence scored low** | A competency the interview did not cover gets a 1 or 2 | Record it as Not assessed; it is left out of the weighted total |
| **Weighting confusion** | Interviewers inflate scores for competencies they personally value | Use the priority weighting from the question plan, not personal preference |

---

## 5. Bias Awareness

Cognitive biases systematically distort interview scoring. Awareness is the first line of defense; structured scoring with evidence requirements is the second.

### Halo / Horn Effect

**Halo:** A strong answer on one competency inflates scores on subsequent competencies. The interviewer forms a positive overall impression and unconsciously rates everything higher.

**Horn:** A weak answer on one competency deflates subsequent scores. The interviewer forms a negative impression and unconsciously rates everything lower.

**Mitigation:**
- Score each competency independently, immediately after the relevant question
- Do not assign an overall score until all individual competency scores are recorded
- Review scores at the end: if all scores are identical (e.g., all 4s), challenge whether the evidence truly supports the same level across every competency (interview-close flags this as "low differentiation")

### Recency Bias

The interviewer gives disproportionate weight to the most recent answer, underweighting earlier responses.

**Mitigation:**
- Take notes during the interview, not just after
- Score each question immediately after it is answered
- During calibration, review early answers with the same rigor as late ones

### Similarity Bias (Affinity Bias)

The interviewer unconsciously favors candidates who share their background, education, interests, communication style, or demographic characteristics.

**Mitigation:**
- Focus on behavioral evidence, not personal rapport
- Ask: "Am I scoring the answer or the person?"
- Structured scoring with evidence requirements reduces the opportunity for affinity to influence scores
- In panel interviews, diverse interviewer composition helps counterbalance individual biases

### Confirmation Bias

The interviewer forms an early impression (from CV review, first impression, or pre-screening results) and unconsciously seeks evidence that confirms it, while discounting contradictory evidence.

**Mitigation:**
- Approach each question as independent evidence collection
- Actively look for disconfirming evidence: if your impression is positive, pay extra attention to weak answers; if negative, pay extra attention to strong answers
- Record both supporting and contradicting evidence in notes

### Contrast Effect

The interviewer's scoring is influenced by the previous candidate rather than the absolute scale. A mediocre candidate looks strong after a weak one; a strong candidate looks average after an exceptional one.

**Mitigation:**
- Score against the canonical anchors, not against other candidates
- Complete scoring for each candidate before interviewing the next
- During calibration, reference the behavioral anchors, not comparisons between candidates

### Attribution Bias

The interviewer attributes the candidate's successes to external factors ("they were lucky", "the team was strong") while attributing failures to internal factors ("they made a bad decision"), or vice versa depending on the interviewer's initial impression.

**Mitigation:**
- Use follow-up probes to understand the candidate's specific contribution to both successes and failures
- Evaluate the candidate's actions and decisions, not just outcomes
- Give equal weight to how the candidate handled failures and what they learned
