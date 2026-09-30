---
name: plantuml-validate
description: Check that `.puml` files compile for every declared target and, at the svg-hash level, render the same as their committed baselines. Use to catch syntax breakage and rendering regressions, locally or in CI. Accepts `mode=check|bless` (default `check`) and `level=checkonly|svg-hash|png-perceptual` (default `checkonly`).
allowed-tools: Read, Glob, Bash, Agent
---

# PlantUML Validate

Render-aware validation across `.puml` × declared targets, with three
levels of stringency. A bundled script runs the whole matrix, so every
cell is checked the same way and no agent is needed per cell.

## Args

- `mode=check` (default) — compare the current state with the baselines.
- `mode=bless` — capture the current render as the new baselines.
- `level=checkonly` (default) — `plantuml -checkonly` per target. It keeps
  no baselines: a file passes when it compiles, so `bless` has nothing to
  write and a failing file can never become a passing baseline.
- `level=svg-hash` — render SVG from the file, strip the PlantUML version
  and comments, hash. Stable across machines only if fonts are pinned.
- `level=png-perceptual` — not implemented; every cell is `unsupported`.

## The matrix script

```bash
VM="${CLAUDE_PLUGIN_ROOT}/skills/plantuml-validate/scripts/validate-matrix.sh"
bash "$VM" --mode <check|bless|preview> --level <level> [FILE...]
```

Run it from the project root. It reads the targets from the Policy,
enumerates every `*.puml` / `*.plantuml` outside `.plantuml/` (skipping
`_*.puml` partials), and calls `plantuml` once per (file, target) with
`PLANTUML_TARGET` set and the file path as argument, so includes resolve
from the diagram's own directory at every level. It prints a JSON array,
one object per cell:

```json
{"file":"diagrams/Foo.puml","target":"web","level":"checkonly","status":"pass","diff_summary":""}
```

`status` ∈ `pass | fail | blessed | rendered | missing-baseline |
unsupported | error`; any exit ≠ 0 from plantuml is `fail` (or `error`
when blessing). Script exit: 0 when every cell is pass, blessed or
rendered; 1 otherwise; 2 on a setup error (no Policy, no `plantuml`),
which you report as is. Each cell starts a JVM (about a second), so give
the Bash call a longer timeout on large projects, or pass the files to
check.

Baselines live at `tests/plantuml-baselines/<flat-relpath>--<target>.svg-hash`,
where `<flat-relpath>` is the path from the project root with `/` replaced
by `__` and the extension dropped (`diagrams/auth/Foo.puml` →
`diagrams__auth__Foo`), so two diagrams with the same stem never collide.

## Flow

1. **Read the Policy** from `CLAUDE.md` § "PlantUML Policy". Without one,
   exit with `"validate requires a PlantUML Policy — run /plantuml-init first"`.
2. **checkonly** (either mode): run `bash "$VM" --level checkonly`. With
   `mode=bless`, tell the user that checkonly keeps no baselines, then
   report the results as for `check`.
3. **svg-hash, `mode=check`**: run `bash "$VM" --level svg-hash`. If every
   cell is `missing-baseline`, tell the user `"no baselines found, run with
   mode=bless to capture current state"`. If only some are missing, list
   them; do not skip them silently.
4. **svg-hash, `mode=bless`**: run the visual smoke check first, and write
   baselines only after it:
   1. `bash "$VM" --mode preview --out "$(mktemp -d)"` renders one PNG per
      cell (no baselines). The `image` field gives each path.
   2. Read the Theme, the brand color `primary` and the `Font family` from
      the Policy. `primary_color` is the Policy's primary brand color only
      when Theme is `custom`, otherwise `null`: with a built-in theme, brand
      colors are only variables and the theme's own palette is drawn.
   3. Dispatch `puml-visual-checker` on each image via the `Agent` tool, in
      parallel batches of ≤8, passing the image path, `primary_color` and
      `font_family`.
   4. If every check is `pass`, `inconclusive` or `skipped`, continue. If
      any is `fail`, show it and ask the user whether to bless anyway. No
      answer or an ambiguous one means do not bless: stop here.
   5. `bash "$VM" --mode bless --level svg-hash` writes the baselines. A
      cell that does not render is `error` and gets no baseline.
5. **png-perceptual**: report that the level is not implemented.
6. **Render** the JSON as a table.

## Output

```
Validate (mode=check, level=checkonly)
file              | target | status        | note
----------------- | ------ | ------------- | ----
diagrams/Foo.puml | web    | pass          |
diagrams/Bar.puml | docx   | fail          | Error line 5 in file: diagrams/Bar.puml (exit 200)

3 pass, 1 fail across 4 cells
```

## Notes

- Baselines live in `tests/plantuml-baselines/` of the user's project,
  intended to be committed.
- The skill never silently overwrites baselines — only `mode=bless` at
  `level=svg-hash` writes them, after the visual check.
- Outside Claude Code (for example in CI), a copy of
  `scripts/validate-matrix.sh` runs on its own with `--targets "<targets>"`;
  it needs bash, awk and plantuml, and exits non-zero on any failing cell.
