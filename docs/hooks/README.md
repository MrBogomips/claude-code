---
title: Hooks Overview
---

# Hooks

Hooks are event-driven automations that fire in response to Claude Code lifecycle events. They can intercept tool usage, modify behavior, and enforce policies.

## What Are Hooks?

Hooks are ideal for:

- **Safety guardrails** — block dangerous commands before execution
- **Policy enforcement** — ensure Claude follows team conventions
- **Workflow automation** — trigger actions on specific events
- **Quality checks** — validate output before completing tasks

## Hook Structure

Hooks are defined in `hooks/hooks.json`:

```json
{
  "hooks": [
    {
      "event": "PreToolUse",
      "matcher": {
        "tool_name": "Bash"
      },
      "hook": {
        "type": "prompt",
        "prompt": "Check if this command is safe..."
      }
    }
  ]
}
```

## Available Events

| Event | When it Fires |
|-------|---------------|
| `PreToolUse` | Before any tool is called |
| `PostToolUse` | After a tool completes |
| `SessionStart` | When a new session begins |
| `SessionEnd` | When a session ends |
| `Stop` | When Claude is about to stop responding |
| `SubagentStop` | When a subagent completes |
| `UserPromptSubmit` | When user submits a prompt |
| `PreCompact` | Before conversation compaction |
| `Notification` | When notifications are sent |

## Hook Types

| Type | Purpose |
|------|---------|
| `prompt` | Provide instructions to Claude (most common) |
| `command` | Execute a shell command |

## Available Hooks

Browse the hooks in this marketplace:
