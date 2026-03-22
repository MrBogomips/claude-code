# Scenario: Summary Mode SOW Generation

## Setup
Provide a contract document (or contract excerpt) describing an existing service agreement. The contract should reference deliverables, payment terms, and SLAs.

Use `tests/scenarios/integration/sample-contract.md` as input.

## Invocation
"Create a summary SOW from this contract"

## Expected Behavior
1. Input Analysis: identifies document as a contract, rates maturity as "rich"
2. Mode Selection: recommends summary mode
3. Language Detection: auto-detects from contract language
4. Clarification Round: minimal (1-2 questions, since contract is detailed)
5. Structure Proposal: presents 9-section outline
6. Section Generation: extracts and structures content from contract
7. Consistency Check: verifies cross-references to parent contract
8. Output: saves to docs/outbox/

## Acceptance Criteria
- [ ] All 9 sections present
- [ ] Section 1 (Contract References) traces to source contract
- [ ] Section 3 (Deliverables) extracted accurately from contract
- [ ] Section 4 (Milestones & Billing) amounts reconcile with contract
- [ ] Section 9 (Cross-references) links each SOW section to contract clauses
- [ ] No invented content — everything traceable to source

## Edge Cases
- Contract in Italian → should produce Italian output
- Contract with ambiguous deliverables → should ask for clarification
