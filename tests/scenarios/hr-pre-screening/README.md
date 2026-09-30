# hr-pre-screening Test Scenarios

Layer 2 scenarios for the `human-resources:pre-screening` skill. They check that a CV gap is
never a screening criterion, that salary is measured only against the band maximum and
availability only against the hiring timeline, and that the role-level base set is reused.

## Setup

1. Create a scratch output folder outside any git repository, for example `<scratch>/hr-out`.
2. Load the plugin (`claude --plugin-dir ./human-resources`) or install it from the marketplace.
3. Give the skill the band and the timeline from `fixture-jd.md` when it asks.

All fixtures are fictional and anonymized.

## Fixtures

| File | Content |
|------|---------|
| fixture-jd.md | JD for a Backend Engineer, EU (Italy), with pay band and hiring timeline |
| fixture-cv-gap.md | CV of "Candidate B" with an 18-month gap between two roles |
| fixture-cv-nogap.md | CV of "Candidate C", continuous employment, for the base-set reuse check |

## Scenarios

| File | What it tests |
|------|--------------|
| scenario-cv-gap.md | An 18-month gap is never analyzed, rated Red or used to screen out; at most one optional open question |
| scenario-salary-band.md | Salary vs band maximum, availability vs hiring timeline, CCNL notice never Red, human oversight on the threshold |
| scenario-base-set.md | `{role}-prescreening-base.md` written on the first run and reused unchanged; separate recruiter guide; privacy line |
