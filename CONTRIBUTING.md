# Contributing

Thank you for your interest in contributing to the Claude Code plugins marketplace.

## Plugin Categories

| Category | Directory | Description |
|----------|-----------|-------------|
| Engineering | `developer-tools/` | Developer tooling, infrastructure, build systems |
| Human Resources | `human-resources/` | HR workflows, recruiting, evaluation |
| Operations | `project-management/` | Project management, estimation, reporting |
| Documentation | `tech-writing/` | Technical writing, style guides, content review |

## Repository Structure

This is a flat-at-root marketplace. Each top-level directory is a plugin:

```
claude-code/
├── .claude-plugin/marketplace.json   # Marketplace manifest
├── developer-tools/                  # Plugin directory
│   ├── .claude-plugin/plugin.json    # Plugin manifest (required)
│   ├── README.md                     # Plugin documentation
│   ├── skills/                       # Skills (optional)
│   ├── agents/                       # Agents (optional)
│   ├── hooks/                        # Hooks (optional)
│   └── commands/                     # Commands (optional)
└── ...
```

## Adding a New Plugin

1. Create a top-level directory with a kebab-case name
2. Add `.claude-plugin/plugin.json` with `name`, `version`, `description`, `author`, `license`, and `keywords`
3. Add a `README.md` describing the plugin
4. Add components (`skills/`, `agents/`, `hooks/`, `commands/`) as needed
5. Register the plugin in `.claude-plugin/marketplace.json` with `name`, `source`, `description`, `category`, and `tags`
6. Validate: `/plugin validate .`

## Improving Existing Plugins

1. Fork the repository
2. Create a branch: `git checkout -b feature/your-change`
3. Make your changes
4. Validate: `/plugin validate .`
5. Submit a pull request

## Pull Request Guidelines

- Use conventional commit format: `feat:`, `fix:`, `docs:`, `refactor:`
- Include a clear description of what and why
- Ensure validation passes before submitting

## Component Conventions

- **Skills** — `skills/<name>/SKILL.md` with optional `references/` subdirectory
- **Agents** — `agents/<name>/AGENT.md` with frontmatter specifying model and tools
- **Hooks** — `hooks/hooks.json` with event matchers
- **Commands** — `commands/<name>.md` with YAML frontmatter
