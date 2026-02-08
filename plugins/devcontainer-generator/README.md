# Devcontainer Generator

A Claude Code plugin that generates production-ready `.devcontainer` configurations through an interactive multi-step workflow. It scans your repository, detects your tech stack, and proposes smart defaults you can accept or customize.

## Usage

```bash
claude /devcontainer-generator
```

Or use natural language:

> "Generate a devcontainer for this project"
> "Set up a devcontainer with Next.js and PostgreSQL"
> "Create a development container with Claude Code"

## What Gets Generated

```
.devcontainer/
├── devcontainer.json          # Features, extensions, ports, lifecycle commands
├── Dockerfile                 # Base image, system deps, runtime layers
├── docker-compose.yml         # Container + infrastructure services
├── firewall-rules.conf        # Domain allowlist/denylist (always deployed)
├── DEVCONTAINER.md            # Configuration summary and customization guide
└── scripts/
    ├── post-create.sh         # Git config, tool install, aliases, packages
    └── apply-firewall.sh      # iptables/ip6tables runtime enforcement
```

## Supported Stacks

| Stack | Base Image | Frameworks |
|-------|------------|------------|
| Node.js | `javascript-node:22` | Next.js, Angular, Vite, Nuxt, Remix, Docusaurus |
| Python | `python:3.12` | Flask, Django, FastAPI |
| .NET | `dotnet:10.0` | ASP.NET Core, Blazor, Aspire |
| Go | `go:1.23` | Gin, Echo, Fiber |
| Rust | `rust:latest` | Actix, Axum, Rocket |
| Java | `java:21` | Spring Boot, Quarkus, Micronaut |

Multi-stack projects are supported — the primary stack determines the base image, additional stacks are layered in the Dockerfile.

## Supported Services

PostgreSQL (with PostGIS), MySQL 8, MongoDB 7, Redis 7, RabbitMQ (with Management UI), Kafka (with Zookeeper), Azurite (Azure Storage), LocalStack (AWS).

All services include health checks, named volumes, and connection strings.

## Agentic Coding Tools

- **Claude Code** — installed with `ccyolo` alias (`claude --dangerously-skip-permissions`)
- **OpenAI Codex CLI** — installed with `codex-full` alias
- **Gemini Code Assist** — installed as VS Code extension

## MCP Servers

The workflow proposes MCP servers based on your stack:
- GitHub, Atlassian, Linear (project management)
- PostgreSQL, Redis, SQLite (database)
- Context7, Sentry, Figma, Playwright (specialized tools)
- Brave Search, Fetch, Memory, Sequential Thinking (AI utilities)

## Firewall

The network firewall is **always deployed**. You choose the policy:

- **Deny-all** (recommended) — only whitelisted domains are accessible, tailored to your stack
- **Allow-all** — no restrictions, can be tightened later

Switch policy anytime by editing one line in `firewall-rules.conf`:
```
DENY *    # restrictive (block everything not whitelisted)
ALLOW *   # permissive (allow all traffic)
```

## Quickstart

1. Navigate to your project directory
2. Run `claude /devcontainer-generator`
3. Answer the interactive prompts (smart defaults pre-selected)
4. Open in VS Code → "Reopen in Container"

## Installation

Add to your Claude Code plugins directory:

```bash
git clone https://github.com/MrBogomips/claude-code.git
```

Or copy just this plugin:

```bash
cp -r plugins/devcontainer-generator ~/.claude/plugins/
```

## License

MIT
