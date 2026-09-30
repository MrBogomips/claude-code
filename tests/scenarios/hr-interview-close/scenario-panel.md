# Scenario: Panel of Two Interviewers

## Setup

Output folder prepared as in the README. Run `scenario-not-assessed.md` first, so that
`candidate-a-evaluation-interviewer-1.md` exists, then record the fingerprint:

```bash
(cd "<scratch>/hr-out" && shasum *.md) > "<scratch>/before-panel.txt"
```

## Invocation

1. As Interviewer 2: "Evaluate Candidate A — my notes are attached" with
   `fixture-notes-interviewer-2.md`. Confirm the scores in the notes.
2. When the skill offers to consolidate, accept. When it asks about divergences, answer:
   "After reviewing the evidence the panel agrees: System Design 3, Go Programming 4,
   API Design 4, Communication 4."

## Expected Behavior

1. Writes a second file for Interviewer 2 without touching the first
2. Offers consolidation because two evaluation files now exist for Candidate A
3. Flags System Design (4 vs 2) as a divergence of 2 points and asks for an evidence review
4. Takes Testing from Interviewer 2 only (Interviewer 1 did not assess it)
5. Recomputes with the same matrix and rules, runs compliance-check, writes the consolidated file

## Expected Figures

Interviewer 2 alone: weighted total 3.05, G = −0.75, System Design 2 points below the target
level (core) → computed category **No Hire**.

Consolidated (System Design 3, Go 4, Testing 3, API Design 4, Communication 4, all assessed):
weighted total 3.50, G = −0.30 → computed category **No Hire**, which the panel may override
with a documented reason.

## Acceptance Criteria

- [ ] `candidate-a-evaluation-interviewer-2.md` is created, and `candidate-a-evaluation-interviewer-1.md` is unchanged (same checksum as in `before-panel.txt`)
- [ ] Interviewer 2's file shows weighted total 3.05 and computed category No Hire, with the computation tables
- [ ] The consolidation lists both interviewers' scores per competency, and flags System Design as the only divergence of 2 or more points
- [ ] Testing in the consolidated file is 3, taken from Interviewer 2, not Not assessed
- [ ] No half score appears in the consolidated file
- [ ] `candidate-a-evaluation-consolidated.md` shows weighted total 3.50 and G = −0.30, uses `backend-engineer-seniority-matrix.md`, and records how the divergence was resolved
- [ ] compliance-check runs on the consolidated draft before it is saved
- [ ] Both individual files are still unchanged after consolidation
- [ ] Every candidate file starts with the confidentiality line
