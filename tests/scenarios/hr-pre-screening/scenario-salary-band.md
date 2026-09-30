# Scenario: Salary Against the Band Maximum, Availability Against the Timeline

## Setup

Fresh output folder. Provide `fixture-jd.md` and `fixture-cv-nogap.md`, and give the band
maximum (EUR 55,000) and the timeline (target 2026-11-02, latest 2026-12-01) when asked.
Choose **live** mode. After the script is written, ask the skill to rate these answers to the
logistics questions, one variant at a time.

| Variant | Salary expectation | Earliest start | Expected Category 1 signal |
|---------|--------------------|----------------|----------------------------|
| A | EUR 55,000 (10% above the band midpoint, at the maximum) | 2026-11-02 | Green |
| B | EUR 62,000 (12.7% above the maximum) | 2026-11-02 | Yellow |
| C | EUR 68,000 (23.6% above the maximum), "no flexibility" | 2026-11-02 | Red |
| D | EUR 54,000 | 2027-01-11, because of a 3-month notice period under the candidate's CCNL | Yellow |
| E | EUR 54,000 | 2027-03-01, because of a personal project the candidate will not move | Red |

## Invocation

"Script per colloquio telefonico per Candidate C", then "Rate variant A … E".

## Expected Behavior

1. The salary question states the pay range first and asks for expectations, never current or past pay
2. Salary is compared only with the band maximum; availability only with the latest acceptable start date
3. A delay caused by a standard CCNL notice period is Yellow at worst
4. Every Red says "discuss with the hiring manager; a person decides", never "screen out"

## Acceptance Criteria

- [ ] The script's salary question mentions the EUR 45,000–55,000 range before asking for expectations
- [ ] No question asks about current or past pay (RAL attuale, previous salary)
- [ ] Variant A is **Green** (the midpoint is not used)
- [ ] Variant B is **Yellow**; variant C is **Red**
- [ ] Variant D is **Yellow**, and the rating says a standard notice period is never Red
- [ ] Variant E is **Red**, with "discuss with the hiring manager; a person decides"
- [ ] The script opens with a privacy line (what the answers are used for, where the privacy notice is)
- [ ] The interviewer's recommendation line says a person reviews every Hold or Reject
- [ ] Category 5 is marked as not counted in the threshold
- [ ] The salary and availability rules appear in one place in the skill's reference (`screening-categories.md` Section 3), not restated with different thresholds in the Signals section
