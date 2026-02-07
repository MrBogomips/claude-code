---
sidebar_position: 1
sidebar_label: Overview
title: Devcontainer Generator
---

# Devcontainer Generator

A Claude Code plugin that generates production-ready `.devcontainer` configurations by analyzing your repository's tech stack.

## What it does

The skill examines your repository, detects languages, frameworks, package managers, and services, then generates a complete `.devcontainer/` directory. The process has four phases:

1. **Repository analysis** -- detects your tech stack or walks you through an interactive setup for empty projects.
2. **User preferences** -- asks about your agentic coding assistant, developer tools, shell, services, and firewall policy.
3. **Template selection** -- fetches current templates from [containers.dev](https://containers.dev/templates) and matches them to your stack.
4. **File generation** -- produces a Dockerfile, docker-compose.yml, devcontainer.json, shell configs, and firewall rules.

## Usage

The skill must be invoked explicitly. It does not activate on its own.

```
/devcontainer-generator
```

Or in natural language:

> "Generate a devcontainer using the skill `devcontainer-generator`."

## Two modes

The skill supports two modes of operation, depending on your needs:

| Mode | Use case |
|------|----------|
| **Full Development Environment** | Existing or new projects that need runtimes, services, and tooling |
| **Claude-Only** | Empty folders or cases where you only need a minimal container with Claude Code. This scenario is ideal for using Claude Code in yolo mode into an isolated environment. |

## Supported tech stacks

### Languages and runtimes

| Detection file | Runtime |
|----------------|---------|
| `package.json` | Node.js |
| `*.csproj`, `*.sln` | .NET |
| `requirements.txt`, `pyproject.toml` | Python |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pom.xml`, `build.gradle` | Java |

### Package managers

| Lock file | Manager |
|-----------|---------|
| `pnpm-lock.yaml` | pnpm |
| `yarn.lock` | Yarn |
| `package-lock.json` | npm |
| `bun.lockb` | Bun |

### Frameworks

| Config file | Framework |
|-------------|-----------|
| `angular.json` | Angular |
| `next.config.*` | Next.js |
| `nuxt.config.*` | Nuxt |
| `vite.config.*` | Vite |
| `docusaurus.config.js` | Docusaurus |
| `.storybook/` | Storybook |

### Services

PostgreSQL (with PostGIS), MySQL, MongoDB, Redis, RabbitMQ (with Management UI), Kafka (with Zookeeper), Azurite (Azure Storage Emulator), LocalStack (AWS Emulator).

### Monorepo support

Detected via `pnpm-workspace.yaml`, `lerna.json`, `nx.json`, `turbo.json`, or the presence of `apps/`, `packages/`, `services/` directories.

## Quickstart

1. Open your project in Claude Code.
2. Run `/devcontainer-generator`.
3. Answer the preference questions.
4. Build and start the container:

```bash
devcontainer up --workspace-folder .
```

5. Attach:

```bash
devcontainer exec --workspace-folder . /bin/zsh
```

Or in VS Code: Command Palette > "Dev Containers: Attach to Running Container".

## Skill frontmatter reference

The skill definition includes several frontmatter options that control its behavior:

| Option | Value | Meaning |
|--------|-------|---------|
| `user-invokable` | `true` | The skill appears as a slash command (`/devcontainer-generator`) and can be invoked by the user directly. |
| `disable-model-invocation` | `true` | The model never auto-triggers this skill. Generation only starts when you explicitly ask for it. |
| `context` | `fork` | The skill runs in a forked (isolated) context, so it does not pollute the main conversation with intermediate analysis. |
| `allowed-tools` | `Read, Grep, Glob, WebFetch` | During the analysis phase, the skill is limited to read-only operations. It cannot write files or run commands until the generation phase. |

## Installation

Add the plugin marketplace `MrBogomips/claude-code` and install the `devcontainer-generator` skill.

## Next steps

- [How It Works](how-it-works.md) -- the full generation pipeline
- [Network Firewall](firewall.md) -- deny-all-except-whitelist network isolation
- [Claude Code Integration](claude-integration.md) -- bind mounts, aliases, and agentic coders
- [Customization](customization.md) -- extension points for generated files
