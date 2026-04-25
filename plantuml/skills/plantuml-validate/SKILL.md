---
name: plantuml-validate
description: Render or check `.puml` files for all declared targets and verify they produce stable output against committed baselines. Use to catch syntax breakage and rendering regressions. Accepts `mode=check|bless` (default `check`) and `level=checkonly|svg-hash|png-perceptual` (default `checkonly`).
allowed-tools: Read, Glob, Bash, Task
---

# PlantUML Validate

Render-aware validation across `.puml` × declared targets, with three
levels of stringency.

## Args

- `mode=check` (default) — compare current render against baseline.
- `mode=bless` — capture current render as new baseline.
- `level=checkonly` (default) — `plantuml -checkonly`, deterministic
  cross-machine, no image output.
- `level=svg-hash` — render SVG, normalize, hash. Stable cross-machine if
  fonts are pinned.
- `level=png-perceptual` — opt-in, fragile across systems. Not implemented
  in v1.0.0; the renderer agent returns `unsupported`.

## Flow

1. **Read Policy** from `CLAUDE.md` § "PlantUML Policy". Extract Primary +
   Additional targets. Abort with a clear message if Policy missing.
2. **Enumerate** `.puml` files (excluding `.plantuml/_*.puml`).
3. **Compute matrix** `file × target`.
4. **Compute baseline path** for each cell:
   `tests/plantuml-baselines/<file-stem>--<target>.<level>`
5. **For `mode=check`**: if any baseline is missing, abort and tell the
   user `"no baselines found, run with mode=bless to capture current state"`.
   (If only some are missing, list them; do not silently skip.)
6. **Dispatch** each cell to `puml-renderer` via `Task` in parallel batches
   of ≤8.
7. **Aggregate** statuses. Render a table.
8. **For `mode=bless`** at level `svg-hash` or higher (i.e. when actual
   images exist): also dispatch `puml-visual-checker` on the freshly
   rendered images (1 per (file, target)) and require all checks `pass`
   or `inconclusive`. A `fail` from visual-checker downgrades the bless
   to `warning` and asks the user to confirm.

## Output

```
Validate (mode=check, level=checkonly)
file              | target | status        | note
----------------- | ------ | ------------- | ----
diagrams/Foo.puml | web    | pass          |
diagrams/Bar.puml | docx   | fail          | exited 1: syntax error line 5

3 pass, 1 fail across 4 cells
```

## Notes

- Baselines live in `tests/plantuml-baselines/` of the user's project,
  intended to be gitcommitted.
- The skill never silently overwrites baselines — only `mode=bless`
  writes.
- For projects without a Policy, this skill exits with `"validate
  requires a PlantUML Policy — run /plantuml-init first"`.
