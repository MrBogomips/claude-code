# Connectors

Tool-specific connector registry for the kaizen plugin. The connector is optional; the engine runs without it. Cross-run continuity needs no connector: the engine keeps it in the `.kaizen/runs/` audit trail.

## Registry

| Category | Placeholder | Options | Required | Used by |
|----------|-------------|---------|----------|---------|
| Structured reasoning | `~~sequential-thinking` | [Sequential Thinking MCP](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking) | No | kaizen-engine (optional) |

## How Skills Use Connectors

### ~~sequential-thinking (optional)

When connected, the engine may record each improvement iteration as a structured thought chain, one thought per phase of the loop:

1. MEASURE — collect current KPIs
2. ANALYZE — compare to baseline and history
3. HYPOTHESIZE — identify root causes and opportunities
4. PROPOSE — generate concrete change plan
5. APPLY — mutate target assets
6. VERIFY — re-measure KPIs
7. DECIDE — keep improvement or revert
8. LOG — write audit record

Without this connector, the engine runs the same eight phases directly.
