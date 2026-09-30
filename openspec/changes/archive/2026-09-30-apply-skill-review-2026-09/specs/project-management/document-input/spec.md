# Spec Delta

## Purpose

Defines how the SOW skills read inputs that are not Markdown.

## ADDED Requirements

### Requirement: DOCX inputs are converted or replaced, never guessed
sow-write, sow-review and sow-estimate SHALL read Markdown and PDF inputs directly. For a DOCX
input they SHALL use a connected `~~document converter`; otherwise look for a converter command
on the system and ask before running it; otherwise ask the user for a Markdown or PDF export.

#### Scenario: DOCX with no converter
- **WHEN** sow-review receives a DOCX file and no converter is connected or installed
- **THEN** it asks for a Markdown or PDF export and does not score the document

#### Scenario: Converter found on the system
- **WHEN** sow-estimate receives a DOCX file and `markitdown` is on PATH
- **THEN** it asks the user before running the conversion
