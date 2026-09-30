# Spec Delta

## Purpose

Defines how the project root is found, so that a session started in a subdirectory uses the
existing project store, and records the date a stale rule was kept.

## ADDED Requirements

### Requirement: The project root is the repository's top level
The project root, where the project store lives, SHALL be the directory
`git rev-parse --show-toplevel` prints, or the working directory outside git. The skills SHALL
pre-approve `git rev-parse` so that finding the root asks for no permission. A session started in
a subdirectory of the repository SHALL use the store at the root and SHALL NOT create a second
store in the subdirectory.

#### Scenario: Session started in a subdirectory
- **WHEN** a session starts in `src/` of a repository whose root holds `.personal-voice/`, and the author revises a text with a client term
- **THEN** the observation is recorded in the root's `.personal-voice/`, no store is created under `src/`, and no project-store question is asked

## MODIFIED Requirements

### Requirement: Store language and entry format
Structure, headings and rule text SHALL be in English. Quoted expressions and exemplars SHALL
stay verbatim in their original language. An entry that depends on a language SHALL carry its
language code; an entry that depends on the audience SHALL carry an audience qualifier. Every
rule SHALL record its evidence count and the date it was last reinforced, and, once the author
kept it at a stale review, the date of that review. Every observation SHALL record its date,
source kind (revision, spoken correction or own text), language, topic, audience when known,
and the before and after excerpts or the quoted trait.

#### Scenario: Rule format
- **WHEN** a rule about closing informal Italian emails is stored
- **THEN** it reads in English, quotes the Italian expression verbatim, carries `[it]` and an
  audience qualifier, and shows its evidence count and last-reinforced date

#### Scenario: Rule kept at a stale review
- **WHEN** the author keeps a stale rule during maintenance on 2026-09-29
- **THEN** the rule keeps its text, evidence and `reinforced` date and gains `reviewed: 2026-09-29`
