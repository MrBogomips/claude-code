# Spec Delta

## Purpose

Makes the text Claude writes for people follow the author's promoted tone and lexicon for the
language, topic, audience and project at hand.

## ADDED Requirements

### Requirement: When the profile applies
The profile SHALL apply whenever Claude writes text meant to be read by people (documents,
reports, emails, messages, posts), in any project and in any language, and when the user
invokes the write skill explicitly. It SHALL NOT apply by default to code, code comments,
commit messages or configuration files.

#### Scenario: Email draft
- **WHEN** the user asks Claude to draft an email to a colleague
- **THEN** Claude applies the author's profile to the draft

#### Scenario: Commit message
- **WHEN** Claude writes a commit message
- **THEN** the profile is not applied

### Requirement: Language detected automatically
The skill SHALL write in the language the request or its context calls for and SHALL load the
matching language file when one exists, without any language configuration.

#### Scenario: Text in a language with no file yet
- **WHEN** Claude writes in a language that has no language file
- **THEN** it applies `core.md` and the topic and project entries that are not tied to
  another language

### Requirement: Topic and audience resolution
The skill SHALL infer the topic and the audience from the request and its context. It SHALL
use at most two topics, the first being the primary. When the topic or the audience is
uncertain, it SHALL ask one short question before writing. The answer MAY name a topic that
does not exist yet.

#### Scenario: Uncertain topic
- **WHEN** a request could belong to more than one topic and the context does not settle it
- **THEN** Claude asks one short question naming the candidate topics before writing

### Requirement: Loading order and precedence
The skill SHALL combine, in this order: `core.md`, the language file, up to two topic files,
the project glossary and content-type file when a project store exists, and exemplars. When
entries conflict, the more specific SHALL win: project over topic, topic over language,
language over core, and the primary topic over the secondary one.

#### Scenario: Project term overrides a topic term
- **WHEN** the topic file prefers "deploy" and the project glossary prefers "rilascio"
- **THEN** text written in that project uses "rilascio"

### Requirement: Exemplars matched by language
The skill SHALL prefer exemplars written in the target language. Exemplars in other languages
SHALL guide only rhythm and structure, never wording.

#### Scenario: No exemplar in the target language
- **WHEN** the only exemplars for the topic are in another language
- **THEN** Claude borrows their rhythm and structure but none of their words or expressions

### Requirement: Only promoted rules apply
The skill SHALL apply only promoted rules and SHALL NOT apply pending observations. When the
store holds nothing for the language or topic, it SHALL NOT invent traits for the author.

#### Scenario: Empty store
- **WHEN** the global store is configured but still empty
- **THEN** Claude writes normally and attributes no traits to the author

### Requirement: Watching for revisions and session end
While loaded, the write skill SHALL watch for the author revising text Claude wrote in the
session, and SHALL then start learning without the user invoking it. It SHALL also watch for
the author signalling the end of the work session, in any language, and SHALL then run the
session wrap-up defined by voice-learning.

#### Scenario: Revision after a draft
- **WHEN** Claude wrote a report earlier in the session and the author pastes a revised version
- **THEN** learning starts on that revision without an explicit command

#### Scenario: Author closes the session
- **WHEN** the author says they want to wrap up the session
- **THEN** the session wrap-up runs
