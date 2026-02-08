# Supported Stacks

The Devcontainer Generator supports six language stacks. During setup, it scans your repository for detection files and proposes the matching stacks with sensible defaults.

## Stack reference

| Stack | Detection files | Default version | Base image | Common frameworks | Default extensions |
|-------|----------------|-----------------|------------|-------------------|-------------------|
| Node.js | `package.json`, `tsconfig.json`, `.nvmrc` | 22 | `mcr.microsoft.com/devcontainers/javascript-node:22` | Next.js, Angular, Vite, Nuxt, Remix, Docusaurus, Storybook | ESLint, Prettier, Tailwind CSS |
| Python | `requirements.txt`, `pyproject.toml`, `setup.py`, `Pipfile`, `uv.lock` | 3.12 | `mcr.microsoft.com/devcontainers/python:3.12` | Flask, Django, FastAPI | Python, Pylance |
| .NET | `*.csproj`, `*.fsproj`, `*.sln`, `global.json` | 10.0 | `mcr.microsoft.com/devcontainers/dotnet:10.0` | ASP.NET Core, Blazor, .NET Aspire | C# Dev Kit, C#, .NET Runtime |
| Go | `go.mod`, `go.sum` | 1.23 | `mcr.microsoft.com/devcontainers/go:1.23` | Gin, Echo, Fiber | Go |
| Rust | `Cargo.toml`, `Cargo.lock`, `rust-toolchain.toml` | latest | `mcr.microsoft.com/devcontainers/rust:latest` | Actix Web, Axum, Rocket | rust-analyzer, crates |
| Java | `pom.xml`, `build.gradle`, `build.gradle.kts` | 21 | `mcr.microsoft.com/devcontainers/java:21` | Spring Boot, Quarkus, Micronaut | Java Extension Pack, Spring Boot Tools |

## Multi-stack projects

When your repository uses more than one language, the generator handles it as follows:

- **Primary stack selection** -- the first stack you select in the guided workflow becomes the primary. Its official Microsoft base image is used for the container.
- **Layering in Dockerfile** -- additional stacks are installed as layers on top of the primary base image. For example, if you select Node.js as primary and Python as secondary, the Dockerfile starts from the Node.js image and adds Python via `apt-get` and runtime setup.
- **Extensions and features** -- VS Code extensions and devcontainer features from all selected stacks are merged into the final configuration.

## Monorepo support

The generator detects monorepo structures through the following indicators:

- `pnpm-workspace.yaml`
- `nx.json`
- `turbo.json`
- `lerna.json`
- `apps/`, `packages/`, or `services/` directories

When a monorepo is detected, the generator aggregates configuration across the workspace -- combining dependencies, framework detection, and service requirements from all sub-projects into a single devcontainer setup.
