# Spec Delta

## Purpose

Defines which content-type file applies, and how the profile combines with another skill or
template that already fixes the text's structure, register or terminology.

## MODIFIED Requirements

### Requirement: Loading order and precedence
The skill SHALL combine, in this order: `core.md`, the language file, up to two topic files,
the project glossary and content-type file when a project store exists, and exemplars. A
content-type file SHALL be loaded only when a slug present in the project store's
`content-types/` names the text's document type, together with `content-types/general.md`. When
entries conflict, the more specific SHALL win: project over topic, topic over language,
language over core, and the primary topic over the secondary one.

#### Scenario: Project term overrides a topic term
- **WHEN** the topic file prefers "deploy" and the project glossary prefers "rilascio"
- **THEN** text written in that project uses "rilascio"

#### Scenario: No matching content type
- **WHEN** the project store holds only `content-types/status-report.md` and Claude writes a notice email
- **THEN** the status-report conventions are not applied

## ADDED Requirements

### Requirement: Other skills and templates take precedence
When another skill, a template or the project's conventions fix the text's structure, register
or terminology, the write skill SHALL follow them, SHALL apply the profile only where they leave
room, SHALL NOT rephrase their verbatim texts, and SHALL set aside a profile rule that
contradicts them for that text. The write skill's description SHALL say so.

#### Scenario: Client deliverable from a document skill
- **WHEN** a document skill with its own style guide writes a client deliverable and the write skill also loads
- **THEN** the deliverable keeps the document skill's structure, register and verbatim notices, and the profile shows at most in word choice
