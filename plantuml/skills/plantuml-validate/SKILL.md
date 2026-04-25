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
   `tests/plantuml-baselines/<flat-relpath>--<target>.<level>`
   where `<flat-relpath>` is the file path relative to the project root with
   `/` replaced by `__` and the `.puml` extension dropped (e.g.
   `diagrams/auth/Foo.puml` → `diagrams__auth__Foo`). This avoids silent
   collisions when two diagrams share a stem in different directories.
5. **For `mode=check`**: if any baseline is missing, abort and tell the
   user `"no baselines found, run with mode=bless to capture current state"`.
   (If only some are missing, list them; do not silently skip.)
6. **Dispatch** each cell to `puml-renderer` via `Task` in parallel batches
   of ≤8.
7. **Aggregate** statuses. Render a table.
8. **Visual smoke (build-time only)** — applies to `mode=bless` and
   only at `level=svg-hash` (or `png-perceptual` once implemented). The
   svg-hash baseline itself is not viewable, so the skill must perform
   a one-shot auxiliary PNG render per `(file, target)` (e.g.
   `plantuml -tpng -Sscale=3 -o <tmp> <file>`) and dispatch
   `puml-visual-checker` on each PNG. The PNGs are transient — they
   are NOT stored as baselines. All checks must be `pass` or
   `inconclusive`; a `fail` downgrades the bless to a warning and
   prompts the user to confirm.

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
