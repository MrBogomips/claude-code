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

The skill first checks whether the directory is empty or contains only hidden files (like `.git`). If so, it skips stack detection and jumps to [Phase 1b](#phase-1b-interactive-stack-discovery) for interactive setup.

Otherwise, it fetches the current template list from [containers.dev/templates](https://containers.dev/templates) to keep template references current, then reads project files to identify your stack across six categories: **languages** (Node.js, .NET, Python, Go, Rust, Java), **package managers** (pnpm, Yarn, npm, Bun), **frameworks** (Angular, Next.js, Nuxt, Vite, Docusaurus, Storybook), **services** (PostgreSQL, MySQL, MongoDB, Redis, RabbitMQ, Kafka), **cloud providers** (Azure, AWS, GCP), and **monorepo tools** (pnpm workspaces, Lerna, Nx, Turborepo, directory conventions). Both root and subdirectories are scanned. See the [Overview](index.md) for the full detection tables.

After detection, the skill matches your stack to official templates — see [Template Selection](template-system.md) for the algorithm.

If a `.devcontainer/` directory already exists, the skill asks whether to **overwrite** (replace all files), **merge** (preserve customizations where possible), or **cancel** generation.

## Phase 1b: Interactive stack discovery

For empty repositories or projects where no tech stack is detected, the skill walks you through a 6-step interactive setup: usage intent, application type, primary language, framework, package manager, and services. Each step filters options based on prior answers — for example, framework choices depend on the selected language.

If you choose **Claude-Only** in the first step, the skill skips to file generation with a minimal container template and **deny-all firewall enabled by default** — ideal for running Claude Code in YOLO mode inside a secure, isolated environment. See [Network Firewall](firewall.md) for enforcement details.

## Phase 2: User preference questions

After analysis, the skill asks six questions to customize the generated configuration:

| # | Topic | Type |
|---|-------|------|
| Q1 | Agentic coding assistant (Claude Code with CCometixLine, Claude Code only, none, other) | Single-select |
| Q2 | Developer tools (gh, fzf, httpie, ripgrep) | Multi-select |
| Q3 | Shell preference (Zsh + Oh My Zsh, Fish, Bash) | Single-select |
| Q4 | Detected services and storage emulators to include | Multi-select |
| Q5 | Runtime version confirmation / override | Confirmation |
| Q6 | Network firewall policy (deny-all, allow-all, disabled) | Single-select |

Q4 and Q5 only appear when services or versions were detected during Phase 1. See [Network Firewall](firewall.md) for details on how firewall enforcement works.

## Phase 3: File generation

The skill resolves a set of internal templates against your detected stack and preference answers to produce the final configuration files. Conditional sections are included or excluded based on your choices — for example, selecting deny-all firewall adds post-start enforcement rules, while choosing Claude Code with CCometixLine adds the full installation block to `post-create.sh`.

The complete set of generated files is documented in [Generated Files](generated-files.md).
