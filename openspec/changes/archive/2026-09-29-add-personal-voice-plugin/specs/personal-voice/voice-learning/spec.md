# Spec Delta

## Purpose

Turns the author's revisions of Claude-written text, and texts the author wrote without AI,
into recorded observations about their tone and lexicon, without interrupting their work.

## ADDED Requirements

### Requirement: Learning from revisions
The learn skill SHALL learn from the author's revision of human-facing text Claude wrote:
a file the author edited, a final version the author pastes, or corrections the author states
in the conversation. It SHALL also run when the user invokes it explicitly.

#### Scenario: Spoken correction
- **WHEN** the author says "don't write 'inoltre', I never use it" about a draft
- **THEN** an observation about avoiding that word is recorded for the draft's language

#### Scenario: Edited file
- **WHEN** Claude wrote a document file in the session and the author edits it and says so
- **THEN** Claude compares its version with the edited file and records the observations

### Requirement: No diff without the draft
The skill SHALL NOT reconstruct or invent a draft. When the draft is neither in the session nor
provided by the user, it SHALL say so, and SHALL offer to treat the final text as the author's
own text only if the author wrote it.

#### Scenario: Revision from an earlier session
- **WHEN** the author provides only a final version of a text drafted in a previous session
- **THEN** the skill does not produce a diff and asks for the draft or offers own-text learning

### Requirement: Authorship of each version
The skill SHALL treat only changes made by the author as preferences. When Claude edited a text
the author wrote, Claude's changes SHALL NOT be recorded as preferences; the author's original
MAY be used as own text.

#### Scenario: Proofreading the author's email
- **WHEN** the author asks Claude to proofread an email they wrote
- **THEN** Claude's corrections produce no observations

### Requirement: Style separated from content
The skill SHALL record only changes of tone, lexicon, punctuation, structure and removals of
LLM habits. It SHALL NOT record content changes such as corrected facts, figures, dates,
names or scope.

#### Scenario: Mixed revision
- **WHEN** a revision fixes a date and replaces a stock phrase with the author's own expression
- **THEN** only the expression change becomes an observation

### Requirement: Learning from the author's own texts
The skill SHALL accept texts the author wrote without AI, pasted or given as files, and record
the traits they show as observations. It MAY keep short excerpts as exemplars in the global
store, tagged with topic, language, audience and source.

#### Scenario: Bootstrap from old emails
- **WHEN** the author gives three emails they wrote to clients
- **THEN** observations are recorded for the traits the emails share
- **AND** excerpts are kept as exemplars tagged with the topic, the language and the audience

### Requirement: Recording without interruption
The skill SHALL record observations without asking, routed as voice-store defines, and SHALL
then show a one-line notice with how many observations were recorded and where. Recording
SHALL NOT change any rule. A trait already observed in an independent text or session SHALL
add evidence to the existing observation instead of creating a new one; repeats within one
text SHALL count once.

#### Scenario: Notice after recording
- **WHEN** two observations are recorded, one global and one for the project
- **THEN** a single line reports the two observations and their destinations

#### Scenario: Repeated trait
- **WHEN** the author makes the same change in a second, independent text
- **THEN** the existing observation's evidence goes from 1 to 2

### Requirement: Maintenance suggestion
After recording, when pending observations reach 10 or the last maintenance is 30 or more days
old, the skill SHALL add one line suggesting the maintain skill. It SHALL NOT run maintenance
itself.

#### Scenario: Threshold reached
- **WHEN** recording brings pending observations to 10
- **THEN** a one-line suggestion to run maintenance follows the notice

### Requirement: Session wrap-up
When the author signals the end of the work session and the plugin was used in the session,
the skill SHALL record any revision from the session not yet recorded, give a recap of at most
two lines (observations recorded in the session and total pending), and, when the maintenance
threshold is reached, ask whether to run maintenance now. When the plugin was not used in the
session, the wrap-up SHALL do nothing.

#### Scenario: Wrap-up with pending work
- **WHEN** the author closes a session in which four observations were recorded and twelve are
  pending in total
- **THEN** the recap reports both numbers and asks whether to run maintenance now

#### Scenario: Missed revision
- **WHEN** a revision in the session was not recorded when it happened
- **THEN** the wrap-up records it before the recap
