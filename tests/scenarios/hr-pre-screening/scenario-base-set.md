# Scenario: Role-Level Base Set and Separate Recruiter Guide

## Setup

Fresh output folder, containing no `backend-engineer-prescreening-base.md`.

## Invocation

1. "Screening questions for Candidate B" with `fixture-jd.md` and `fixture-cv-gap.md`, **async** mode.
2. Record the fingerprint: `(cd "<scratch>/hr-out" && shasum *.md) > "<scratch>/after-first.txt"`
3. "Screening questions for Candidate C" with `fixture-jd.md` and `fixture-cv-nogap.md`, **async** mode.

## Expected Behavior

1. First run: generates Categories 1, 3, 4 and 5, shows them, and saves `backend-engineer-prescreening-base.md` once confirmed
2. First run writes `candidate-b-prescreening.md` (to send) and `candidate-b-prescreening-guide.md` (recruiter only)
3. Second run: finds the base file, reuses Categories 1, 3, 4 and 5 unchanged, and generates only Category 2 from Candidate C's CV
4. compliance-check runs last, with the questionnaire and the guide

## Acceptance Criteria

- [ ] `backend-engineer-prescreening-base.md` exists after the first run and holds no candidate name or CV detail
- [ ] The second run says it reused the base set, and the base file's checksum equals the one in `after-first.txt`
- [ ] The Category 1, 3, 4 and 5 questions in `candidate-c-prescreening.md` are word for word those in `candidate-b-prescreening.md`
- [ ] Only the Experience Alignment questions differ between the two candidates
- [ ] `candidate-*-prescreening.md` contain no rationale, no Green/Yellow/Red guidance and no threshold; they carry the privacy notice and the pay range
- [ ] `candidate-*-prescreening-guide.md` hold the alignment summary, the signals and the threshold, start with the confidentiality line, and state that a person reviews every Hold or Reject
- [ ] Every run keeps the total at 12 questions or fewer
