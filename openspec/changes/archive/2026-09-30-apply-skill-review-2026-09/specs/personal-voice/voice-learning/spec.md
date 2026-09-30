# Spec Delta

## Purpose

Keeps client and project names out of the exemplars, which live in the global store and guide
texts in every project.

## MODIFIED Requirements

### Requirement: Learning from the author's own texts
The skill SHALL accept texts the author wrote without AI, pasted or given as files, and record
the traits they show as observations. It MAY keep short excerpts as exemplars in the global
store, tagged with topic, language, audience and source. An exemplar SHALL be a passage without
client or project names and without other people's contact details; when a text has no such
passage, the skill SHALL keep no exemplar from it and SHALL still record its traits.

#### Scenario: Bootstrap from old emails
- **WHEN** the author gives three emails they wrote to clients
- **THEN** observations are recorded for the traits the emails share
- **AND** excerpts are kept as exemplars tagged with the topic, the language and the audience

#### Scenario: Every passage names the client
- **WHEN** the author gives an own email in which every paragraph names the client or the project
- **THEN** its traits are recorded as observations and no exemplar is kept from it
