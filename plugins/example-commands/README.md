# Example Commands Plugin

This plugin demonstrates how to create slash commands for Claude Code.

## Commands

### `/example-commands:hello`

A simple greeting command that demonstrates basic slash command structure.

**Usage:**
```
/example-commands:hello
/example-commands:hello Alice
```

### `/example-commands:review-code`

Perform a thorough code review with actionable feedback.

**Usage:**
```
/example-commands:review-code
/example-commands:review-code src/auth.js
/example-commands:review-code src/api.ts security
```

**Focus areas:**
- `security` - Look for vulnerabilities
- `performance` - Identify inefficiencies
- `style` - Check code style and readability
- `all` - Review all aspects (default)

## Command Structure

Commands are defined as Markdown files in the `commands/` directory:

```
commands/
├── hello.md
└── review-code.md
```

Each command file uses YAML frontmatter for metadata:

```yaml
---
description: Brief description shown in command list
user_invocable: true
arguments:
  - name: arg_name
    description: What this argument does
    required: false
---
```

## Installation

Add this plugin to your Claude Code configuration:

```bash
claude --plugin-dir /path/to/example-commands
```

Or add to your project's `.claude/settings.local.json`:

```json
{
  "plugins": ["./plugins/example-commands"]
}
```

## License

MIT
