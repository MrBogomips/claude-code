---
sidebar_position: 3
sidebar_label: Template Selection
title: Template Selection
---

# Template Selection

The generator selects a base container template by matching your detected tech stack against the official devcontainer registry.

## Dynamic fetching

At runtime, the skill fetches the current template list from [containers.dev/templates](https://containers.dev/templates). This means template references stay current without requiring plugin updates. The fetched list is cached for the duration of the generation session.

## Matching algorithm

The matching algorithm has four tiers, evaluated in order:

### 1. Exact match

If the detected stack maps directly to an official template, that template is used.

| Detected stack | Template |
|---------------|----------|
| Python | `python` |
| Node.js | `javascript-node` |
| TypeScript | `typescript-node` |
| .NET | `dotnet` |
| Go | `go` |
| Rust | `rust` |
| Java | `java` |

### 2. Combo match (language + database)

If both a language and a database are detected, the skill prefers a combo template that includes both:

| Stack | Database | Combo template |
|-------|----------|---------------|
| Python | PostgreSQL | `python-3-postgres` |
| Node.js | PostgreSQL | `javascript-node-postgres` |
| Node.js | MongoDB | `javascript-node-mongo` |

If no combo template exists for the detected pair, the language template is used and the database is added via Docker Compose instead.

### 3. Multiple matches

When more than one template could apply (for example, a Node.js project could use `javascript-node`, `typescript-node`, or `universal`), the skill presents the options and asks you to choose. Microsoft official templates are listed first.

### 4. Fallback to Universal

If no specific template matches the detected stack, the `universal` template is selected. This is a multi-language image that supports many runtimes out of the box.

## Monorepo and multi-stack handling

When multiple tech stacks are detected (for example, a Node.js frontend, a .NET backend, and Python scripts), the skill identifies the primary stack by:

1. Root-level config files (weighted higher)
2. File count per language
3. User's stated intent (from the interactive flow)

If the primary stack is ambiguous, you are asked to choose. The selected stack determines the base template, and additional runtimes are layered in the Dockerfile. See [How It Works](how-it-works.md) for the full analysis flow and [Generated Files](generated-files.md) for how multi-runtime Dockerfiles are structured.

## Why a Dockerfile is always generated

Even when the selected template could be used directly via `image` in devcontainer.json, the generator always produces a Dockerfile. This ensures:

- A customization point for adding system dependencies not in the base image
- Documentation of the full tech stack in a single place
- Support for multi-runtime layering in monorepo projects

## Official template sources

### Microsoft official (preferred)

Registry: `ghcr.io/devcontainers/templates/`

| Template | Use case |
|----------|----------|
| `alpine` | Minimal Alpine Linux |
| `debian` | Debian base |
| `ubuntu` | Ubuntu base |
| `dotnet` | .NET SDK |
| `go` | Go language |
| `java` | Java JDK |
| `javascript-node` | Node.js |
| `typescript-node` | TypeScript with Node.js |
| `python` | Python 3 |
| `rust` | Rust toolchain |
| `universal` | Multi-language universal image |

### Community templates

Community templates from the fetched list are used only when no official template covers the use case. Examples include specialized templates for quantum computing (Julia, Qiskit), robotics (ROS), enterprise (Salesforce DX, SAP), and scientific computing (R, Miniconda).
