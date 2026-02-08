---
sidebar_position: 2
title: Interactive Workflow
---

# Interactive Workflow

The devcontainer generator uses a 10-step interactive workflow (Steps 0–9). Each step presents multi-select options with smart defaults pre-selected based on project detection. You confirm or adjust at every step.

## Step 0: Preflight Discovery

**Automatic — no user interaction.**

The plugin silently scans your project before presenting any choices:

1. **Parse CLI arguments** for explicit requests (e.g., "Next.js with PostgreSQL", "no firewall", "Claude Code only"). These pre-select options in subsequent steps.

2. **Detect language stacks** by scanning for marker files:

   | Marker Files | Detected Stack |
   |-------------|---------------|
   | `package.json` | Node.js (check `engines.node` for version) |
   | `*.csproj`, `*.sln`, `global.json` | .NET (check `sdk.version`) |
   | `requirements.txt`, `pyproject.toml`, `setup.py`, `Pipfile`, `uv.lock` | Python |
   | `go.mod` | Go |
   | `Cargo.toml` | Rust |
   | `pom.xml`, `build.gradle`, `build.gradle.kts` | Java |

3. **Detect frameworks:**

   | Marker Files | Detected Framework |
   |-------------|-------------------|
   | `angular.json` | Angular |
   | `next.config.*` | Next.js |
   | `nuxt.config.*` | Nuxt |
   | `vite.config.*` | Vite |
   | `docusaurus.config.*` | Docusaurus |
   | `.storybook/` | Storybook |
   | `remix.config.*` | Remix |

4. **Detect package managers:** `pnpm-lock.yaml` → pnpm, `yarn.lock` → Yarn, `package-lock.json` → npm, `bun.lockb` → Bun

5. **Detect monorepo indicators:** `pnpm-workspace.yaml`, `nx.json`, `turbo.json`, `lerna.json`, `apps/`, `packages/`, `services/`

6. **Scan for infrastructure services:** existing `docker-compose.yml` (parse service names/images), environment variables referencing databases/brokers, cloud provider files (`azure-pipelines.yml`, `azuredeploy.json`, Bicep → Azure; `serverless.yml`, `aws-cdk.*` → AWS)

7. **Detect Git LFS:** check `.gitattributes` for `filter=lfs` patterns

8. **Check for existing `.devcontainer/`** directory

If nothing is detected and no CLI arguments were given, the workflow proceeds with all options unselected.

## Step 1: Tech Stack

Multi-select prompt with detected stacks pre-selected:

```
[ ] Node.js 22 (+ Next.js)        ← pre-selected if detected
[ ] Python 3.12
[ ] .NET 10.0
[ ] Go 1.23
[ ] Rust latest
[ ] Java 21
```

- Detected version is shown (e.g., "Node.js 22" from `engines.node`)
- Detected framework is appended (e.g., "Node.js 22 + Next.js")
- "Other" free-text input is always available
- The **first selected stack** becomes the primary — its base image is used for the Dockerfile

After selection, the plugin loads the corresponding [stack reference files](./stacks) to extract base images, extensions, aliases, firewall domains, and host binding guidance.

## Step 2: Infrastructure Services

Multi-select prompt with stack-aware and detection-based pre-selections:

```
[ ] PostgreSQL (with PostGIS)      ← pre-select if detected, or if .NET/Python selected
[ ] MySQL 8
[ ] MongoDB 7                      ← pre-select if Node.js + MongoDB detected
[ ] Redis 7                        ← suggest if any backend stack selected
[ ] RabbitMQ (with Management UI)
[ ] Kafka (with Zookeeper)
[ ] Azurite (Azure Storage)        ← pre-select if Azure detected
[ ] LocalStack (AWS Emulator)      ← pre-select if AWS detected
```

After selection, the plugin loads [service reference files](./services) to extract Docker Compose blocks, connection strings, credentials, volumes, ports, and client tools.

## Step 3: Agentic Coding Tools

Multi-select prompt:

```
[x] Claude Code                    ← selected by default
[ ] OpenAI Codex CLI
[ ] Gemini Code Assist
```

After selection, the plugin loads [agentic tool reference files](./ai-tools) for installation commands, aliases, verification steps, and firewall domains.

## Step 4: Git Configuration

Multi-select prompt:

```
[x] Git                            ← always pre-selected
[ ] Git LFS                        ← pre-selected if LFS detected in Step 0
```

Git configuration includes: credential helper, autocrlf, default branch (`main`), push.autoSetupRemote, color, rebase settings.

If Git LFS is selected: `git-lfs` is added to Dockerfile apt install, and `git lfs install` runs in post-create.sh.

## Step 5: MCP Servers

:::info Conditional Step
This step is **only presented if an agentic coding tool was selected in Step 3**. Otherwise, it is skipped entirely.
:::

Before presenting options, the plugin performs a **live web search** (e.g., "best MCP servers for Node.js 2026") to supplement the built-in catalog with fresh recommendations.

Options are organized by category with stack-aware pre-selections:

**Documentation & Code Context:**
```
[ ] Context7 (by Upstash) — version-specific library docs
```

**Source Control & Project Management:**
```
[ ] GitHub MCP                     ← pre-selected if .git detected
[ ] Atlassian MCP (Jira + Confluence)
[ ] Linear MCP
```

**Database:**
```
[ ] PostgreSQL MCP                 ← pre-selected if PostgreSQL chosen in Step 2
[ ] Redis MCP                      ← pre-selected if Redis chosen in Step 2
[ ] SQLite MCP
```

**Design & Browser:**
```
[ ] Figma MCP
[ ] Puppeteer MCP
[ ] Playwright MCP
```

**Code Quality & Monitoring:**
```
[ ] Sentry MCP
[ ] Serena MCP
```

**Search & Web:**
```
[ ] Brave Search MCP
[ ] Fetch MCP
```

**AI & Reasoning:**
```
[ ] Memory MCP
[ ] Sequential Thinking MCP
```

See [Agentic Tools & MCP Servers](./ai-tools) for full details on each server's configuration and API key requirements.

## Step 6: VS Code Extensions & Features

Multi-select prompts with stack- and service-aware pre-selections:

**Common** (always pre-selected):
```
[x] GitLens
[x] Error Lens
[x] EditorConfig
[x] Path Intellisense
```

**Stack-specific** (pre-selected based on Step 1):

| Stack | Extensions |
|-------|-----------|
| Node.js | ESLint, Prettier, Tailwind CSS |
| .NET | C# Dev Kit, C#, .NET Runtime |
| Python | Python, Pylance |
| Go | Go |
| Rust | rust-analyzer, crates |
| Java | Java Extension Pack, Spring Boot (if detected), Quarkus (if detected) |

**Service-specific** (pre-selected based on Step 2):

| Service | Extension |
|---------|-----------|
| PostgreSQL | PostgreSQL explorer |
| MongoDB | MongoDB explorer |
| Redis | Redis explorer |

**Testing:**
```
[ ] Playwright                     ← pre-selected if detected
```

**Devcontainer Features** (always pre-selected):
```
[x] common-utils, git, github-cli, docker-outside-of-docker
[ ] azure-cli                      ← pre-selected if Azure detected
```

## Step 7: Firewall Policy

Single-select prompt (not multi-select):

```
[x] Deny-all (recommended) — only whitelisted domains accessible
[ ] Allow-all — no restrictions, ALLOW * default policy
```

:::note Always Deployed
The firewall scripts (`apply-firewall.sh` and `firewall-rules.conf`) are **always generated** regardless of this choice. Selecting "Allow-all" simply sets the default policy to `ALLOW *` — no traffic is blocked. You can tighten rules later by editing `firewall-rules.conf`.
:::

See [Network Firewall](./firewall) for full details.

## Step 8: Final Recap & Confirmation

A formatted summary of all selections is displayed:

```
=== Devcontainer Configuration Recap ===

Tech Stack:      Node.js 22 + Next.js
Services:        PostgreSQL :5432, Redis :6379
Agentic Tools:   Claude Code
MCP Servers:     GitHub, Context7, PostgreSQL
Git:             Standard + LFS
VS Code:         12 extensions, 4 features
Firewall:        Deny-all
Base Image:      mcr.microsoft.com/devcontainers/javascript-node:22

Host Reachability: Dev servers must bind 0.0.0.0 (not localhost)
```

If an existing `.devcontainer/` directory was detected in Step 0, an **overwrite warning** is shown.

You then choose:

- **Generate files** — proceed to file generation (Step 9)
- **Let me adjust something** — revisit a specific step, then return to recap
- **Start over** — restart from Step 1

## Step 9: Generate Files

The plugin generates 7 files by reading template skeletons and replacing `{{PLACEHOLDER}}` markers with content assembled from the selected stack/service/tool reference files.

1. **Fetch base image** — `WebFetch` to `https://containers.dev/templates` to find the best official devcontainer image for the primary stack
2. **Read templates** from the plugin's `references/templates/` directory
3. **Compose final content** by replacing each placeholder with assembled blocks from the loaded reference files
4. **Write 7 files** to `.devcontainer/`

See [Generated Files](./generated-files) for a detailed breakdown of each file.

After generation, the plugin displays a summary with next steps:
- Open in VS Code → **Dev Containers: Rebuild Container**
- Review `firewall-rules.conf` for your network policy
- Check `DEVCONTAINER.md` for service credentials and host binding

## CLI Argument Shortcuts

You can pass context when invoking the skill to pre-select options:

| Argument | Effect |
|----------|--------|
| `"Next.js with PostgreSQL"` | Pre-selects Node.js stack + PostgreSQL service |
| `"no firewall"` | Sets firewall policy to allow-all |
| `"Claude Code only"` | Pre-selects only Claude Code in Step 3 |
| `"Python Django Redis"` | Pre-selects Python stack + Redis service |

These shortcuts are parsed in Step 0 and used to pre-populate subsequent steps, reducing the number of confirmations needed.
