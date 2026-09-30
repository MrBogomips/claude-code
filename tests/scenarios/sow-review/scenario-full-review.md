# Scenario: Full SOW Review

## Setup
Provide a complete 15-section SOW (from sow-write output or manually created) with intentional weaknesses:
- 2 vague scope items ("appropriate solution", "user-friendly interface")
- 1 missing deliverable (in scope but not in phase breakdown)
- Risk register with only generic risks, one of them scored P×I = 10 (P 2, I 5) with no mitigation
- No escalation path in governance

## Invocation
"Review this SOW"

## Expected Behavior
1. Ingests SOW, identifies full mode (15 sections)
2. Scores all 8 dimensions (Corporate Standards as N/A)
3. Flags vague language in Clarity dimension
4. Flags missing deliverable in Consistency dimension
5. Flags generic risks in Risk Coverage dimension
6. Flags missing escalation in Collaboration Model dimension
7. Runs adversarial pass
8. Generates structured report

## Acceptance Criteria
- [ ] Scorecard has 7 scored dimensions + 1 N/A
- [ ] Clarity score <= 3 (due to vague language, with specific quotes)
- [ ] Consistency score <= 3 (due to missing deliverable)
- [ ] Risk Coverage score <= 3 (due to generic risks)
- [ ] Collaboration Model score <= 3 (due to missing escalation)
- [ ] Critical Issues section lists specific fixes
- [ ] The P×I = 10 risk is reported as a high risk without a mitigation plan
- [ ] Overall score is the average of the 7 scored dimensions, rounded to two decimals
- [ ] Overall grade uses the half-open bands: e.g. 31/7 = 4.43 → "Minor improvements recommended", 24/7 = 3.43 → "Significant gaps — revise before signing"
- [ ] Report saved to `<OutputDir>/<project-name>-sow-review.md` (with the SOW version in the name when the SOW file has one)

## Edge Cases
- Review of the same SOW run twice → the second report gets a `-2` suffix; the first is not overwritten
- SOW given as DOCX with no converter connected or installed → asks for a Markdown or PDF export
- An average of exactly 4.5 → "Ready for signature"; exactly 3.5 → "Minor improvements recommended"
