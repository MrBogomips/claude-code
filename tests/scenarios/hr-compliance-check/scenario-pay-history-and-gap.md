# Scenario: Pay History and CV-Gap Questions

## Setup

Provide `fixture-questionnaire-it.md`, a candidate-facing questionnaire for an Italian
employer. It asks for current pay (Q2), asks about a specific CV gap (Q3), and has no
privacy notice.

## Invocation

"Verifica discriminazioni in questo questionario" with the fixture attached.

## Expected Behavior

1. Classifies the document as a screening questionnaire, jurisdiction Italy
2. Flags the pay-history question under the EU Pay Transparency Directive
3. Flags the gap question as a proxy for protected grounds
4. Flags the missing privacy notice on a form that collects answers
5. Leaves the salary-expectations question (Q5) alone, or suggests stating the pay range first

## Acceptance Criteria

- [ ] Q2 "Qual è la tua RAL attuale?" is **CRITICAL**, citing Directive 2023/970 Art. 5(2); the fix removes it and suggests stating the pay range before asking for expectations
- [ ] Q3 (gap question) is **WARNING**, as a proxy for pregnancy, maternity or paternity, health, disability or caregiving, citing the statutes of those grounds from the legal map (D.Lgs. 198/2006 Art. 27(2)(a) and/or D.Lgs. 216/2003)
- [ ] The fix for Q3 is at most one optional, open career-path question for every candidate, not a reworded question about the gap
- [ ] Missing privacy notice is **CRITICAL** (a candidate-facing form that collects data), citing GDPR Art. 13 or Arts. 12–14
- [ ] Q5 (expectations) is not flagged as pay history
- [ ] Q1 is not flagged
- [ ] Overall status is **Fail**
- [ ] If a clean version is requested, it has no pay-history question, no gap question, a privacy notice reference, and states the pay range before Q5
