---
sidebar_position: 1
sidebar_label: Example Hooks
title: Example Hooks
---

# Example Hooks Plugin

A plugin demonstrating how to create hooks for Claude Code.

> For details on hooks in Claude Code, see the [official documentation](https://docs.anthropic.com/en/docs/claude-code/plugins).

## Components

This plugin includes example hooks for common lifecycle events:

| Event | Purpose |
|-------|---------|
| `PreToolUse` (Bash) | Safety check before executing shell commands |
| `PostToolUse` (Write) | Note file creation details |
| `SessionStart` | Welcome message with help info |
| `Stop` | Verify task completion before ending |

**Key configuration:**

Each hook in `hooks/hooks.json` specifies an event, an optional matcher (e.g., `tool_name: "Bash"`), and a hook type — either `prompt` (instructions for Claude) or `command` (shell command to execute).

**Example hook entry:**

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
        "prompt": "Check that this command is safe before executing."
      }
    }
  ]
}
```

## Safety Notes

- Hooks can significantly affect Claude's behavior
- Test hooks thoroughly before deploying
- Be careful with `PreToolUse` hooks that might block legitimate actions

## Installation

```bash
claude --plugin-dir /path/to/example-hooks
```
