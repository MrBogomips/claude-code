---
sidebar_position: 1
sidebar_label: Example Agents
title: Example Agents
---

# Example Agents Plugin

This plugin demonstrates how to create custom agents for Claude Code.

## Agents

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

## Agent Structure

Agents are defined in subdirectories under `agents/`:

```
agents/
└── code-analyzer/
    └── AGENT.md
```

Each agent directory contains an `AGENT.md` file with YAML frontmatter:

```yaml
---
name: agent-name
description: What this agent does (shown in agent list)
tools:
  - Glob
  - Grep
  - Read
model: sonnet  # or opus, haiku
---

# Agent System Prompt

Instructions for the agent...
```

## Available Tools

Agents can be given access to various tools:

| Tool | Purpose |
|------|---------|
| `Glob` | Find files by pattern |
| `Grep` | Search file contents |
| `Read` | Read file contents |
| `Write` | Write files |
| `Edit` | Edit files |
| `Bash` | Run shell commands |
| `LS` | List directories |

## Installation

Add this plugin to your Claude Code configuration:

```bash
claude --plugin-dir /path/to/example-agents
```
