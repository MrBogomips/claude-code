---
sidebar_position: 2
sidebar_label: How It Works
title: How It Works
---

# How It Works

The generator follows a three-phase pipeline: analyze, ask, generate.

```
Repository files
      |
      v
Phase 1: Analysis -----> detect languages, frameworks, services, monorepo
      |                   fetch templates from containers.dev
      |                   (or Phase 1b: interactive discovery for empty projects)
      |
      v
Phase 2: Questions -----> agentic coder, tools, shell, services, firewall
      |
      v
Phase 3: Generation ----> devcontainer.json, Dockerfile, docker-compose.yml,
                           post-create.sh, shell configs, firewall rules
```

## Phase 1: Repository analysis

The skill reads project files to identify your stack. It checks both the root directory and subdirectories for monorepo support.

### Language detection

| Indicator | Runtime |
|-----------|---------|
| `package.json` | Node.js (reads `engines.node` for version) |
| `*.csproj`, `*.sln`, `global.json` | .NET (reads `global.json` for SDK version) |
| `requirements.txt`, `pyproject.toml`, `setup.py` | Python |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pom.xml`, `build.gradle`, `build.gradle.kts` | Java |

### Package manager detection

| Lock file | Manager |
|-----------|---------|
| `pnpm-lock.yaml` | pnpm |
| `yarn.lock` | Yarn |
| `package-lock.json` | npm |
| `bun.lockb` | Bun |

### Framework detection

| Config file | Framework |
|-------------|-----------|
| `angular.json` | Angular (reads version from `package.json`) |
| `next.config.js`, `next.config.mjs`, `next.config.ts` | Next.js |
| `nuxt.config.js`, `nuxt.config.ts` | Nuxt |
| `vite.config.*` | Vite |
| `docusaurus.config.js` | Docusaurus |
| `.storybook/` | Storybook |

### Service detection

The skill looks at `docker-compose.yml`, environment variables, and connection strings for:

| Service | Default port |
|---------|-------------|
| PostgreSQL | 5432 |
| MySQL | 3306 |
| MongoDB | 27017 |
| Redis | 6379 |
| RabbitMQ | 5672, 15672 |
| Kafka | 9092 |

### Cloud provider detection

| Indicator | Provider |
|-----------|----------|
| `azure-pipelines.yml`, `azuredeploy.json`, Bicep files | Azure |
| `serverless.yml` with AWS, `aws-cdk.*` | AWS |
| `app.yaml` (GCP), `cloudbuild.yaml` | GCP |

### Monorepo detection

| Indicator | Tool |
|-----------|------|
| `pnpm-workspace.yaml` | pnpm workspaces |
| `lerna.json` | Lerna |
| `nx.json` | Nx |
| `turbo.json` | Turborepo |
| `apps/`, `packages/`, `services/` directories | Convention |

### Template fetching

Before selecting a template, the skill fetches the current template list from [containers.dev/templates](https://containers.dev/templates). This ensures template references stay current as the official registry evolves. See [Template Selection](template-system.md) for the full matching algorithm.

### Existing configuration

If a `.devcontainer/` directory already exists, the skill asks whether to:

- Overwrite the existing configuration (replace all files)
- Merge with existing (preserve customizations where possible)
- Cancel generation

## Phase 1b: Interactive stack discovery

For empty repositories or projects where no tech stack is detected, the skill walks you through an interactive setup:

**Step 0 -- Usage intent:**
Choose between a full development environment or a Claude Code execution only (minimal container). If you select Claude-only, the skill skips to file generation with a minimal template.

**Step 1 -- Application type:**
Web application (frontend), Web API (backend), full-stack, CLI tool, library/package, or other.

**Step 2 -- Primary language:**
Options are filtered by application type. For example, a web frontend might show TypeScript/JavaScript, while a CLI tool might show Go, Rust, or Python.

**Step 3 -- Framework:**
Options are filtered by language. For TypeScript web: Next.js, Angular, Nuxt, Vite + React, etc.

**Step 4 -- Package manager** (if applicable):
pnpm (recommended), Yarn, npm, or Bun.

**Step 5 -- Services:**
Database (PostgreSQL, MySQL, MongoDB), cache (Redis), message queue (RabbitMQ, Kafka), storage emulator (Azurite, LocalStack), or none.

**Step 6 -- Confirmation:**
A summary of the configured stack is displayed. You can iterate until it looks correct.

```
Configured Stack:
- Application: Full-stack web application
- Language: TypeScript
- Framework: Next.js
- Package Manager: pnpm
- Services: PostgreSQL, Redis
```

## Phase 2: User preference questions

After analysis, the skill asks six questions:

**Q1: Agentic coding assistant**
- Claude Code with CCometixLine (recommended) -- full integration with statusline
- Claude Code only -- basic installation
- None -- configure your own
- Other agentic coder -- generates a customization section in post-create.sh

**Q2: Developer tools** (multi-select)
- GitHub CLI (gh) -- selected by default
- fzf (fuzzy finder)
- httpie (HTTP client)
- rg (ripgrep)

**Q3: Shell preference**
- Zsh with Oh My Zsh (recommended)
- Fish
- Bash

**Q4: Detected services** (only if services were found, multi-select)
Lists each detected database, message queue, and storage emulator.

**Q5: Version confirmation** (only if versions were detected)
Shows detected runtime versions and lets you override them.

**Q6: Network firewall**
- Enabled with deny-all policy (recommended) -- only whitelisted domains accessible
- Enabled with allow-all policy -- all traffic allowed, specific domains can be blocked
- Disabled -- no network restrictions

See [Network Firewall](firewall.md) for details on how firewall enforcement works.

## Phase 3: File generation

The skill uses template files with `{{PLACEHOLDER}}` markers. Each placeholder is resolved based on your answers and detected stack. Conditional sections (commented-out blocks prefixed with `// {{PLACEHOLDER}}`) are uncommented when the condition is met.

For example, if you select Claude Code with CCometixLine, the `{{INSTALL_CLAUDE_FULL}}` block in `post-create.sh` is uncommented. If you select the deny-all firewall policy, the `{{FIREWALL_POST_START}}` block in `devcontainer.json` is uncommented and `DENY *` remains as the last rule in `firewall-rules.conf`.

The full set of generated files is documented in [Generated Files](generated-files.md).
