# Scenario: A Competency That Was Never Asked

## Setup

Output folder prepared as in the README, with `backend-engineer-seniority-matrix.md` in it.
Provide the JD summary "Backend Engineer, target level Senior" and
`fixture-notes-interviewer-1.md`. Testing (a core competency, weight 0.20) was never asked.

## Invocation

"Evaluate Candidate A after the interview — here are my notes" (as Interviewer 1). When the
skill asks about Testing, answer "we didn't get to it". When it asks about culture fit, answer
"they just felt like a good fit".

## Expected Behavior

1. Finds `backend-engineer-seniority-matrix.md` first and asks to reuse it
2. Records Testing as **Not assessed**, never as a 1
3. Renormalizes the weights of the four assessed competencies
4. Computes the weighted total, the target-level gap and the distances over assessed competencies only
5. Proposes a category and asks the interviewer to confirm it
6. Treats "great culture fit" as non-evidence and does not score it
7. Runs compliance-check last and writes `candidate-a-evaluation-interviewer-1.md`

## Expected Figures

| Competency | Score | Weight | Weight used | Weighted | Expected (Senior) | Gap |
|------------|-------|--------|-------------|----------|-------------------|-----|
| System Design | 4 | 0.30 | 0.375 | 1.50 | 4 | 0 |
| Go Programming | 5 | 0.25 | 0.3125 | 1.56 | 4 | +1 |
| Testing | Not assessed | 0.20 | — | — | 3 | — |
| API Design | 4 | 0.15 | 0.1875 | 0.75 | 4 | 0 |
| Communication | 3 | 0.10 | 0.125 | 0.38 | 4 | −1 |

Weighted total 4.19 / 5.00 (4 of 5 assessed); G = +0.19. Distances: Junior 2.75, Mid 1.56,
Senior 0.44, Lead/Principal 1.12–1.13.

## Acceptance Criteria

- [ ] The skill offers to reuse `backend-engineer-seniority-matrix.md` before proposing any new matrix
- [ ] Testing is "Not assessed" in the scores table, with no numeric score, and is listed under Evidence Coverage with a suggested follow-up
- [ ] The output contains the competency table with "Weight used" and "Weighted" columns, the target-level gap table and the distance table — not just the results
- [ ] Weighted total is 4.19 (± 0.01) and states "4 of 5 competencies assessed"
- [ ] Suggested level is **Senior**, with confidence **Low** because a competency is Not assessed
- [ ] No floor rule (Junior cap) is applied, and no "No Hire" is forced by Testing
- [ ] Computed category is **Hire** (not Strong Hire, because Communication is below the target level), and the interviewer is asked to confirm it
- [ ] The recommendation says "Based on 4 of 5 competencies"
- [ ] "Great culture fit" appears nowhere as evidence or as a concern; the skill says culture fit is not scored (and may flag similarity bias for "grab a beer")
- [ ] The file is named `candidate-a-evaluation-interviewer-1.md` and starts with the confidentiality line and a delete-by date
- [ ] Nothing about Candidate A is written to memory
- [ ] The scale anchors cited are the absolute ones (1 = no competence shown … 5 = sets direction for others)

## Variant: Insufficient Evidence

Repeat with a fresh output folder, and answer that you cannot recall Go Programming or API
Design either (Not assessed weight 0.60).

- [ ] No category is computed; the recommendation reads "Insufficient evidence — schedule a follow-up interview"
- [ ] No No Hire or Strong No Hire is proposed
