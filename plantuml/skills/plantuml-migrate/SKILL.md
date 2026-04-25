---
name: plantuml-migrate
description: Apply a Policy change across all `.puml` files in the project (theme switch, target add/remove, brand colors update). Use after editing `## PlantUML Policy` in CLAUDE.md. Detects manual edits to `.plantuml/_*.puml` and halts to prompt before overwriting. Backs up `.plantuml/` before any destructive write.
allowed-tools: Read, Edit, Glob, Bash, Task
---

# PlantUML Migrate

Propagate a Policy change across the project's `.plantuml/` and `.puml`
files. The most invasive skill in the plugin — it modifies user files,
so safety mechanisms are explicit.

## Flow

1. **Read current Policy** from `CLAUDE.md` § "PlantUML Policy". Abort if
   absent with `"migrate requires a PlantUML Policy — run /plantuml-init first"`.

2. **Compute expected `.plantuml/`** files as if the Policy were freshly
   materialized. Run the same generation logic as `plantuml-bootstrap`
   (see `${CLAUDE_PLUGIN_ROOT}/skills/plantuml-bootstrap/SKILL.md` §
   "Generation"), but produce in-memory strings instead of disk writes.
   For each of the four partials (`_brand.puml`, `_theme.puml`,
   `_fonts.puml`, `_layout.puml`), hold the expected bytes.

3. **Manual-edit detection (hash divergence)** — for each existing
   `.plantuml/_brand.puml`, `_theme.puml`, `_fonts.puml`, `_layout.puml`:
   - **Normalize** both sides before hashing to avoid false positives:
     strip CR (`\r`), collapse trailing whitespace per line, ensure a
     single trailing newline at EOF. Same normalization on both sides.
   - Compute SHA-256 via `shasum -a 256` (BSD-compatible across macOS
     and Linux).
   - **Idempotency short-circuit**: if all four hashes match expected
     AND no targets need adding/removing AND no Policy-driven `.puml`
     edits are needed, print `"migration: nothing to do"` and exit 0.

4. **If any divergence is detected**, list the divergent files and
   present three options. Use `AskUserQuestion` if available; else
   inline chat.

   **Safety contract:** Do NOT proceed without an explicit, unambiguous
   user choice. If the user does not respond, or the response is
   ambiguous, treat it as `abort`. NEVER default to `overwrite` or
   `promote-to-policy`. Overwrite destroys user work.

   - **promote-to-policy** — reconcile the on-disk drift back into the
     Policy section. Concretely:
     1. Parse each divergent partial:
        - `_brand.puml` → extract `!$<name> = "#…"` lines as brand colors.
        - `_theme.puml` → extract `!theme <name>` if present, else mark
          theme as `custom`.
        - `_fonts.puml` → extract `defaultFontName` and `defaultFontSize`.
        - `_layout.puml` → extract `!pragma layout <name>` and detect
          `left to right direction`.
     2. Map each parsed value to the corresponding Policy field.
     3. Show a per-field diff (Policy current → Policy proposed) and
        ask the user to confirm field-by-field. Any rejected field is
        reverted to the Policy value (and the on-disk partial will be
        regenerated to match).
     4. After confirmation, `Edit` the `## PlantUML Policy` section in
        CLAUDE.md to apply the accepted changes. Re-run from Step 2
        with the updated Policy.
   - **overwrite** — proceed to Step 5 with the in-memory expected
     content, discarding manual edits.
   - **abort** — exit with status 1.

5. **Apply changes (with backup)**:
   - **Backup first**: copy the existing `.plantuml/` to a timestamped
     directory under the system temp dir, e.g.
     `cp -R .plantuml "$(mktemp -d -t plantuml-migrate-backup.XXXXXX)/"`.
     Capture the backup path; include it in the final summary so the
     user can roll back.
   - Regenerate divergent or stale `.plantuml/_*.puml` from the expected
     content. "Stale" means the on-disk hash differs from expected and
     the user chose `overwrite` (or there were no manual edits to begin
     with).
   - Add/remove `.plantuml/_targets/<t>.puml` per current Policy targets
     vs files present.

6. **Edit-plan for `.puml`**: if the regeneration changed something that
   authored diagrams reference (rare — only include filename rename or
   target directive change), build an `edit_plan` per file. **Skip
   dispatch when the per-file edit_plan is empty.** If all files have
   empty plans, skip Step 6 entirely. Otherwise, dispatch
   `puml-migrator` per file in parallel and aggregate the JSON results
   (applied/skipped/error counts) for the summary.

7. **Validate**: run `plantuml -checkonly` over every `.puml` file
   (excluding `.plantuml/_*.puml`). Aggregate results. On any failure,
   stop reporting "complete" and emit a recovery block (see Output).

## Output

Successful run:

```
Migration summary
- backup: /tmp/plantuml-migrate-backup.XXXXXX/.plantuml
- regenerated: .plantuml/_brand.puml, .plantuml/_theme.puml
- targets added: docx
- targets removed: (none)
- diagrams edited: 0 applied, 0 skipped, 0 errors
- checkonly: 12 ok, 0 errors

Migration complete.
```

Partial-failure run (any Step 7 error or any per-file `error` from
`puml-migrator`):

```
Migration summary (PARTIAL — REVIEW REQUIRED)
- backup: /tmp/plantuml-migrate-backup.XXXXXX/.plantuml
- regenerated: .plantuml/_brand.puml
- diagrams edited: 8 applied, 1 skipped, 1 error
  - error: diagrams/Foo.puml — confirmation failed after replace_include
- checkonly: 11 ok, 1 error
  - error: diagrams/Bar.puml — exited 1: include not found at line 2

To roll back:
  rm -rf .plantuml && cp -R /tmp/plantuml-migrate-backup.XXXXXX/.plantuml .
  (and revert any Step 6 edits via git checkout if your tree was clean)
```

## Notes

- The skill is **stateful**: it modifies the user's project. Always
  produce a summary so the user can review.
- **Concurrency**: do NOT run `plantuml-migrate` while editing `.puml`
  files in another tool. There is no locking; concurrent edits may be
  lost. v1.0.0 limitation.
- **Atomicity**: Step 6 dispatches per-file edits in parallel. There is
  no global rollback if Step 7 fails after Step 6 succeeded — the
  backup covers `.plantuml/` only, not authored `.puml` edits. If your
  tree was clean before invocation, `git checkout -- diagrams/` is the
  fastest recovery.
- For projects without a Policy: aborts with `"migrate requires a
  PlantUML Policy — run /plantuml-init first"`.
