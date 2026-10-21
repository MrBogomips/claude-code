# Spec Delta

## REMOVED Requirements

### Requirement: Uncommitted changes in the mutation targets are resolved before any commit
**Reason**: kaizen 2.0.0 removes the KPI loop engine; it never commits (see `kaizen/proposal-apply`).
**Migration**: Use kaizen 1.2.0 from the repository history for KPI loops.

### Requirement: KEEP commits only the edits the iteration made
**Reason**: kaizen 2.0.0 removes the KPI loop engine and its KEEP decision.
**Migration**: Use kaizen 1.2.0 from the repository history for KPI loops.

### Requirement: REVERT restores the pre-iteration state from the backup
**Reason**: kaizen 2.0.0 removes the KPI loop engine; edits are undone with git.
**Migration**: Use kaizen 1.2.0 from the repository history for KPI loops.

### Requirement: A failed verify check forces REVERT
**Reason**: kaizen 2.0.0 removes the KPI loop engine and its verify checks.
**Migration**: Use kaizen 1.2.0 from the repository history for KPI loops.

### Requirement: User decisions during an iteration are recorded as keep or revert
**Reason**: kaizen 2.0.0 removes the KPI loop engine and its decision records.
**Migration**: Use kaizen 1.2.0 from the repository history for KPI loops.
