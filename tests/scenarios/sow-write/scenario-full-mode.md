# Scenario: Full Mode SOW Generation

## Setup
Provide a project brief describing a SaaS platform for property management (fictional). Brief should include: parties, high-level scope, 3 phases, team hints, and budget range.

Use `tests/scenarios/integration/sample-brief.md` as input.

## Invocation
"Write a SOW for this project brief in full mode"

## Expected Behavior
1. Input Analysis: skill identifies document as a brief, rates maturity as "partial"
2. Mode Selection: recommends full mode (confirmed by user)
3. Language Detection: detects English
4. Clarification Round: asks 3-5 targeted questions (acceptance criteria, governance, timeline details)
5. Structure Proposal: presents 15-section outline for approval
6. Section Generation: generates sections progressively
7. Section 10 (Economics): placeholder referencing sow-estimate
8. Consistency Check: verifies cross-references
9. Output: saves to docs/outbox/

## Acceptance Criteria
- [ ] All 15 sections present in output
- [ ] Section 10 has sow-estimate placeholder (not populated)
- [ ] Deliverables in Scope (§5) match Deliverables in Phase Breakdown (§6)
- [ ] RACI roles match Team Composition
- [ ] Milestones in Schedule (§9) align with Phase Breakdown (§6)
- [ ] No vague language in scope or acceptance criteria
- [ ] Version set to v0.1.0

## Edge Cases
- Brief with very little detail → should ask more clarification questions
- Brief with conflicting information → should flag contradictions
