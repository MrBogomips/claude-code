# Supported Stacks

The Devcontainer Generator supports six language stacks. During setup, it scans your repository for detection files and proposes the matching stacks with sensible defaults.

## Base image strategy

All stacks share a single base image: **`mcr.microsoft.com/devcontainers/base:ubuntu-24.04`**. Languages are installed via [devcontainer features](https://containers.dev/features) rather than language-specific container images.

Why this approach:

- **Stability** — Ubuntu 24.04 LTS is supported until 2029. The underlying OS cannot be silently changed by upstream image maintainers, unlike language-specific images whose OS layer is a rolling target.
- **Control** — Language versions are explicitly declared as feature parameters (e.g., `"version": "22"` for Node.js). The version is never implicitly tied to an opaque image tag.
- **Consistency** — Every generated container starts from the same OS. System packages, paths, user accounts, and capabilities are identical regardless of the language stack, eliminating cross-stack compatibility surprises.

## Stack reference

| Stack | Detection files | Default version | Language feature | Common frameworks | Default extensions |
|-------|----------------|-----------------|-----------------|-------------------|-------------------|
| Node.js | `package.json`, `tsconfig.json`, `.nvmrc` | 22 | `ghcr.io/devcontainers/features/node:1` | Next.js, Angular, Vite, Nuxt, Remix, Docusaurus, Storybook | ESLint, Prettier, Tailwind CSS |
| Python | `requirements.txt`, `pyproject.toml`, `setup.py`, `Pipfile`, `uv.lock` | 3.12 | `ghcr.io/devcontainers/features/python:1` | Flask, Django, FastAPI | Python, Pylance |
| .NET | `*.csproj`, `*.fsproj`, `*.sln`, `global.json` | 10.0 | `ghcr.io/devcontainers/features/dotnet:2` | ASP.NET Core, Blazor, .NET Aspire | C# Dev Kit, C#, .NET Runtime |
| Go | `go.mod`, `go.sum` | 1.23 | `ghcr.io/devcontainers/features/go:1` | Gin, Echo, Fiber | Go |
| Rust | `Cargo.toml`, `Cargo.lock`, `rust-toolchain.toml` | latest | `ghcr.io/devcontainers/features/rust:1` | Actix Web, Axum, Rocket | rust-analyzer, crates |
| Java | `pom.xml`, `build.gradle`, `build.gradle.kts` | 21 | `ghcr.io/devcontainers/features/java:1` | Spring Boot, Quarkus, Micronaut | Java Extension Pack, Spring Boot Tools |

## Multi-stack projects

When your repository uses more than one language, the generator handles it as follows:

- **Shared base image** — all stacks use `mcr.microsoft.com/devcontainers/base:ubuntu-24.04`. The base image does not change based on which stack is primary.
- **Primary stack** — the first selected language is installed via its devcontainer feature in `devcontainer.json` (e.g., `node:1` for Node.js).
- **Secondary stacks** — additional languages are installed via runtime layers in the Dockerfile. Each stack's reference file includes the Dockerfile commands used for this purpose.
- **Merged configuration** — VS Code extensions, editor settings, forwarded ports, and environment variables from all selected stacks are combined into the final configuration.

## Monorepo support

The generator detects monorepo structures through the following indicators:

- `pnpm-workspace.yaml`
- `nx.json`
- `turbo.json`
- `lerna.json`
- `apps/`, `packages/`, or `services/` directories

When a monorepo is detected, the generator aggregates configuration across the workspace -- combining dependencies, framework detection, and service requirements from all sub-projects into a single devcontainer setup.

## Credential files

Each stack defines credential files that can be shared from the host to the container via read-only bind mounts. This enables seamless authentication with private registries without manual setup.

| Stack | Credential Files | Pre-Selected | Fallback Env Vars |
|-------|-----------------|-------------|-------------------|
| Node.js | `~/.npmrc`, `~/.yarnrc.yml` | `.npmrc` always; `.yarnrc.yml` if Yarn Berry | `NPM_TOKEN`, `YARN_NPM_AUTH_TOKEN` |
| Python | `~/.pip/pip.conf`, `~/.pypirc` | `pip.conf` always; `.pypirc` optional | `PIP_INDEX_URL`, `TWINE_PASSWORD` |
| .NET | `~/.nuget/NuGet.Config` | Always | `NUGET_AUTH_TOKEN` |
| Go | `~/.netrc`, `GOPRIVATE`/`GONOSUMCHECK` (env) | Always | `GONOSUMDB` |
| Rust | `~/.cargo/credentials.toml` | Always | `CARGO_REGISTRY_TOKEN` |
| Java | `~/.m2/settings.xml`, `~/.gradle/gradle.properties` | Maven/Gradle detection | `MAVEN_SERVER_PASSWORD`, `GRADLE_PUBLISH_KEY` |

Credential sharing is configured in **Step 1b** of the interactive workflow. See [Customization](customization.md) for details on modifying credential behavior after generation.
