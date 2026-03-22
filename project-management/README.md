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
 ┌──────────┐     ┌────────────┐     ┌──────────────────┐
 │ sow-write │────▶│ sow-review │     │ pmo-pert-estimate │
 └──────────┘     └────────────┘     └──────────────────┘
      │                                        ▲
      ▼                                        │
 ┌──────────────┐                              │
 │ sow-estimate │──────────────────────────────┘
 └──────────────┘
```

**SOW-first, PERT follows**: `sow-write` defines scope, `sow-estimate` extracts the WBS and feeds it into `pmo-pert-estimate` for economics and timeline. `sow-review` can be run at any point for quality assurance.

## Connectors

This plugin uses the **CONNECTORS pattern** for optional MCP server integration. See [CONNECTORS.md](CONNECTORS.md) for the full registry. Skills degrade gracefully when connectors are not available.

## Language Support

SOW skills auto-detect language from input documents. Supported: English, Italian. Additional language packs can be added under `skills/sow-write/references/language-packs/`.

## License

MIT
