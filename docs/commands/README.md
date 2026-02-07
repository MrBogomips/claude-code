---
title: Commands Overview
---

# Commands

Slash commands are quick actions invoked with `/plugin-name:command-name`. They provide a direct interface for users to trigger specific functionality.

## What Are Commands?

Commands are ideal for:

- **Direct user actions** — things the user explicitly wants to trigger
- **Parameterized operations** — actions that accept arguments
- **Workflow shortcuts** — common sequences of actions bundled together
- **Interactive prompts** — guided flows with user input

## Command Structure

Commands are Markdown files in the `commands/` directory with YAML frontmatter:

```yaml
---
description: Brief description shown in command list
user_invocable: true
arguments:
  - name: target
    description: File or directory to process
    required: false
---

# Command Prompt

Instructions for what Claude should do when this command is invoked...
```

## Key Properties

| Property | Purpose |
|----------|---------|
| `description` | Shown when listing available commands |
| `user_invocable` | Whether users can trigger it with `/` |
| `arguments` | Named parameters the command accepts |

## Available Commands

Browse the commands in this marketplace:
