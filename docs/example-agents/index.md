---
sidebar_position: 1
sidebar_label: Example Agents
title: Example Agents
---

# Example Agents Plugin

A plugin demonstrating how to create custom agents for Claude Code.

> For details on agents in Claude Code, see the [official documentation](https://docs.anthropic.com/en/docs/claude-code/plugins).

## Components

### `code-analyzer`

A specialized agent for analyzing codebase architecture, patterns, and dependencies.

**When to use:**
- Understanding a new codebase
- Documenting architecture
- Finding patterns and conventions
- Mapping dependencies

**Example usage:**

The agent is automatically available when this plugin is loaded. Use the Task tool to invoke it:

```
Task: Analyze the architecture of this codebase
Agent: example-agents:code-analyzer
```

**Key configuration:**

The agent is given read-only tool access (`Glob`, `Grep`, `Read`, `LS`) to explore the codebase without modifying it. It uses the `sonnet` model for a good balance of speed and analysis depth.

## Installation

```bash
claude --plugin-dir /path/to/example-agents
```
