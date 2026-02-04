# Claude Code Plugin Marketplace

A collection of developer tools and plugins for Claude Code.

## Overview

This repository serves as a marketplace for Claude Code plugins. It provides example plugins demonstrating various patterns and a validation pipeline to ensure plugin quality.

## Marketplace Schema

The marketplace manifest (`/.claude-plugin/marketplace.json`) must follow this schema:

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "marketplace-name",
  "owner": {
    "name": "Owner Name",
    "email": "owner@example.com"
  },
  "metadata": {
    "description": "Description of the marketplace",
    "version": "1.0.0",
    "license": "MIT"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "source": "./plugins/plugin-name",
      "description": "Brief description of what the plugin does"
    }
  ]
}
```

**Important:** Plugin entries must be objects with `name`, `source`, and `description` fields. String paths are not valid.

## Plugin Structure

Each plugin follows this directory structure:

```
plugins/plugin-name/
├── .claude-plugin/
│   └── plugin.json      # Plugin manifest (required)
├── commands/            # Slash commands (*.md files)
├── agents/              # Custom agents (AGENT.md in subdirs)
├── skills/              # Skills (SKILL.md in subdirs)
├── hooks/               # Event hooks (hooks.json)
└── README.md            # Plugin documentation
```

### Plugin Manifest (`plugin.json`)

Required fields:
- `name` - Must match the directory name
- `version` - Semver format (e.g., "1.0.0")
- `description` - Brief description of the plugin

## Development Commands

### Validation

```bash
# Validate all plugins and marketplace manifest
npm run validate

# Run all tests
npm test
```

### Build

```bash
# Regenerate marketplace.json from plugins
npm run build
```

## Contributing

1. Create a new plugin directory under `plugins/`
2. Add the required `.claude-plugin/plugin.json` manifest
3. Add your plugin components (commands, agents, skills, hooks)
4. Update `/.claude-plugin/marketplace.json` with your plugin entry
5. Run validation: `npm run validate && npm test`
6. Submit a pull request

## Adding to Claude Code

```bash
# Add this marketplace to Claude Code
claude /plugin marketplace add .
```
