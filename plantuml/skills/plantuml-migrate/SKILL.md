---
name: plantuml-migrate
description: Regenerate `.plantuml/` after a change to `## PlantUML Policy` in CLAUDE.md (theme switch, target add/remove, brand colors, fonts, layout) and check that every diagram still compiles for each declared target. Tells hand edits from Policy changes by each file's hash header, asks before replacing a hand-edited file, and backs up `.plantuml/` before any write. Use after editing the Policy, or to bring an older `.plantuml/` in line with the generator.
allowed-tools: Read, Edit, Glob, Bash
---

# PlantUML Migrate

Propagate a Policy change to the project's `.plantuml/` partials. The
expected files come from the same bundled generator that
`plantuml-bootstrap` uses, so the comparison is byte for byte and the
model never recreates file contents itself. Authored `.puml` files are
never edited: they include the partials, so regenerating the partials is
the whole migration.

## Flow

1. **Read the Policy.** Abort if `CLAUDE.md` has no `## PlantUML Policy`,
   with `"migrate requires a PlantUML Policy — run /plantuml-init first"`.
   Locate the scripts:
   ```bash
   GEN="${CLAUDE_PLUGIN_ROOT}/skills/plantuml-bootstrap/scripts/generate-config.sh"
   VM="${CLAUDE_PLUGIN_ROOT}/skills/plantuml-validate/scripts/validate-matrix.sh"
   ```

2. **Generate the expected files** into a temp directory:
   ```bash
   EXPECTED="$(mktemp -d -t plantuml-migrate-expected.XXXXXX)"
   bash "$GEN" generate --policy CLAUDE.md --out "$EXPECTED/.plantuml"
   ```
   On exit 2 the Policy is invalid: show the `ERROR:` line and stop.
   Nothing in the project has been touched.

3. **Compare** the project with the expected files:
   ```bash
   diff -r .plantuml "$EXPECTED/.plantuml"
   ```
   Sort every file into one group:
   - **regenerate**: present on both sides, contents differ;
   - **add**: only in the expected output (a new target, or a missing file);
   - **remove**: `_targets/<t>.puml` on disk for a target the Policy no
     longer declares;
   - **keep**: any other file only on disk. It is not generated, so leave
     it in place and list it in the summary.

   If there is nothing to regenerate, add or remove, print
   `"migration: nothing to do"` and stop.

4. **Hand-edit detection.** Run
   `bash "$GEN" verify .plantuml --against "$EXPECTED/.plantuml"`. It prints
   one line per file:
   - `ok <file>` — untouched since generation (its body matches its own
     header hash), so a difference in step 3 comes from the Policy change;
     or its body already equals the expected file's body, so only the
     header would change. Either way replacing it loses nothing: do it
     without asking.
   - `edited <file>` — changed by hand after generation.
   - `no-header <file>` — written before hash headers existed, or by hand.

   Only files in the regenerate and remove groups matter here.

   **For `no-header` files**, ask once for all of them: show their diff
   and ask whether to regenerate them with a header (the backup keeps the
   old versions) or abort.

   **For `edited` files**, list them with their diff and present three
   options. Use `AskUserQuestion` if available; else inline chat.

   **Safety contract:** Do NOT proceed without an explicit, unambiguous
   user choice. If the user does not respond, or the response is
   ambiguous, treat it as `abort`. NEVER default to `overwrite` or
   `promote-to-policy`. Overwrite destroys user work.

   - **promote-to-policy** — carry the hand edit back into the Policy:
     1. Parse each edited partial (skip comment lines):
        - `_brand.puml` → `!$<name> = "#…"` lines as brand colors.
        - `_theme.puml` → `!theme <name>` if present, else `custom`.
        - `_fonts.puml` → `defaultFontName` and `!$base_font_size`.
        - `_layout.puml` → `!pragma layout <name>` and `!$direction`.
     2. Map each parsed value to the corresponding Policy field. An edit
        with no Policy field (an extra skinparam, a changed target file)
        cannot be promoted: say so, and offer overwrite or abort for it.
     3. Show a per-field diff (Policy current → Policy proposed) and
        ask the user to confirm field-by-field. A rejected field keeps
        the Policy value.
     4. After confirmation, `Edit` the `## PlantUML Policy` section in
        CLAUDE.md, then re-run from Step 2 with the updated Policy (a new
        `mktemp` directory). A promoted file now equals the new expected
        output apart from its header, so `verify --against` reports it
        `ok` and it is regenerated with a fresh header without asking
        again. Only edits the Policy cannot express are asked about.
   - **overwrite** — continue to Step 5; the backup keeps the hand edits.
   - **abort** — stop without writing anything.

5. **Apply, backup first:**
   ```bash
   BACKUP="$(mktemp -d -t plantuml-migrate-backup.XXXXXX)"
   cp -R .plantuml "$BACKUP/"
   cp -R "$EXPECTED/.plantuml/." .plantuml/
   rm -f .plantuml/_targets/<each target in the remove group>.puml
   ```
   Capture `$BACKUP`; the summary names it so the user can roll back.
   Copying the whole expected tree is safe: unchanged files are identical,
   and files in the keep group are not touched.

6. **Validate** every diagram against every declared target:
   ```bash
   bash "$VM" --level checkonly
   ```
   It prints one JSON object per (file, target) cell and exits 1 if any
   cell fails. `checkonly` keeps no baselines. On any failure, do not
   report "complete": emit the recovery block (see Output). If `plantuml`
   is not installed (exit 2), say that validation was skipped.

## Output

Successful run:

```
Migration summary
- backup: /tmp/plantuml-migrate-backup.XXXXXX/.plantuml
- regenerated: .plantuml/_brand.puml, .plantuml/_theme.puml
- added: .plantuml/_targets/docx.puml
- removed: (none)
- kept (not generated): (none)
- checkonly: 24 cells, 24 pass

Migration complete.
```

Partial-failure run (any failing cell in Step 6):

```
Migration summary (PARTIAL — REVIEW REQUIRED)
- backup: /tmp/plantuml-migrate-backup.XXXXXX/.plantuml
- regenerated: .plantuml/_brand.puml
- checkonly: 24 cells, 23 pass, 1 fail
  - fail: diagrams/Bar.puml [docx] — Error line 2 in file: diagrams/Bar.puml (exit 200)

To roll back:
  rm -rf .plantuml && cp -R /tmp/plantuml-migrate-backup.XXXXXX/.plantuml .
```

## Notes

- The skill is **stateful**: it modifies the project's `.plantuml/` and,
  on promote-to-policy, CLAUDE.md. Always produce a summary.
- The hash header is the only record of what was generated; no state file
  is kept. Editing a file and its header together defeats the check, so
  keep hand edits out of `.plantuml/` and put them in the Policy.
- **Older `.plantuml/` files** wrote `left to right direction` globally.
  The generator now keeps it behind `$apply_direction()`, because sequence,
  activity, timing, gantt, wbs, interaction-overview and nwdiag diagrams
  reject it. After migrating, diagrams of the other types that relied on
  the global direction add `$apply_direction()` after their includes.
- **Concurrency**: do NOT run `plantuml-migrate` while another tool writes
  `.plantuml/`. There is no locking.
- For projects without a Policy: aborts with `"migrate requires a
  PlantUML Policy — run /plantuml-init first"`.
