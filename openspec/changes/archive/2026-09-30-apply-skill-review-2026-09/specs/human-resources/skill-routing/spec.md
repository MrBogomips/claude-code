# Spec Delta

## Purpose

Defines which HR skill a request reaches when requests overlap, so that candidate work does not
land in the help skill and screening does not land in interview preparation.

## ADDED Requirements

### Requirement: Overlapping requests have explicit exclusions
The hr-help description SHALL trigger on which-skill and how-to questions (including "which HR
skill should I use" and "quale skill uso") and SHALL exclude preparing or evaluating a specific
candidate. The pre-screening description SHALL include "colloquio telefonico", "primo colloquio"
and "call conoscitiva" and SHALL exclude full interview preparation; the interview-prep
description SHALL exclude a first screening call. Each description SHALL put its use case and
trigger phrases first.

#### Scenario: Help with tomorrow's interview
- **WHEN** the user asks for help with tomorrow's interview with a named candidate
- **THEN** interview-prep handles it, not hr-help

#### Scenario: Phone screen in Italian
- **WHEN** the user asks for "domande per il colloquio telefonico" with a candidate's CV
- **THEN** pre-screening handles it, not interview-prep

### Requirement: Revising an existing JD goes to compliance-check
hr-help SHALL route a request to revise or audit an existing JD to compliance-check in
standalone mode (audit and clean version); job-description SHALL describe itself as writing new
JDs.

#### Scenario: Revise a JD
- **WHEN** the user asks hr-help how to revise an existing job posting
- **THEN** hr-help points to compliance-check's audit and clean version
