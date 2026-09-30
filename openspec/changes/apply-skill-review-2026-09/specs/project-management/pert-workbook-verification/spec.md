# Spec Delta

## Purpose

Defines how pmo-pert-estimate obtains the figures it reports and verifies the workbook it
generates, given that openpyxl writes formula strings without computed values.

## ADDED Requirements

### Requirement: Figures come from the bundled summarizer, never from the workbook
The skill SHALL take every figure it reports (rollups, Low / Medium / High Band, contingency,
Management Reserve, calendar duration, risk counts) from the output of `scripts/summarize.py`,
which computes them from `excel-input.json` with the generator's formulas. It SHALL NOT read
numbers back from the generated workbook.

#### Scenario: Final statistics after generation
- **WHEN** Phase 6 presents the result of an estimate
- **THEN** each figure shown equals the matching value in `summary.json`, and the Medium Band equals Low Band + Low Band × MR%

#### Scenario: Rollup sigma matches the workbook
- **WHEN** a phase has leaf durations O and P summing to ΣO and ΣP
- **THEN** the summarizer reports the phase σ as (ΣP − ΣO) / 6, the linear sum the WBS rollup row computes

### Requirement: The workbook is checked statically against its input
`summarize.py --workbook` SHALL compare each formula cell with the documented pattern at the row
the JSON layout implies, and SHALL fail with exit code 2 and a `Sheet!Cell` message when a formula
cell holds a value, a rollup range is wrong, an input cell is empty, an error token such as
`#REF!` appears, the sheet order differs, or a ratio or calendar value no longer matches the
input. A fix SHALL go through `excel-input.json` and regeneration, not through edits to the
workbook.

#### Scenario: Hardcoded value in a formula cell
- **WHEN** the PERT cell of a leaf row holds a number instead of `=(E{r}+4*F{r}+G{r})/6`
- **THEN** the check exits with code 2 and names that cell

#### Scenario: Freshly generated workbook
- **WHEN** the check runs on a workbook just generated from the same input
- **THEN** it exits with code 0 and reports no errors

### Requirement: Recalculation is optional and used only when LibreOffice is found
With `--recalc`, the summarizer SHALL recalculate a copy with LibreOffice when `soffice` or
`libreoffice` is on PATH and compare the band values with its own figures; when neither is found
it SHALL report the recalculation as skipped without failing.

#### Scenario: No LibreOffice installed
- **WHEN** `--recalc` is given on a system without LibreOffice
- **THEN** the result reports `recalc` as `skipped` and the exit code depends only on the static checks

### Requirement: The input is validated before generation
The summarizer SHALL reject, with exit code 1 and the offending key named, an input missing a
required key of the documented schema, with inverted three-point values, with a ratio written as
a percentage (for example 10 instead of 0.10), or with a work package without activities. It
SHALL report as warnings the keys the generator does not read and the leaf activities whose
most-likely effort is outside 1–10 PD (the 8/80 rule).

#### Scenario: Percentage given instead of a ratio
- **WHEN** `config.management_reserve_pct` is 10
- **THEN** validation exits with code 1 and says to write 0.1

#### Scenario: Activity above 10 PD
- **WHEN** a leaf activity has a most-likely effort of 12 PD
- **THEN** the summary carries an 8/80 warning naming that activity, and generation is not blocked

### Requirement: Python and openpyxl are checked before they are needed
Phase 0 SHALL run `python3 -c "import openpyxl"`. When it fails, the skill SHALL ask the user
whether to install openpyxl with `python3 -m pip install --user openpyxl` or to continue and stop
after writing `excel-input.json`, and SHALL NOT install anything without that consent.

#### Scenario: openpyxl missing and install declined
- **WHEN** the check fails and the user declines the installation
- **THEN** the skill runs Phases 1–4, writes `excel-input.json` in Phase 5, stops, and gives the commands to generate and check the workbook later
