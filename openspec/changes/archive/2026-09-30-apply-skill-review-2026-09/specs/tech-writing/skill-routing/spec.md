# Spec Delta

## Purpose

Defines how the tech-writing descriptions are written so that they stay in the skill listing, and
how the tech-writing skills combine with a personal writing-voice skill that also matches the
request.

## ADDED Requirements

### Requirement: Descriptions lead with the use case
Each tech-writing skill description SHALL state its use case and trigger phrases before the list of
capabilities, SHALL stay within 650 characters, and SHALL parse as strict YAML.

#### Scenario: Description check
- **WHEN** the frontmatter of client-facing-doc and bid-delivery-summary is parsed with a strict YAML parser
- **THEN** it parses, and each description is at most 650 characters with its "Use when" clause in the first half

### Requirement: The deliverable's structure and style guide take precedence over a personal voice
When a personal writing-voice skill also applies to a tech-writing document, the tech-writing skill's
section plan or structure, style guide and language pack SHALL take precedence, and the personal voice
SHALL apply only where they leave room, never to the structure, the register, the verbatim texts or
the removals.

#### Scenario: Client deliverable written in the author's voice
- **WHEN** the user asks for a client-facing version and a personal-voice profile is also loaded
- **THEN** the deliverable keeps the style guide's consultative register and section structure, and the personal profile changes at most word choice within sentences
