# Scenario: Review with Corporate Standards

## Setup
Provide:
1. A SOW document
2. A corporate standard template with: required clauses (confidentiality, IP, GDPR), formatting rules (specific numbering scheme), terminology requirements ("Committente" not "Cliente")

## Invocation
"Review this SOW against our corporate standards" (provide both files)

## Expected Behavior
1. Ingests SOW and corporate standards
2. Corporate Standards dimension is scored (not N/A)
3. Missing required clauses flagged
4. Terminology mismatches flagged
5. Formatting deviations noted

## Acceptance Criteria
- [ ] All 8 dimensions scored (including Corporate Standards)
- [ ] Standards Compliance section in report with pass/fail per item
- [ ] Specific clause references ("missing GDPR clause per corporate template §4.2")
- [ ] Terminology issues listed with correction suggestions
