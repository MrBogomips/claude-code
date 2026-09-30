# human-resources/evaluation-scoring Specification

## Purpose
Defines the single scoring scale of the human-resources plugin and how interview-close turns
scores into a seniority level and a recommendation, including competencies with no evidence
and panels of several interviewers.

## Requirements

### Requirement: One absolute 1–5 scale, defined in one file
The scale SHALL be defined only in interview-close's `references/evaluation-template.md`
Section 3, with absolute anchors: 1 = no competence shown, 2 = basic with guidance,
3 = independent, 4 = advanced and guides others, 5 = sets direction for others. Every other file
that uses the scale (the interview-prep scoring rubric and templates, interview-close SKILL.md,
the seniority matrix template, METHODOLOGY.md) SHALL point to it and SHALL NOT define other
anchors. The expected score for a level SHALL come from the seniority matrix. interview-prep's
good and excellent answer examples SHALL be set at the expected score for the target level and
one point above it.

#### Scenario: A Lead who meets expectations
- **WHEN** a Lead/Principal candidate scores at the matrix values for Lead/Principal
- **THEN** the candidate is classified Lead/Principal, not Mid or Senior

### Requirement: No evidence is "Not assessed", never a score
A competency without evidence SHALL be recorded as Not assessed. It SHALL be left out of the
weighted total, the target-level gap, the distances and every threshold rule; the remaining
weights SHALL be renormalized; the classification confidence SHALL be Low; and it SHALL never
force No Hire or a Junior cap. When Not assessed competencies carry more than half the weight,
no category SHALL be computed ("Insufficient evidence").

#### Scenario: A core competency was never asked
- **WHEN** Testing (core, weight 0.20) was not covered and the other four competencies were scored 4, 5, 4, 3
- **THEN** Testing is Not assessed, the weights of the other four are divided by 0.80, the confidence is Low, and the computed category is Hire rather than a forced No Hire

### Requirement: The recommendation compares scores with the target level and shows its computation
The recommendation SHALL be computed from the gap between each score and the expected score for
the target level, with the rules in `evaluation-template.md` Section 6, and SHALL be confirmed or
overridden by the interviewer. The output SHALL include the competency table with the weights
used, the target-level gap table and the distance table. Only a documented conduct concern
(dishonesty, hostility or harassment, discriminatory remarks) SHALL force Strong No Hire;
culture fit, "values alignment", demeanor and body language SHALL NOT.

#### Scenario: Interviewer says "not a culture fit"
- **WHEN** the interviewer's only negative remark is about culture fit
- **THEN** the remark is not used as evidence or as a conduct concern, and the category comes from the scores

### Requirement: One evaluation file per interviewer, with optional consolidation
interview-close SHALL collect the JD and one interviewer's notes per run, and SHALL write
`{candidate}-evaluation-{interviewer}.md`. When two or more such files exist for a candidate, it
SHALL offer a consolidation that compares scores per competency, asks for an evidence review of
any divergence of 2 or more points, recomputes with the same matrix, and writes
`{candidate}-evaluation-consolidated.md` without changing the individual files.

#### Scenario: Second panel member
- **WHEN** a second interviewer evaluates the same candidate
- **THEN** a second file is written and the first interviewer's file is unchanged

### Requirement: The confirmed seniority matrix is saved per role and reused first
interview-close SHALL look for `{role}-seniority-matrix.md` in the output folder before using a
corporate matrix or generating one, and SHALL save every newly confirmed or edited matrix there.
interview-prep SHALL read it, when present, for the expected scores.

#### Scenario: Next candidate for the role
- **WHEN** interview-close runs for another candidate and `{role}-seniority-matrix.md` exists
- **THEN** it offers that matrix before proposing any other
