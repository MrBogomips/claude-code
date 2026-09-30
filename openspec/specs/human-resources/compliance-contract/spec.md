# human-resources/compliance-contract Specification

## Purpose
Defines the contract between compliance-check and the HR skills that call it: the severity
levels, the call that selects embedded mode, and the point in each pipeline where it runs.

## Requirements

### Requirement: Severities are CRITICAL, WARNING and INFO only
compliance-check and every reference it loads SHALL use exactly three severities. CRITICAL
SHALL mean a direct breach of statute or GDPR, including a masculine-only or feminine-only job
title in an Italian ad, a candidate-facing form that collects data without a privacy notice,
and a pay-history question in an EU jurisdiction. WARNING SHALL mean a proxy, indirect
discrimination, a missing safeguard or a case that depends on context, including a missing pay
range in an EU JD and a question about a CV gap. INFO SHALL mean wording.

#### Scenario: Italian JD with lexicon issues
- **WHEN** an Italian ad contains "Sviluppatore", "madrelingua italiana" and "bella presenza"
- **THEN** "Sviluppatore" is CRITICAL, the other two are WARNING, each with a statute from the legal map, and no finding uses HIGH, MEDIUM or LOW

#### Scenario: Pay-history question
- **WHEN** an EU screening questionnaire asks "Qual è la tua RAL attuale?"
- **THEN** the finding is CRITICAL and cites Directive 2023/970 Art. 5(2)

### Requirement: Embedded mode is selected by an explicit call
Calling skills SHALL load compliance-check with the Skill tool and the arguments
`embedded <document_type>[,<document_type>...] [<jurisdiction>]`, where `document_type` is one or
more of `jd`, `questionnaire`, `interview_questions`, `position_assessment`, `evaluation_form`,
`other`. compliance-check SHALL use embedded mode only when its arguments start with `embedded`;
in embedded mode it SHALL return a findings list, ask no question and write no file.

#### Scenario: Direct user request
- **WHEN** the user asks "check this JD for compliance"
- **THEN** compliance-check runs in standalone mode and writes an audit report that says it is not legal advice

### Requirement: Compliance runs last in every calling skill
job-description, pre-screening, interview-prep and interview-close SHALL run compliance-check
after every other change to their draft, including interview-prep's redundancy rewrite and
interview-close's corporate template adaptation, and SHALL write their files only after it.

#### Scenario: Corporate template with a culture-fit field
- **WHEN** interview-close adapts the evaluation to a corporate template that has a "culture fit" field
- **THEN** the adapted text is checked by compliance-check before the file is written
