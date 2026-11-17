# Design

## Context

See proposal.md for why the two plugins leave this marketplace. Their behavior is specified in seven
capabilities under `openspec/specs/kaizen/` and `openspec/specs/personal-voice/` (50 requirements). The
specs travel with the code in spirit only: the new repository keeps its own records, and this
repository keeps the specs as history.

The full specs as they stood before this change can still be read at commit `83b8bcf` on `main`
(merge of PR #27), for example:

```bash
git show 83b8bcf:openspec/specs/kaizen/session-gate/spec.md
git ls-tree -r --name-only 83b8bcf openspec/specs/kaizen openspec/specs/personal-voice
```

The archived changes that produced them (`2026-09-29-add-personal-voice-plugin`,
`2026-10-22-rewrite-kaizen-as-session-retrospective`, and earlier ones) stay untouched under
`openspec/changes/archive/`.

## Goals / Non-Goals

**Goals:**

- Leave no live copy of either plugin, its tests or its specs in this marketplace.
- Keep the retirement inside the OpenSpec workflow, so `openspec/specs/` changes only through archive.

**Non-Goals:**

- Changing the other repositories (`MrBogomips/skills`, `MrBogomips/claude-plugins`).
- Editing historical content in `openspec/changes/archive/`.
- Changing any remaining plugin or its version.

## Decisions

- **Retire whole capabilities with `retire_capabilities: true`.** Archiving a delta that removes every
  requirement of a capability is refused by default ("Spec must have at least one requirement"). The
  OpenSpec CLI's supported way out is `retire_capabilities: true` in the change's `.openspec.yaml`:
  archive then deletes the emptied spec files and their empty folders. Checked with both the local
  OpenSpec 2.0.0 and the 1.13.2 pinned in `tests/validate-openspec.sh`; after archive,
  `openspec validate --all --strict` passes on the remaining 26 specs. Alternatives rejected: deleting
  `openspec/specs/kaizen/` and `openspec/specs/personal-voice/` by hand (bypasses the workflow), or
  leaving a placeholder requirement per capability (specifies behavior that no longer exists here).
- **REMOVED deltas, no ADDED counterpart.** The project rule for a plugin move pairs a REMOVED delta at
  the old path with an ADDED delta at the new path. That rule covers moves inside this repository; here
  the new path is in another repository, so only the REMOVED half applies. Each REMOVED requirement
  carries the same Reason and Migration (reinstall from `mrbogomips`).
- **Marketplace 4.0.1 → 5.0.0.** Removing listed plugins breaks every install that references them, so
  the marketplace version takes a major bump.
- **A short "Moved" note in `README.md`.** Users arriving from old links find the new install in one
  place; no redirect stub plugin is left behind.

## Risks / Trade-offs

- [Users of `@mrbogomips-tools` lose updates when this merges] → merge only after the `skills` and
  `claude-plugins` PRs are merged, so the new install already works; the README note gives the commands.
- [The CI-pinned OpenSpec could ignore `retire_capabilities`] → verified: 1.13.2 archives the change the
  same way as 2.0.0.

## Migration Plan

1. Merge `MrBogomips/skills`, then `MrBogomips/claude-plugins`.
2. Merge this change. Rollback: revert the merge commit; the specs, plugins and tests come back as they
   were at `83b8bcf`.
