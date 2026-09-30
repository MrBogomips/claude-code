# Contributing

Thank you for your interest in contributing to the Claude Code plugins marketplace.

## Plugin Categories

| Category | Directory | Description |
|----------|-----------|-------------|
| Engineering | `context-hygiene/`, `kaizen/` | Developer tooling, agentic context, continuous improvement |
| Human Resources | `human-resources/` | HR workflows, recruiting, evaluation |
| Operations | `project-management/` | Project management, estimation, reporting |
| Documentation | `tech-writing/`, `personal-voice/` | Technical writing, style guides, content review, personal writing voice |

## Repository Structure

This is a flat-at-root marketplace. Each top-level directory containing `.claude-plugin/` is a plugin:

```
mrbogomips/
├── .claude-plugin/marketplace.json   # Marketplace manifest
├── <plugin-name>/                    # Plugin directory
│   ├── .claude-plugin/plugin.json    # Plugin manifest (required)
│   ├── README.md                     # Plugin documentation
│   ├── skills/                       # Skills (optional)
│   ├── agents/                       # Agents (optional)
│   ├── hooks/                        # Hooks (optional)
│   └── commands/                     # Commands (optional)
├── ...
├── openspec/                         # Specs (not a plugin)
└── tests/                            # Validation suite (not a plugin)
```

`.claude/` at the root holds the OpenSpec agent files used to maintain this repository; it is not part of the marketplace.

## Adding a New Plugin

1. Create a top-level directory with a kebab-case name
2. Add `.claude-plugin/plugin.json` with `name`, `version`, `description`, `author`, `license`, and `keywords`
3. Add a `README.md` describing the plugin
4. Add components (`skills/`, `agents/`, `hooks/`, `commands/`) as needed
5. Register the plugin in `.claude-plugin/marketplace.json` with `name`, `source`, `description`, `category`, and `tags`
6. Validate: `/plugin validate .` and `bash tests/ci/run-structural-tests.sh`

## Improving Existing Plugins

1. Fork the repository
2. Create a branch: `git checkout -b feature/your-change`
3. If the change alters a plugin's behavior, start an OpenSpec change (see below)
4. Make your changes
5. Validate: `/plugin validate .` and `bash tests/ci/run-structural-tests.sh`
6. Submit a pull request

## Specs (OpenSpec)

Plugin behavior is specified with [OpenSpec](https://github.com/Fission-AI/OpenSpec) in `openspec/`. The structural suite runs `openspec validate --all --strict`, so it needs the OpenSpec CLI or Node ≥20.19.

Setup, once per machine:

```bash
# Install the CLI at the version pinned in tests/validate-openspec.sh (used by CI)
npm i -g @fission-ai/openspec@1.13.2       # or: brew install openspec (tracks the latest release)

# Use the OpenSpec default profile, which matches the committed agent files
openspec config profile core
openspec config set delivery both
```

Without the CLI, the suite falls back to `npx @fission-ai/openspec@<pinned version>`, which needs Node ≥20.19.

Flow for a behavior change, on your branch:

1. `/opsx:propose <what you want to change>` creates `openspec/changes/<id>/` with a proposal, spec deltas, a design when needed, and tasks
2. `/opsx:apply` implements the tasks and ticks them in `tasks.md`
3. `/opsx:archive` merges the deltas into `openspec/specs/`; make it the last commit before merge

The agent files under `.claude/skills/openspec-*` and `.claude/commands/opsx/` are generated and committed. To upgrade the CLI, in one commit: bump `OPENSPEC_VERSION` in `tests/validate-openspec.sh` and the version above, run `openspec update`, and commit the regenerated files. Run `openspec update` only with the profile above; otherwise it rewrites them to match your own profile.

## Pull Request Guidelines

- Use conventional commit format: `feat:`, `fix:`, `docs:`, `refactor:`
- Include a clear description of what and why
- Ensure validation passes before submitting

## Component Conventions

- **Skills** — `skills/<name>/SKILL.md` with optional `references/` subdirectory
- **Agents** — `agents/<name>/AGENT.md` with frontmatter specifying model and tools
- **Hooks** — `hooks/hooks.json` with event matchers
- **Commands** — `commands/<name>.md` with YAML frontmatter
