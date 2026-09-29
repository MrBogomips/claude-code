# Spec Delta

## Purpose

Defines where the author's voice profile is stored, how it is laid out, and how each
observation or rule is routed between the global store and a project store.

## ADDED Requirements

### Requirement: Global store location chosen by the user
The global store SHALL live in a directory the user sets through the plugin's configuration.
The plugin SHALL NOT place the global store in its own installation or data directory. When
the location is not set or cannot be read, the skills SHALL tell the user how to set it and
SHALL NOT write any store file.

#### Scenario: Location not configured
- **WHEN** a skill needs the global store and no location is configured
- **THEN** it explains how to set the location in the plugin configuration
- **AND** it writes nothing

#### Scenario: Uninstalling the plugin
- **WHEN** the user uninstalls the plugin
- **THEN** the global store is left untouched in the directory the user chose

### Requirement: Global store layout
The global store SHALL separate tone from lexicon:
- `core.md` holds the tone of voice that applies in every language and topic, including
  audience-qualified tone and language-neutral LLM habits to avoid.
- `languages/<code>.md` holds tone specific to one language (punctuation, register and
  audience forms, LLM habits typical of that language) and signature expressions the author
  uses across topics in that language.
- `topics/<slug>.md` holds the lexicon of one topic (professional, hobby or personal): a
  glossary of the most used terms, preferred technical and jargon expressions, and
  expressions from other languages used as a quirk or expressive identity.
- `exemplars/` holds texts the author wrote without AI, each tagged with topic, language,
  audience and source.
- `observations.md` holds pending observations.
Files and folders SHALL be created only when first needed.

#### Scenario: First observation for a new topic
- **WHEN** an observation is recorded for a topic with no file yet
- **THEN** the observation goes to `observations.md` with that topic
- **AND** no topic file is created until a rule for that topic is promoted

#### Scenario: Tone and lexicon kept apart
- **WHEN** the store holds a rule about how the author addresses clients and a rule about
  the terms the author uses in software engineering
- **THEN** the first lives in `core.md` or a language file and the second in
  `topics/software-engineering.md`

### Requirement: Project store layout and content
A project store SHALL live in `.personal-voice/` at the project root and SHALL hold only
project-specific material: `glossary.md` (client and project terms with preferred use, terms
to avoid and meaning), `content-types/<slug>.md` (conventions for this project's document
types) and `observations.md`. The project store SHALL NOT hold exemplars or any rule or
observation from personal topics.

#### Scenario: Personal material stays global
- **WHEN** an observation comes from a message to a family member while working in a project
- **THEN** it is recorded in the global store and never in `.personal-voice/`

### Requirement: Project store initialization with an informed git choice
The project store SHALL be created only after the user confirms. In a git repository, before
creating it, the skill SHALL explain what versioning the store implies (who can read it,
history, changes appearing in git status, merge conflicts, exposure of client names in shared
or public repositories) and ask whether to keep it personal or version it. Personal SHALL be
the default. A personal store SHALL be excluded through the repository's local exclude file,
never through a shared ignore file. Outside a git repository the question SHALL NOT be asked.

#### Scenario: Default choice
- **WHEN** the user confirms creating the project store and accepts the default
- **THEN** `.personal-voice/` is created and listed in `.git/info/exclude`
- **AND** `.gitignore` is not modified

#### Scenario: User declines the project store
- **WHEN** the user declines creating the project store
- **THEN** no folder is created and project-specific observations are not recorded
- **AND** the skill does not ask again in the same session

### Requirement: Routing between stores and files
Every observation and rule SHALL be routed by these questions, in order:
1. Would it hold in another project? If not, or if uncertain, it belongs to the project store.
2. Is it about how the text sounds (tone) or which words it uses (lexicon)?
3. Does it depend on the language, on the topic, on both, or on neither?
Tone that depends on neither goes to `core.md`; tone that depends on the language goes to
`languages/<code>.md`; tone that depends on a topic stays in the tone file and carries a topic
qualifier. Lexicon tied to a topic goes to `topics/<slug>.md`, marked with a
language when it depends on one; lexicon used across topics in one language goes to
`languages/<code>.md`.

#### Scenario: Topic term in one language
- **WHEN** the author consistently writes "deploy" instead of "rilascio" in Italian software
  engineering texts
- **THEN** the entry goes to `topics/software-engineering.md` marked `[it]`

#### Scenario: Cross-topic signature expression
- **WHEN** the author uses a literary Italian expression in texts on several topics
- **THEN** the entry goes to `languages/it.md` as a signature expression

#### Scenario: Topic-dependent tone
- **WHEN** the author writes shorter sentences in Italian texts about cycling than elsewhere
- **THEN** the entry goes to `languages/it.md` with a qualifier for the cycling topic, and no
  topic file holds tone

#### Scenario: Client-specific term
- **WHEN** the author replaces a term with the one a client uses, in that client's project
- **THEN** the entry goes to the project `glossary.md`

### Requirement: Store language and entry format
Structure, headings and rule text SHALL be in English. Quoted expressions and exemplars SHALL
stay verbatim in their original language. An entry that depends on a language SHALL carry its
language code; an entry that depends on the audience SHALL carry an audience qualifier. Every
rule SHALL record its evidence count and the date it was last reinforced. Every observation
SHALL record its date, source kind (revision, spoken correction or own text), language, topic,
audience when known, and the before and after excerpts or the quoted trait.

#### Scenario: Rule format
- **WHEN** a rule about closing informal Italian emails is stored
- **THEN** it reads in English, quotes the Italian expression verbatim, carries `[it]` and an
  audience qualifier, and shows its evidence count and last-reinforced date
