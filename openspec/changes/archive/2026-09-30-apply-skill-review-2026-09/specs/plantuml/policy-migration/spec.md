# Spec Delta

## Purpose

Defines how plantuml-migrate brings `.plantuml/` in line with a changed Policy without mistaking a
Policy change for a hand edit, and without losing hand edits.

## ADDED Requirements

### Requirement: Migrate compares the project with the generator's output
plantuml-migrate SHALL generate the expected files into a temporary directory with the bundled
generator and SHALL compare them with `.plantuml/` using `diff -r`. When nothing differs it SHALL
report "migration: nothing to do" and write nothing.

#### Scenario: Policy unchanged
- **WHEN** migrate runs on a project whose `.plantuml/` equals the generator's output
- **THEN** it reports "migration: nothing to do" and writes nothing

### Requirement: A hand edit is detected from the file's own header
Migrate SHALL treat a file as hand-edited only when its body no longer matches its own
`' generated-sha256:` header and differs from the newly generated file apart from that header. A
file generated from an older Policy that matches its header, or whose body already equals the
newly generated body, SHALL be replaced without a hand-edit prompt. A hand-edited file SHALL be
replaced only after an explicit choice among promote-to-policy, overwrite and abort; no answer or
an ambiguous one SHALL mean abort.

#### Scenario: Legitimate Policy change
- **WHEN** the user changes the Layout engine in the Policy and runs migrate on files generated from the old Policy
- **THEN** only `_layout.puml` is listed for regeneration and no hand-edit prompt appears

#### Scenario: Hand edit
- **WHEN** a line was appended to `.plantuml/_layout.puml` after generation
- **THEN** migrate lists it as edited, shows its diff, and asks promote-to-policy, overwrite or abort before writing

#### Scenario: After promote-to-policy
- **WHEN** the user promotes a hand-edited layout engine into the Policy and migrate re-runs from the generation step
- **THEN** the promoted file is regenerated with a fresh header without the three options being offered again

### Requirement: Files without a header need one confirmation
A file in `.plantuml/` with no hash header SHALL be regenerated, with a header, only after one
confirmation that covers all such files.

#### Scenario: Project set up before hash headers
- **WHEN** migrate runs on a `.plantuml/` whose files have no header
- **THEN** it shows their diff, asks once, and on yes regenerates them with headers

### Requirement: Migrate backs up and edits no diagram
Before writing, migrate SHALL copy `.plantuml/` to a backup directory and name it in the summary.
It SHALL remove `_targets/` files only for targets dropped from the Policy, SHALL leave other files
it did not generate in place, and SHALL NOT edit authored `.puml` files.

#### Scenario: Target removed from the Policy
- **WHEN** `web` is removed from the Additional targets and migrate is confirmed
- **THEN** `.plantuml/_targets/web.puml` is deleted after the backup, and no diagram file is modified
