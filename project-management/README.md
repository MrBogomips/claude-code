# Project Management

SOW writing, review, estimation, and PMI-compliant PERT analysis for Claude Code.

## Skills

| Skill | Trigger | Purpose |
|-------|---------|---------|
| `sow-write` | "write SOW", "create statement of work" | Write full or summary SOWs from project briefs |
| `sow-review` | "review SOW", "SOW quality check" | Score and adversarially review SOW documents |
| `sow-estimate` | "estimate SOW", "SOW economics" | Extract WBS from SOW and bridge to PERT |
| `pmo-pert-estimate` | "PERT estimate", "three-point estimate" | Generate PMI-compliant PERT Excel workbooks |

## Pipeline

```
 Project Brief
      │
      ▼
 ┌───────────┐     ┌────────────┐     ┌───────────────────┐
 │ sow-write │────▶│ sow-review │     │ pmo-pert-estimate │
 └───────────┘     └────────────┘     └───────────────────┘
      │                                        ▲
      ▼                                        │
 ┌──────────────┐     sow-extraction.md        │
 │ sow-estimate │──────────────────────────────┘
 └──────────────┘
```

**SOW-first, PERT follows**: `sow-write` defines scope, `sow-estimate` extracts the WBS, roles and risks into `sow-extraction.md` and hands it to `pmo-pert-estimate`, which starts from it. When the estimate is done, `sow-estimate` writes the figures into a new version of the SOW. `sow-review` can be run at any point for quality assurance.

## Requirements

- **Python 3 and openpyxl** for `pmo-pert-estimate` (and so for the economics step of `sow-estimate`): the workbook generator and the `summarize.py` checks use them. The skill checks for them at the start and asks before installing openpyxl (`python3 -m pip install --user openpyxl`); without them it stops after writing the generator input, `excel-input.json`.
- **LibreOffice** (optional): when `soffice` is on PATH, `summarize.py --recalc` also recalculates the workbook and compares the values.
- **A document converter** (optional): to read DOCX inputs, the SOW skills use a connected converter or a `markitdown`/`pandoc` command, or ask for a Markdown or PDF export.

## Configuration

All four skills read one section of the project's `CLAUDE.md`, written on first use:

```markdown
## project-management Configuration

| Field | Value |
|-------|-------|
| OutputDir | docs/outbox/ |
| WorkspaceDir | (project working-documents location) |
| Language | en |
| EffortUnit | pd |
| DurationUnit | d |
| PrimaryColor | 1B4FA5 |
| Currency | EUR |
| AvgRate | (none) |
| ManagementReservePct | 10 |
| CustomTemplate | (bundled) |
```

- `OutputDir` holds the deliverables: SOW versions, review reports and PERT workbooks. Every skill asks for it when it is missing.
- `WorkspaceDir` holds the working documents: input analyses, the SOW→PERT handoff and the PERT drafts, one folder per estimate. When it is not set, the skills use the project's declared working-documents location, or ask.
- The other fields are used by `pmo-pert-estimate`. A section named `## pmo-pert-estimate Configuration`, from earlier versions, is read the same way.

Outputs are versioned and never overwritten: a re-run writes the next version (`…-sow-v0.2.0.md`, `…-pert-v2.xlsx`), and input documents are not modified.

## Risk threshold

A risk is **high** when Probability × Impact ≥ 10 (on 1–5 scales) in every skill: it needs a mitigation action and an owner, and the PERT Risks sheet marks it HIGH (10–14) or CRITICAL (≥ 15).

## Connectors

This plugin uses the **CONNECTORS pattern** for optional MCP server integration. See [CONNECTORS.md](CONNECTORS.md) for the full registry. Skills degrade gracefully when connectors are not available.

## Language Support

SOW skills auto-detect language from input documents. Supported: English, Italian. Additional language packs can be added under `skills/sow-write/references/language-packs/`. `sow-review` writes its report in the language of the SOW it reviews.

## Tests

The PERT scripts have a pytest suite, which also generates and checks every bundled example:

```bash
python3 -m pip install -r project-management/skills/pmo-pert-estimate/scripts/requirements-dev.txt
python3 -m pytest -q project-management/skills/pmo-pert-estimate/scripts
```

## License

MIT
