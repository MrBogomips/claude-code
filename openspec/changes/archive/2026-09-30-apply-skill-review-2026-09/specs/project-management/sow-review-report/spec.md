# Spec Delta

## Purpose

Defines how sow-review maps the overall score to a grade and which language its report uses.

## ADDED Requirements

### Requirement: Grade bands are half-open
sow-review SHALL map the overall score, the average of the scored dimensions, to a grade with
bands that include their lower bound: ≥ 4.5 ready for signature, ≥ 3.5 minor improvements,
≥ 2.5 significant gaps, ≥ 1.5 major rework, below 1.5 fundamental issues.

#### Scenario: Average between two bands
- **WHEN** seven scored dimensions sum to 31 (average 4.43)
- **THEN** the grade is "Minor improvements recommended"

#### Scenario: Average on a boundary
- **WHEN** the average is exactly 3.5
- **THEN** the grade is "Minor improvements recommended"

### Requirement: The report is written in the SOW's language
sow-review SHALL write the report, including headings, dimension names and the grade label, in
the dominant language of the reviewed SOW.

#### Scenario: Italian SOW
- **WHEN** the reviewed SOW is in Italian
- **THEN** the report is in Italian and names the dimensions Completezza, Chiarezza, Coerenza, Copertura dei rischi, Adeguatezza commerciale, Modello di collaborazione, Aderenza alle best practice, Standard aziendali
