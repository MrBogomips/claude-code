---
slug: /
sidebar_position: 1
sidebar_label: Home
title: "MrBogomips' Claude Code"
---

# MrBogomips' Claude Code

A collection of developer tools and plugins for [Claude Code](https://claude.com/claude-code).

## Overview

This marketplace provides a curated set of plugins that extend Claude Code's capabilities with:

- **Slash Commands** - Quick actions invoked with `/plugin:command`
- **Custom Agents** - Specialized subagents for complex tasks
- **Skills** - Reusable knowledge and workflows
- **Hooks** - Event-driven automation

## Available Plugins

| Plugin | Description | Components |
|--------|-------------|------------|
| [Devcontainer Generator](/skills/devcontainer-generator) | Generate production-ready devcontainer configurations | Skills |
| [Example Commands](/commands/example-commands) | Example slash commands demonstrating command patterns | Commands |
| [Example Agents](/agents/example-agents) | Example custom agents demonstrating agent patterns | Agents |
| [Example Skills](/skills/example-skills) | Example skills demonstrating skill patterns | Skills |
| [Example Hooks](/hooks/example-hooks) | Example hooks demonstrating event-driven patterns | Hooks |

## Installation

### Using the Marketplace

Add this marketplace to your Claude Code configuration:

```bash
# Install from GitHub
claude plugins install github:MrBogomips/claude-code
```

### Using Individual Plugins

Install a specific plugin:

```bash
# From local path
claude --plugin-dir ./plugins/example-commands

# Add to project settings (.claude/settings.local.json)
{
  "plugins": ["./plugins/example-commands"]
}
```

## Usage

Once installed, plugins are available immediately:

```
# Commands
/example-commands:hello
/example-commands:review-code src/app.ts

# Skills
/example-skills:code-quality
```

Agents are invoked automatically by Claude when appropriate, or explicitly via the Task tool.

## Plugin Structure

Every plugin follows this structure:

```
plugins/my-plugin/
├── .claude-plugin/
│   └── plugin.json      # Required: plugin manifest
├── commands/            # Optional: slash commands
│   └── my-command.md
├── agents/              # Optional: custom agents
│   └── my-agent/
│       └── AGENT.md
├── skills/              # Optional: skills
│   └── my-skill/
│       └── SKILL.md
├── hooks/               # Optional: event hooks
│   └── hooks.json
└── README.md            # Required: documentation
```

## Resources

- [Claude Code Documentation](https://code.claude.com/docs)
- [Plugin Development Guide](https://code.claude.com/docs/en/plugins)
- [GitHub Repository](https://github.com/MrBogomips/claude-code)

## Author

**Mr Bogomips** - giovanni.costagliola@gmail.com
