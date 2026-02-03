# MrBogomips Claude Code Marketplace

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
| [example-commands](./plugins/example-commands) | Example slash commands demonstrating command patterns | Commands |
| [example-agents](./plugins/example-agents) | Example custom agents demonstrating agent patterns | Agents |
| [example-skills](./plugins/example-skills) | Example skills demonstrating skill patterns | Skills |
| [example-hooks](./plugins/example-hooks) | Example hooks demonstrating event-driven patterns | Hooks |

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

## Development

### Prerequisites

- Node.js 20.x or later
- npm

### Setup

```bash
# Clone the repository
git clone https://github.com/MrBogomips/claude-code.git
cd claude-code

# Install dependencies
npm install
```

### Available Scripts

```bash
# Run tests
npm test

# Validate all plugins
npm run validate

# Lint code and markdown
npm run lint

# Create a new plugin interactively
npm run new-plugin

# Build/update marketplace.json
npm run build
```

### Creating a New Plugin

The easiest way to create a new plugin is with the scaffolding tool:

```bash
npm run new-plugin
```

This will guide you through creating a plugin with the components you need.

### Plugin Structure

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

### Testing Your Plugin

```bash
# Validate structure
npm run validate

# Run tests
npm test

# Test with Claude Code
claude --plugin-dir ./plugins/my-plugin
```

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

### Quick Start

1. Fork this repository
2. Create a new plugin: `npm run new-plugin`
3. Implement your plugin
4. Run `npm test` and `npm run validate`
5. Submit a pull request

## License

MIT - see [LICENSE](./LICENSE) for details.

## Resources

- [Claude Code Documentation](https://code.claude.com/docs)
- [Plugin Development Guide](https://code.claude.com/docs/en/plugins)
- [Official Plugins Repository](https://github.com/anthropics/claude-plugins-official)

## Author

**Mr Bogomips** - giovanni.costagliola@gmail.com
