# human-resources/candidate-screening Specification

## Purpose
Defines how pre-screening and interview-prep treat CV gaps, salary, availability and the base
question set, so that screening stays job-relevant, consistent across candidates and decided by
a person.

## Requirements

### Requirement: A CV gap is never a screening criterion
pre-screening and interview-prep SHALL NOT analyze, rate, list as a risk, or plan a question
about a gap in a candidate's CV or its reason. They MAY include at most one optional, open
career-path question, with the same wording for every candidate, and that question SHALL NOT
be rated. A protected reason the candidate volunteers (health, pregnancy, disability,
caregiving, family) SHALL NOT be recorded.

#### Scenario: CV with an 18-month gap
- **WHEN** pre-screening runs on a CV with no work listed for 18 months
- **THEN** no question names the gap or its dates, no signal or threshold refers to it, and the candidate is never marked Red or screened out because of it

#### Scenario: Candidate volunteers a protected reason
- **WHEN** the candidate answers the optional career-path question by mentioning caring for a family member and a course they took
- **THEN** the notes keep the course and do not record the caregiving

### Requirement: Salary and availability have one rule each
Salary expectations SHALL be compared only with the band maximum: at or below it is Green, up
to 20% above it is Yellow, more than 20% above it with no flexibility is Red. Availability
SHALL be compared only with the hiring timeline, and a delay caused by a standard CCNL notice
period SHALL never be Red. Each rule SHALL be stated once, in the screening-categories
reference. The salary question SHALL state the pay range first and SHALL NOT ask about current
or past pay.

#### Scenario: Expectation at the band maximum
- **WHEN** the band is EUR 45,000–55,000 and the candidate expects EUR 55,000
- **THEN** the salary signal is Green, although the expectation is 10% above the midpoint

#### Scenario: Start delayed by a CCNL notice period
- **WHEN** the candidate's earliest start is after the latest acceptable date only because of a standard notice period
- **THEN** the availability signal is Yellow, not Red

### Requirement: The base question set is shared by every candidate for a role
pre-screening SHALL look for `{role}-prescreening-base.md` in the output folder. If it exists,
the skill SHALL reuse its Categories 1, 3, 4 and 5 unchanged; if not, it SHALL generate them,
and save them once the user confirms. Only Category 2 SHALL vary with the CV. A change to the
base set SHALL be saved only after the user confirms it applies to all later candidates.

#### Scenario: Second candidate for the same role
- **WHEN** pre-screening runs for a second candidate and `{role}-prescreening-base.md` exists
- **THEN** Categories 1, 3, 4 and 5 are word for word those of the first candidate and the base file is unchanged

### Requirement: Screening signals are suggestions reviewed by a person
The recruiter guide SHALL be a separate file from the questionnaire sent to the candidate. The
suggested threshold SHALL count only Categories 1–4, and every threshold, Red signal and
Proceed / Hold / Reject line SHALL state that a person reviews every Hold or Reject. The live
script SHALL open with a privacy line.

#### Scenario: Async questionnaire
- **WHEN** async mode is selected
- **THEN** `{candidate}-prescreening.md` holds the instructions, privacy notice, pay range and questions only, and `{candidate}-prescreening-guide.md` holds the signals and the threshold with the human-review statement
