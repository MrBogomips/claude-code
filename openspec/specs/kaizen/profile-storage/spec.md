# kaizen/profile-storage Specification

## Purpose
Defines where kaizen custom profiles are saved and how the engine finds a profile by name, so
that custom profiles survive plugin updates and `/kaizen <name>` resolves them.

## Requirements

### Requirement: Custom profiles are saved outside the plugin directory
kaizen-profile-designer SHALL save a new profile to `.kaizen/profiles/<name>/PROFILE.md` at the
project root by default, and SHALL offer `~/.kaizen/profiles/<name>/PROFILE.md` for a profile
used across projects. It SHALL NOT save into the plugin directory.

#### Scenario: Default save location
- **WHEN** the user finishes designing a profile named `build-speed` without choosing a location
- **THEN** the profile is written to `.kaizen/profiles/build-speed/PROFILE.md` and the skill suggests `/kaizen build-speed`

### Requirement: The designer checks for a profile with the same name before saving
Before saving, kaizen-profile-designer SHALL look for a profile with the same `name` in
`.kaizen/profiles/`, `~/.kaizen/profiles/` and the bundled profiles. If one exists, it SHALL show
where and ask whether to replace it or choose another name, and SHALL NOT overwrite a file
without an explicit yes.

#### Scenario: Name already taken
- **WHEN** the user names a new profile `code-refactoring`
- **THEN** the skill reports the bundled profile of that name and asks whether to pick another name, and writes nothing until the user answers

### Requirement: The engine resolves a profile name in a fixed order
Given a profile name, the engine SHALL look for `<name>/PROFILE.md` in `.kaizen/profiles/` at the
project root, then `~/.kaizen/profiles/`, then the bundled `profiles/`, SHALL use the first match,
and SHALL tell the user which file it loaded when the name exists in more than one place. Every
`references/` path a profile names SHALL resolve against the folder that holds its PROFILE.md.

#### Scenario: Custom profile shadows a bundled one
- **WHEN** `.kaizen/profiles/code-refactoring/PROFILE.md` exists and the user runs `/kaizen code-refactoring`
- **THEN** the engine loads the project's custom profile and tells the user that it hides the bundled one

### Requirement: Profile source types match the engine's collectors
kaizen-profile-designer SHALL offer only the source types the engine collects: `config`,
`git_history`, `session_transcripts`, `memory` and `user_provided`.

#### Scenario: Data from an API
- **WHEN** the user wants a KPI computed from an API response
- **THEN** the skill records it for the generated measurement script or as `user_provided`, not as a new source type
