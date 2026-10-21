# Spec Delta

## REMOVED Requirements

### Requirement: The engine runs the measurement script itself
**Reason**: kaizen 2.0.0 removes generated measurement scripts.
**Migration**: Use kaizen 1.2.0 from the repository history for KPI loops.

### Requirement: The scaffolding reads the profile's MEASURE guidance
**Reason**: kaizen 2.0.0 removes profiles and measurement scaffolding.
**Migration**: Use kaizen 1.2.0 from the repository history for KPI loops.

### Requirement: Each run measures a fresh baseline and reuses the previous tool when the profile is unchanged
**Reason**: kaizen 2.0.0 removes baselines and measurement tools.
**Migration**: Use kaizen 1.2.0 from the repository history for KPI loops.

### Requirement: claude-code-usage reads only this project's transcripts
**Reason**: kaizen 2.0.0 removes the claude-code-usage profile; cross-session usage reports are `/insights`, and the new hook reads only the current session's transcript.
**Migration**: Use `/insights` for usage across sessions, or kaizen 1.2.0 from the repository history.
