---
name: plantuml-migrate
description: Apply a Policy change across all `.puml` files in the project (theme switch, target add/remove, brand colors update). Use after editing `## PlantUML Policy` in CLAUDE.md. Detects manual edits to `.plantuml/_*.puml` and halts to prompt before overwriting.
allowed-tools: Read, Edit, Glob, Bash, Task
---

# PlantUML Migrate

Propagate a Policy change across the project's `.plantuml/` and `.puml`
files.

## Flow

1. **Read current Policy** from `CLAUDE.md` § "PlantUML Policy". Abort if
   absent.
2. **Compute expected `.plantuml/`** files as if the Policy were freshly
   materialized (run the same generation steps as `plantuml-bootstrap`,
   but in-memory, producing strings rather than disk writes).
3. **Manual-edit detection (hash divergence)** — for each existing
   `.plantuml/_brand.puml`, `_theme.puml`, `_fonts.puml`, `_layout.puml`:
   compare its on-disk SHA-256 to the SHA-256 of the in-memory expected
   content. Use `shasum -a 256` (BSD-compatible).
4. **If any divergence is detected**, list the divergent files and
   present three options:
   - **promote-to-policy** — re-engineer Policy fields from the on-disk
     content (calls the `mode=reverse` flow of `plantuml-bootstrap`
     conceptually).
   - **overwrite** — proceed with regeneration, discarding manual edits.
   - **abort** — exit with status 1.
   Use `AskUserQuestion` if available; else inline chat. Do NOT proceed
   without explicit user choice.
5. **Apply changes**:
   - Regenerate divergent or stale `.plantuml/_*.puml` from the expected
     content.
   - Add/remove `_targets/<t>.puml` per current Policy targets vs files
     present.
6. **Edit-plan for `.puml`**: if the regeneration changed anything that
   authored diagrams reference (rare — only include filename rename or
   target directive change), build an `edit_plan` and dispatch
   `puml-migrator` per file in parallel.
7. **Validate**: run `plantuml -checkonly` over every `.puml` file. Report
   any failure.

## Output

```
Migration summary
- regenerated: .plantuml/_brand.puml, .plantuml/_theme.puml
- targets added: docx
- diagrams edited: 0
- checkonly: 12 ok, 0 errors

Migration complete.
```

## Notes

- The skill is **stateful**: it modifies the user's project. Always
  produce a summary so the user can review.
- For projects without a Policy: aborts with `"migrate requires a
  PlantUML Policy — run /plantuml-init first"`.
