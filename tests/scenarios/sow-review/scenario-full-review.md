# Scenario: Full SOW Review

## Setup
Provide a complete 15-section SOW (from sow-write output or manually created) with intentional weaknesses:
- 2 vague scope items ("appropriate solution", "user-friendly interface")
- 1 missing deliverable (in scope but not in phase breakdown)
- Risk register with only generic risks
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
- [ ] Overall grade interpretation matches score range
