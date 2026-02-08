---
sidebar_position: 1
title: Devcontainer Generator
---

# Devcontainer Generator

Generate a production-ready `.devcontainer` setup for any repository through a guided, multi-step interactive workflow. The `devcontainer-generator` skill scans your project, proposes smart defaults, and lets you confirm or adjust at every step — then produces all the files you need to open in VS Code Remote Containers or GitHub Codespaces.

## Feature Highlights

| Category | What you get |
|----------|-------------|
| **Language Stacks** | Node.js, Python, .NET, Go, Rust, Java — with framework detection |
| **Infrastructure Services** | PostgreSQL (PostGIS), MySQL, MongoDB, Redis, RabbitMQ, Kafka, Azurite, LocalStack |
| **Agentic Coding Tools** | Claude Code, OpenAI Codex CLI, Gemini Code Assist |
| **MCP Servers** | 16 servers across 7 categories — auto-configured for your stack |
| **Network Firewall** | Always-on iptables firewall with deny-all or allow-all policy |
| **VS Code Integration** | Stack-aware extensions, settings, features, and port forwarding |

## Quick Start

1. **Invoke the skill** — run `/devcontainer-generator` in Claude Code (or mention "devcontainer" in conversation)
2. **Walk through the workflow** — confirm or adjust at each of the 10 interactive steps
3. **Build the container** — open in VS Code and run **Dev Containers: Rebuild Container**

The skill generates 7 files inside `.devcontainer/`:

```
.devcontainer/
├── devcontainer.json         # Features, extensions, ports, lifecycle
├── Dockerfile                # Base image, system deps, runtime layers
├── docker-compose.yml        # App container + infrastructure services
├── firewall-rules.conf       # Domain allowlist / denylist
├── scripts/
│   ├── post-create.sh        # Git config, tool install, aliases, deps
│   └── apply-firewall.sh     # Runtime iptables enforcement
└── DEVCONTAINER.md           # Human-readable configuration summary
```

## Supported Stacks

| Stack | Base Image | Frameworks | Package Managers |
|-------|-----------|------------|------------------|
| **Node.js** | `mcr.microsoft.com/devcontainers/javascript-node:22` | Next.js, Angular, Vite, Nuxt, Remix, Docusaurus, Storybook | npm, pnpm, Yarn, Bun |
| **Python** | `mcr.microsoft.com/devcontainers/python:3.12` | Flask, Django, FastAPI | pip, Poetry, Pipenv, uv |
| **.NET** | `mcr.microsoft.com/devcontainers/dotnet:10.0` | ASP.NET Core, Blazor, .NET Aspire | NuGet |
| **Go** | `mcr.microsoft.com/devcontainers/go:1.23` | Gin, Echo, Fiber | Go modules |
| **Rust** | `mcr.microsoft.com/devcontainers/rust:latest` | Actix Web, Axum, Rocket | Cargo |
| **Java** | `mcr.microsoft.com/devcontainers/java:21` | Spring Boot, Quarkus, Micronaut | Maven, Gradle |

## Supported Services

| Service | Image | Port(s) | Default Credentials |
|---------|-------|---------|-------------------|
| **PostgreSQL** (PostGIS) | `postgis/postgis:16-3.4` | 5432 | `postgres` / `postgres` |
| **MySQL** | `mysql:8` | 3306 | `dev` / `dev` (root: `root` / `root`) |
| **MongoDB** | `mongo:7` | 27017 | `admin` / `admin` |
| **Redis** | `redis:7-alpine` | 6379 | No auth |
| **RabbitMQ** | `rabbitmq:3.13-management` | 5672, 15672 | `guest` / `guest` |
| **Kafka** | `confluentinc/cp-kafka:7.5.0` | 9092 | No auth |
| **Azurite** | `mcr.microsoft.com/azure-storage/azurite` | 10000, 10001, 10002 | Well-known dev credentials |
| **LocalStack** | `localstack/localstack:latest` | 4566 | `test` / `test` |

## Agentic Coding Tools

| Tool | Installation | Key Alias |
|------|-------------|-----------|
| **Claude Code** | `curl -fsSL https://claude.ai/install.sh \| bash` | `ccyolo` — skip permissions |
| **OpenAI Codex CLI** | `npm install -g @openai/codex` | `codex-full` — full auto mode |
| **Gemini Code Assist** | VS Code extension `google.geminicodeassist` | — |

## Documentation

| Page | Description |
|------|-------------|
| [Interactive Workflow](./devcontainer-generator/workflow) | The full 10-step generation flow (Steps 0–9) |
| [Language Stacks](./devcontainer-generator/stacks) | Detailed reference for each of the 6 supported stacks |
| [Infrastructure Services](./devcontainer-generator/services) | Detailed reference for each of the 8 supported services |
| [Agentic Tools & MCP Servers](./devcontainer-generator/ai-tools) | 3 AI tools + 16 MCP servers configuration |
| [Network Firewall](./devcontainer-generator/firewall) | Firewall architecture, rules, and troubleshooting |
| [Generated Files](./devcontainer-generator/generated-files) | File-by-file reference and customization guide |
