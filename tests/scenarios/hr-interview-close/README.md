# hr-interview-close Test Scenarios

Layer 2 scenarios for the `human-resources:interview-close` skill. They check the canonical
absolute scale, the "Not assessed" status, the computation tables, the per-interviewer files
and the panel consolidation.

## Setup

1. Create a scratch output folder outside any git repository, for example `<scratch>/hr-out`.
2. Copy `fixture-matrix.md` into it as `backend-engineer-seniority-matrix.md`.
3. Record a fingerprint of the folder before each run, to check which files change:
   ```bash
   (cd "<scratch>/hr-out" && shasum *.md) > "<scratch>/before.txt"
   ```
4. Load the plugin (`claude --plugin-dir ./human-resources`) or install it from the marketplace.

Candidate: "Candidate A". Role: "Backend Engineer". Target level: Senior. Interview format:
panel, two interviewers ("Interviewer 1", "Interviewer 2"). All fixtures are fictional.

## Fixtures

| File | Content |
|------|---------|
| fixture-matrix.md | Confirmed seniority matrix for the role, with weights and core competencies |
| fixture-notes-interviewer-1.md | Interviewer 1's notes; Testing was never asked |
| fixture-notes-interviewer-2.md | Interviewer 2's notes; covers Testing, diverges on System Design |

## Scenarios

| File | What it tests |
|------|--------------|
| scenario-not-assessed.md | A competency never asked is Not assessed: renormalized weights, Low confidence, no forced No Hire or Junior cap; culture fit never triggers Strong No Hire; insufficient evidence |
| scenario-panel.md | Two interviewers produce two files; consolidation resolves a divergence and leaves the individual files unchanged |
