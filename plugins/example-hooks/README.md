# Example Hooks Plugin

This plugin demonstrates how to create hooks for Claude Code.

## Hooks

This plugin includes example hooks for common events:

| Event | Purpose |
|-------|---------|
| `PreToolUse` (Bash) | Safety check before executing shell commands |
| `PostToolUse` (Write) | Note file creation details |
| `SessionStart` | Welcome message with help info |
| `Stop` | Verify task completion before ending |

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
        "prompt": "Instructions for Claude..."
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

## Matchers

Hooks can use matchers to filter when they fire:

```json
{
  "matcher": {
    "tool_name": "Bash"
  }
}
```

Available matchers:
- `tool_name`: Match specific tool
- `tool_input`: Match tool input patterns

## Hook Types

### Prompt Hooks

Most common type - provides instructions to Claude:

```json
{
  "type": "prompt",
  "prompt": "Your instructions here..."
}
```

### Command Hooks

Execute a shell command:

```json
{
  "type": "command",
  "command": "echo 'Hook fired'"
}
```

## Installation

Add this plugin to your Claude Code configuration:

```bash
claude --plugin-dir /path/to/example-hooks
```

## Safety Notes

- Hooks can significantly affect Claude's behavior
- Test hooks thoroughly before deploying
- Be careful with `PreToolUse` hooks that might block legitimate actions

## License

MIT
