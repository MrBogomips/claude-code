# Spec Delta

## REMOVED Requirements

### Requirement: The manifest holds the resolved configuration
**Reason**: kaizen 2.0.0 removes runs and their audit trail; it writes no state besides the hook's per-session marker.
**Migration**: Existing `.kaizen/runs/` folders are no longer read; use kaizen 1.2.0 from the repository history to inspect them.

### Requirement: The storage root is settled before anything is written
**Reason**: kaizen 2.0.0 removes the `.kaizen/` storage roots.
**Migration**: Existing `.kaizen/runs/` folders are no longer read; use kaizen 1.2.0 from the repository history to inspect them.

### Requirement: An unfinished run can be resumed from either storage root
**Reason**: kaizen 2.0.0 removes runs; a retrospective completes within one session.
**Migration**: Use kaizen 1.2.0 from the repository history to resume an old run.

### Requirement: An iteration interrupted during APPLY is restored before APPLY runs again
**Reason**: kaizen 2.0.0 removes iterations and backups; edits are undone with git.
**Migration**: Use kaizen 1.2.0 from the repository history to resume an old run.

### Requirement: The final review receives the run directory and the kept iterations
**Reason**: kaizen 2.0.0 replaces the final run review with a review of proposed edits (see `kaizen/proposal-apply`).
**Migration**: Use kaizen 1.2.0 from the repository history to review an old run.
