# Claude Code Plugins

A curated collection of [Claude Code](https://claude.com/claude-code) plugins for professional workflows.

## Plugins

| Plugin | Description | Category |
|--------|-------------|----------|
| [developer-tools](./developer-tools) | Developer environment tooling — devcontainer generation, stack detection, infrastructure config | Engineering |
| [human-resources](./human-resources) | HR interview workflow — job descriptions, pre-screening, interview prep, evaluation, compliance | Human Resources |
| [kaizen](./kaizen) | Continuous improvement loops — recursive optimization engine with profiles for Claude Code usage, refactoring, and process improvement | Engineering |
| [plantuml](./plantuml) | PlantUML diagrams — policy-driven authoring, rendering, lint, validate, review, advisor, and migrate | Documentation |
| [project-management](./project-management) | SOW writing, review, estimation, and PMI-compliant PERT analysis — integrated project management pipeline | Operations |
| [tech-writing](./tech-writing) | Technical writing support — documentation structure, style guides, content review | Documentation |

> **Moved:** the `agentic-harness` plugin now lives in its own repository — [MrBogomips/agentic-harness](https://github.com/MrBogomips/agentic-harness). If you installed it from this marketplace, re-add it from there.

## Installation

Add this marketplace, then install the plugins you want.

```bash
# 1. Add the marketplace
claude plugin marketplace add MrBogomips/claude-code

# 2. Install a plugin (the marketplace name is "mrbogomips-tools")
claude plugin install kaizen@mrbogomips-tools
```

Or, inside a Claude Code session, use the slash commands:

```
/plugin marketplace add MrBogomips/claude-code
/plugin install kaizen@mrbogomips-tools
```

Browse and manage everything interactively with `/plugin`.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines on adding or improving plugins.

## License

MIT — see [LICENSE](./LICENSE) for details.

## Resources

- [Claude Code Documentation](https://code.claude.com/docs)
- [Plugin Development Guide](https://code.claude.com/docs/en/plugins)
- [Plugin Marketplaces Guide](https://code.claude.com/docs/en/plugin-marketplaces)

## Author

**Mr Bogomips** — giovanni.costagliola@gmail.com
