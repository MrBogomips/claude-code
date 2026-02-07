---
title: Agents Overview
---

# Agents

Custom agents are specialized subagents that handle complex, multi-step tasks autonomously. They are launched via the Task tool and operate with a focused set of tools and a dedicated system prompt.

## What Are Agents?

Agents are ideal for:

- **Complex analysis** — deep codebase exploration, architecture review
- **Autonomous workflows** — tasks that require multiple steps without user intervention
- **Specialized processing** — focused work with constrained tool access
- **Parallel execution** — running multiple agents concurrently for independent tasks

## Agent Structure

Each agent lives in a subdirectory under `agents/` and contains an `AGENT.md` file with YAML frontmatter:

```yaml
---
name: my-agent
description: What this agent does
tools:
  - Glob
  - Grep
  - Read
model: sonnet
---

# Agent System Prompt

Instructions that guide the agent's behavior...
```

## Key Properties

| Property | Purpose |
|----------|---------|
| `name` | Identifier used when invoking the agent |
| `description` | Shown in agent lists, helps Claude decide when to use it |
| `tools` | Which tools the agent can access |
| `model` | Which Claude model powers it (`sonnet`, `opus`, `haiku`) |

## Available Agents

Browse the agents in this marketplace:
