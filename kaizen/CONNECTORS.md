# Connectors

Tool-specific connector registry for the kaizen plugin. The engine requires Sequential Thinking MCP for loop orchestration and optionally uses memory connectors for cross-session continuity.

## Registry

| Category | Placeholder | Options | Required | Used by |
|----------|-------------|---------|----------|---------|
| Structured reasoning | `~~sequential-thinking` | [Sequential Thinking MCP](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking) | **Yes** | kaizen-engine |
| Persistent memory | `~~memory` | File-based memory, Memory MCP | No | kaizen-engine (optional) |

## How Skills Use Connectors

### ~~sequential-thinking (required)

The kaizen engine uses Sequential Thinking MCP to orchestrate each improvement iteration as a structured thought chain. Each thought maps to a phase of the improvement loop:

1. MEASURE — collect current KPIs
2. ANALYZE — compare to baseline and history
3. HYPOTHESIZE — identify root causes and opportunities
4. PROPOSE — generate concrete change plan
5. APPLY — mutate target assets
6. VERIFY — re-measure KPIs
7. DECIDE — keep improvement or revert
8. LOG — write audit record

Without this connector, the plugin cannot function. See the README for installation instructions.

### ~~memory (optional)

When available, the engine uses persistent memory to maintain context across sessions and improvement runs. When unavailable, the engine relies solely on `.kaizen/` audit logs for cross-run continuity.
