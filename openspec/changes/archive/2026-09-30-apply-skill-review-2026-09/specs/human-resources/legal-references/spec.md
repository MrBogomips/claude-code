# Spec Delta

## Purpose

Defines where the HR plugin's legal content lives and what it says about protected grounds,
pay transparency and AI-assisted screening, so that corrections reach every skill at once.

## ADDED Requirements

### Requirement: One ground-to-statute map
compliance-check's `references/legal-map.md` SHALL be the only file that maps a protected ground
to its statute: race and ethnic origin to D.Lgs. 215/2003; religion or belief, disability, age
and sexual orientation to D.Lgs. 216/2003; sex and gender to D.Lgs. 198/2006; political opinion
and trade-union membership to L. 300/1970 Art. 8 and Art. 15; nationality to D.Lgs. 286/1998
Art. 43; targeted disability hiring to L. 68/1999. Other files SHALL name the ground and point to
the map. The genuine occupational requirement SHALL be cited as Art. 3(3) of D.Lgs. 215/2003 and
D.Lgs. 216/2003.

#### Scenario: Age finding
- **WHEN** compliance-check flags an age proxy in an Italian JD
- **THEN** the citation is D.Lgs. 216/2003, not D.Lgs. 215/2003 or D.Lgs. 198/2006

### Requirement: Pay transparency is covered
The legal map SHALL describe Directive 2023/970 Art. 5 (pay range before the interview, no
pay-history questions, gender-neutral notices) with a note to check the current national
transposition. job-description SHALL ask for the pay range and warn in EU jurisdictions when it
is missing.

#### Scenario: JD without a pay range
- **WHEN** job-description drafts an EU JD and the user gives no pay range
- **THEN** compliance-check returns a WARNING citing Directive 2023/970 Art. 5(1), and the output summary lists the range as a remaining placeholder

### Requirement: AI-assisted screening and legal disclaimers
The legal map SHALL note GDPR Art. 22 human review and the AI Act high-risk classification of
recruitment AI, and the privacy-notice template SHALL include a disclosure line for AI-assisted
tools. Every legal reference file and every standalone audit report SHALL state that the content
is not legal advice and should be verified with counsel.

#### Scenario: Standalone audit
- **WHEN** compliance-check writes a standalone audit report
- **THEN** the report states that the findings are not legal advice
