# Spec Delta

## Purpose

Defines what the kaizen engine persists for a run and how it rebuilds context from it, so that
values settled with the user at BOOTSTRAP survive every iteration and session, an unfinished run
can be resumed, and the final review can inspect the kept changes.

## ADDED Requirements

### Requirement: The manifest holds the resolved configuration
At BOOTSTRAP the engine SHALL write the resolved `kpis` (each with its effective `epsilon`),
`mutation_targets`, `verify_checks` and git choices to `manifest.json`. It SHALL read the
profile's `## BOOTSTRAP` section, when present, before writing it. Before each iteration the
engine SHALL rebuild its context from `manifest.json`, not from the PROFILE.md frontmatter.

#### Scenario: KPIs defined with the user
- **WHEN** the process-improvement profile settles a KPI named `lead_time_hours` with the user at BOOTSTRAP
- **THEN** `manifest.json` lists `lead_time_hours` with its direction, unit and epsilon, and every later iteration measures and decides on it rather than on the frontmatter placeholder

### Requirement: The storage root is settled before anything is written
Before it writes any run file, the engine SHALL settle the run's storage root: `.kaizen/` at the
project root when every default mutation target is inside the project, otherwise the root the
user chooses between the project's `.kaizen/` and `~/.kaizen/`. The root SHALL be recorded as
`storage_root` in the manifest, and the run directory, the run-ID sequence and the previous-run
lookups SHALL use it. A profile's BOOTSTRAP section SHALL NOT choose the storage root.

#### Scenario: Targets not known yet
- **WHEN** a new process-improvement run starts, whose mutation target path is empty until its BOOTSTRAP section runs
- **THEN** the engine asks whether the run belongs to the project or to `~/.kaizen/` before creating the run directory, and creates it in the chosen root

#### Scenario: Targets inside the project
- **WHEN** a new code-refactoring run starts with its default targets under the project root
- **THEN** the engine uses the project's `.kaizen/` without asking

### Requirement: An unfinished run can be resumed from either storage root
The engine SHALL look for open runs of the profile in both `.kaizen/runs/` at the project root and
`~/.kaizen/runs/`. A run is open when it has a `manifest.json` and its `summary.json` is missing
or has `convergence_reason: null`. The engine SHALL offer to resume the latest open run in each
root, naming the root; a resumed run SHALL keep its root. On resume it SHALL rebuild context from
the run's files, repeat the git check, and continue where the run stopped, including an
iteration waiting at VERIFY. If the user declines, the engine SHALL record
`convergence_reason: "user_stopped"` for that run.

#### Scenario: Process change waiting for new metrics
- **WHEN** the user runs `/kaizen process-improvement` and the open run's latest iteration has a `diff.patch` but no `verification.json`
- **THEN** the engine offers to resume, and on yes asks for the updated metrics of that iteration

#### Scenario: User declines the resume
- **WHEN** the user declines to resume an open run
- **THEN** that run's `summary.json` gets `convergence_reason: "user_stopped"` and a new run starts

#### Scenario: User-level run
- **WHEN** an open run of the profile exists only under `~/.kaizen/runs/`
- **THEN** the engine offers to resume it, and all files of the resumed run are written under `~/.kaizen/runs/`

### Requirement: An iteration interrupted during APPLY is restored before APPLY runs again
When the iteration to resume has a `backup/` directory but no `diff.patch`, the engine SHALL
restore every file from `backup/` and delete each file listed in `backup/created.txt` before it
runs the git check and APPLY again, and SHALL do the same before starting a new run when the user
declines the resume. APPLY SHALL NOT overwrite a backup copy that already exists and SHALL NOT
remove entries from `created.txt`. The files APPLY found dirty SHALL be written to
`iterations/<N>/dirty-before-apply.txt`, so the list survives a session that ends before DECIDE.

#### Scenario: Session ended after the first edit
- **WHEN** a run is resumed whose iteration has a backup of `src/a.txt`, lists `src/DONE.md` in `created.txt`, and has no `diff.patch`, and `src/a.txt` was already edited
- **THEN** `src/a.txt` is restored from the backup and `src/DONE.md` is removed if present before APPLY runs again, the backup copy is unchanged afterwards, and a later REVERT leaves `src/a.txt` byte-identical to its pre-iteration state

#### Scenario: Resume declined after an interrupted APPLY
- **WHEN** the user declines to resume a run that stopped partway through APPLY
- **THEN** the half-edited targets are restored from the backup before the new run's git check, and the user is told

### Requirement: The final review receives the run directory and the kept iterations
The final adversarial review SHALL receive the run directory path and the list of kept
iterations, each with the path of its `diff.patch`, in addition to the summary and sample
decisions.

#### Scenario: Reviewer checks immutable boundaries
- **WHEN** a run ends with two kept iterations
- **THEN** the reviewer's context names the run directory and both `diff.patch` paths
