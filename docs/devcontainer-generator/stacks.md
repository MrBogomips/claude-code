---
sidebar_position: 3
title: Language Stacks
---

# Language Stacks

Reference for the 6 supported language stacks. Each stack defines a base image, detection patterns, frameworks, package managers, VS Code extensions, shell aliases, environment variables, firewall domains, and host binding guidance.

All stacks share a single base image: `mcr.microsoft.com/devcontainers/base:ubuntu-24.04`. Languages are installed via [devcontainer features](https://containers.dev/features) (primary stack) or Dockerfile runtime layers (secondary stacks).

---

## Node.js

### Base Image

`mcr.microsoft.com/devcontainers/base:ubuntu-24.04`

### Devcontainer Feature

```json
{
  "ghcr.io/devcontainers/features/node:1": {
    "version": "22"
  }
}
```

### Detection

| File | Meaning |
|------|---------|
| `package.json` | Primary indicator; checks `engines.node` for version |
| `pnpm-lock.yaml` | pnpm project |
| `yarn.lock` | Yarn project |
| `package-lock.json` | npm project |
| `bun.lockb` | Bun project |
| `.nvmrc` / `.node-version` | Pinned Node version |
| `tsconfig.json` | TypeScript variant |

### Frameworks

| Framework | Detection | Dev Port | Telemetry Opt-Out |
|-----------|----------|----------|-------------------|
| **Next.js** | `next.config.js`, `.mjs`, `.ts` | 3000 | `NEXT_TELEMETRY_DISABLED=1` |
| **Angular** | `angular.json`, `nx.json` | 4200 | `NG_CLI_ANALYTICS=false` |
| **Vite** | `vite.config.js`, `.ts`, `.mjs` | 5173 | — |
| **Nuxt** | `nuxt.config.js`, `.ts` | 3000 | `NUXT_TELEMETRY_DISABLED=1` |
| **Remix** | `remix.config.js`, `.ts` | 3000 | — |
| **Docusaurus** | `docusaurus.config.js`, `.ts` | 3000 | — |
| **Storybook** | `.storybook/` directory | 6006 | — |

### Package Managers

| Lock File | Manager | Install Command | Cache Volume Mount |
|-----------|---------|-----------------|-------------------|
| `package-lock.json` | npm | `npm ci` | `/home/vscode/.npm` |
| `pnpm-lock.yaml` | pnpm | `pnpm install --frozen-lockfile` | `/home/vscode/.local/share/pnpm/store` |
| `yarn.lock` | Yarn | `yarn install --frozen-lockfile` | `/home/vscode/.yarn/cache` |
| `bun.lockb` | Bun | `bun install --frozen-lockfile` | `/home/vscode/.bun/install/cache` |

### VS Code Extensions

- `dbaeumer.vscode-eslint` — ESLint integration
- `esbenp.prettier-vscode` — Prettier formatter
- `bradlc.vscode-tailwindcss` — Tailwind CSS IntelliSense
- `angular.ng-template` — Angular language service (Angular projects)
- `dsznajder.es7-react-js-snippets` — React/Redux snippets (React projects)
- `ms-playwright.playwright` — Playwright test runner

### Aliases

```bash
alias pn="pnpm"    pni="pnpm install"    pnr="pnpm run"    pnd="pnpm dev"
alias yi="yarn install"    yr="yarn run"
alias ni="npm install"     nr="npm run"      nd="npm run dev"
```

### Environment Variables

```json
{
  "NEXT_TELEMETRY_DISABLED": "1",
  "NG_CLI_ANALYTICS": "false",
  "NUXT_TELEMETRY_DISABLED": "1",
  "GATSBY_TELEMETRY_DISABLED": "1"
}
```

### Host Binding

Dev servers must bind to `0.0.0.0` to be reachable from the host:

| Framework | Command |
|-----------|---------|
| Next.js | `next dev -H 0.0.0.0` |
| Vite | `vite --host 0.0.0.0` |
| Angular | `ng serve --host 0.0.0.0` |
| Nuxt | `nuxt dev --host 0.0.0.0` |
| Remix | `remix dev --host 0.0.0.0` |
| Docusaurus | `docusaurus start --host 0.0.0.0` |
| Storybook | `storybook dev --host 0.0.0.0` |

### Firewall Domains

```
ALLOW registry.npmjs.org        ALLOW *.npmjs.org
ALLOW *.npmjs.com               ALLOW nodejs.org
ALLOW deb.nodesource.com        ALLOW yarnpkg.com
ALLOW pnpm.io                   ALLOW volta.sh
ALLOW esm.sh                    ALLOW unpkg.com
ALLOW cdn.jsdelivr.net
```

---

## Python

### Base Image

`mcr.microsoft.com/devcontainers/base:ubuntu-24.04`

### Devcontainer Feature

```json
{
  "ghcr.io/devcontainers/features/python:1": {
    "version": "3.12"
  }
}
```

### Detection

| File | Meaning |
|------|---------|
| `requirements.txt` | pip dependencies |
| `pyproject.toml` | Modern Python project (`[tool.poetry]` → Poetry, `[project]` → PEP 621) |
| `setup.py` | Legacy setuptools project |
| `Pipfile` | Pipenv project |
| `setup.cfg` | Setuptools declarative config |
| `.python-version` | Pinned Python version |
| `uv.lock` | uv project |

### Frameworks

| Framework | Detection | Dev Port | Config |
|-----------|----------|----------|--------|
| **Flask** | `flask` in dependencies | 5000 | `FLASK_APP`, `FLASK_ENV=development` |
| **Django** | `manage.py`, `django` in deps | 8000 | `DJANGO_SETTINGS_MODULE` |
| **FastAPI** | `fastapi` in dependencies | 8000 | — |

### Package Managers

| Lock File | Manager | Install Command | Cache Volume Mount |
|-----------|---------|-----------------|-------------------|
| `requirements.txt` | pip | `pip install -r requirements.txt` | `/home/vscode/.cache/pip` |
| `poetry.lock` | Poetry | `poetry install --no-interaction` | `/home/vscode/.cache/pypoetry` |
| `Pipfile.lock` | Pipenv | `pipenv install --deploy` | `/home/vscode/.cache/pipenv` |
| `uv.lock` | uv | `uv sync` | `/home/vscode/.cache/uv` |

### VS Code Extensions

- `ms-python.python` — Python language support, debugging, IntelliSense
- `ms-python.vscode-pylance` — Fast, feature-rich language server

### Aliases

```bash
alias venv="python3 -m venv .venv && source .venv/bin/activate"
alias pipi="pip install -r requirements.txt"
```

### Environment Variables

```json
{
  "PYTHONUNBUFFERED": "1",
  "PYTHONDONTWRITEBYTECODE": "1"
}
```

### Host Binding

| Framework | Command |
|-----------|---------|
| Flask | `flask run --host=0.0.0.0` |
| Django | `python manage.py runserver 0.0.0.0:8000` |
| FastAPI | `uvicorn app:app --host 0.0.0.0` |

### Firewall Domains

```
ALLOW pypi.org              ALLOW *.pypi.org
ALLOW files.pythonhosted.org
```

---

## .NET

### Base Image

`mcr.microsoft.com/devcontainers/base:ubuntu-24.04`

### Devcontainer Feature

```json
{
  "ghcr.io/devcontainers/features/dotnet:2": {
    "version": "10.0"
  }
}
```

### Detection

| File | Meaning |
|------|---------|
| `*.csproj` | C# project file |
| `*.fsproj` | F# project file |
| `*.sln` / `*.slnx` | Solution file |
| `global.json` | Pinned SDK version (`sdk.version`) |
| `Directory.Build.props` | Shared build properties |

### Frameworks

| Framework | Detection | Dev Port(s) | Config |
|-----------|----------|-------------|--------|
| **ASP.NET Core** | `Microsoft.AspNetCore` in `*.csproj` | 5000 (HTTP), 5001 (HTTPS) | `launchSettings.json` |
| **Blazor** | `Microsoft.AspNetCore.Components` in `*.csproj` | 5000 | — |
| **.NET Aspire** | `Aspire.Hosting` / `Aspire.Dashboard` in `*.csproj` | 18888 (Dashboard) | `dotnet workload install aspire` |

### Package Managers

| Lock File | Manager | Install Command | Cache Volume Mount |
|-----------|---------|-----------------|-------------------|
| `packages.lock.json` | NuGet | `dotnet restore --locked-mode` | `/home/vscode/.nuget` |

### VS Code Extensions

- `ms-dotnettools.csdevkit` — C# Dev Kit (project system, test explorer, solution management)
- `ms-dotnettools.csharp` — C# language support
- `ms-dotnettools.vscode-dotnet-runtime` — .NET runtime install tool

### Aliases

```bash
alias dn="dotnet"    dnr="dotnet run"    dnb="dotnet build"
alias dnt="dotnet test"    dnw="dotnet watch"
```

### Environment Variables

```json
{
  "DOTNET_CLI_TELEMETRY_OPTOUT": "1",
  "ASPNETCORE_ENVIRONMENT": "Development",
  "DOTNET_RUNNING_IN_CONTAINER": "true"
}
```

### Host Binding

| Method | Command |
|--------|---------|
| dotnet run | `dotnet run --urls http://0.0.0.0:5000` |
| dotnet watch | `dotnet watch --urls http://0.0.0.0:5000` |
| launchSettings.json | `"applicationUrl": "http://0.0.0.0:5000"` |

### Firewall Domains

```
ALLOW api.nuget.org          ALLOW *.nuget.org
ALLOW dotnet.microsoft.com   ALLOW dotnetcli.azureedge.net
ALLOW *.microsoft.com
```

---

## Go

### Base Image

`mcr.microsoft.com/devcontainers/base:ubuntu-24.04`

### Devcontainer Feature

```json
{
  "ghcr.io/devcontainers/features/go:1": {
    "version": "1.23"
  }
}
```

### Detection

| File | Meaning |
|------|---------|
| `go.mod` | Primary indicator; contains module path and Go version |
| `go.sum` | Dependency checksums |

### Frameworks

| Framework | Detection | Dev Port |
|-----------|----------|----------|
| **Gin** | `github.com/gin-gonic/gin` in `go.mod` | 8080 |
| **Echo** | `github.com/labstack/echo` in `go.mod` | 8080 |
| **Fiber** | `github.com/gofiber/fiber` in `go.mod` | 3000 |

### Package Managers

| Lock File | Manager | Install Command | Cache Volume Mount |
|-----------|---------|-----------------|-------------------|
| `go.sum` | Go modules | `go mod download` | `/home/vscode/go/pkg/mod` |

### VS Code Extensions

- `golang.go` — Go language support (IntelliSense, debugging, testing, linting)

### Aliases

```bash
alias gr="go run ."    gb="go build"    gt="go test ./..."
```

### Environment Variables

```json
{
  "GOPATH": "/home/vscode/go",
  "GOFLAGS": "-buildvcs=false"
}
```

### Host Binding

Go frameworks bind via address strings. Ensure `0.0.0.0`:

| Framework | Binding |
|-----------|---------|
| Standard library | `http.ListenAndServe(":8080", handler)` |
| Gin | `router.Run(":8080")` — all interfaces by default |
| Echo | `e.Start(":8080")` — all interfaces by default |
| Fiber | `app.Listen(":3000")` — all interfaces by default |

### Firewall Domains

```
ALLOW proxy.golang.org      ALLOW sum.golang.org
ALLOW storage.googleapis.com ALLOW go.dev
```

---

## Rust

### Base Image

`mcr.microsoft.com/devcontainers/base:ubuntu-24.04`

### Devcontainer Feature

```json
{
  "ghcr.io/devcontainers/features/rust:1": {
    "version": "latest"
  }
}
```

### Detection

| File | Meaning |
|------|---------|
| `Cargo.toml` | Primary indicator; package metadata and dependencies |
| `Cargo.lock` | Locked dependency versions |
| `rust-toolchain.toml` / `rust-toolchain` | Pinned toolchain version |

### Frameworks

| Framework | Detection | Dev Port |
|-----------|----------|----------|
| **Actix Web** | `actix-web` in `Cargo.toml` dependencies | 8080 |
| **Axum** | `axum` in `Cargo.toml` dependencies | 3000 |
| **Rocket** | `rocket` in `Cargo.toml` dependencies | 8000 |

### Package Managers

| Lock File | Manager | Install Command | Cache Volume Mount |
|-----------|---------|-----------------|-------------------|
| `Cargo.lock` | Cargo | `cargo build` | `/usr/local/cargo/registry` |
| — | — | — | `/workspaces/{{PROJECT_NAME}}/target` |

Two cache volumes are used: one for the cargo registry, one for the build target directory.

### VS Code Extensions

- `rust-lang.rust-analyzer` — Rust language server (IntelliSense, diagnostics, refactoring)
- `serayuzgur.crates` — Crate version management in `Cargo.toml`

### Aliases

```bash
alias cr="cargo run"    cb="cargo build"    ct="cargo test"    cc="cargo check"
```

### Environment Variables

```json
{
  "CARGO_HOME": "/usr/local/cargo",
  "RUSTUP_HOME": "/usr/local/rustup"
}
```

### Host Binding

| Framework | Binding |
|-----------|---------|
| Actix Web | `HttpServer::new(...).bind("0.0.0.0:8080")` |
| Axum | `TcpListener::bind("0.0.0.0:3000").await` |
| Rocket | Set `address = "0.0.0.0"` in `Rocket.toml` under `[default]` |

### Firewall Domains

```
ALLOW crates.io              ALLOW static.crates.io
ALLOW index.crates.io        ALLOW doc.rust-lang.org
ALLOW static.rust-lang.org
```

---

## Java

### Base Image

`mcr.microsoft.com/devcontainers/base:ubuntu-24.04`

### Devcontainer Feature

```json
{
  "ghcr.io/devcontainers/features/java:1": {
    "version": "21",
    "installMaven": "true",
    "installGradle": "true"
  }
}
```

### Detection

| File | Meaning |
|------|---------|
| `pom.xml` | Maven project |
| `build.gradle` | Gradle project (Groovy DSL) |
| `build.gradle.kts` | Gradle project (Kotlin DSL) |
| `.mvn/` | Maven wrapper directory |
| `gradlew` | Gradle wrapper script |
| `settings.gradle` / `settings.gradle.kts` | Multi-module Gradle project |

### Frameworks

| Framework | Detection | Dev Port | CLI Command |
|-----------|----------|----------|-------------|
| **Spring Boot** | `spring-boot-starter` in build file | 8080 | `./mvnw spring-boot:run` or `./gradlew bootRun` |
| **Quarkus** | `quarkus` in build file | 8080 | `./mvnw quarkus:dev` or `./gradlew quarkusDev` |
| **Micronaut** | `micronaut` in build file | 8080 | `./mvnw mn:run` or `./gradlew run` |

### Package Managers

| Lock File | Manager | Install Command | Cache Volume Mount |
|-----------|---------|-----------------|-------------------|
| — | Maven | `./mvnw dependency:resolve` | `/home/vscode/.m2` |
| `gradle.lockfile` | Gradle | `./gradlew dependencies` | `/home/vscode/.gradle` |

### VS Code Extensions

- `vscjava.vscode-java-pack` — Java Extension Pack (language support, debugger, test runner, Maven, project manager)
- `vmware.vscode-spring-boot` — Spring Boot tools (Spring Boot projects)
- `redhat.vscode-quarkus` — Quarkus tools (Quarkus projects)

### Aliases

```bash
alias mvn="./mvnw"    gradle="./gradlew"
```

### Environment Variables

```json
{
  "JAVA_HOME": "/usr/lib/jvm/java-21-openjdk-amd64",
  "MAVEN_OPTS": "-Xmx512m",
  "GRADLE_OPTS": "-Xmx512m"
}
```

### Host Binding

| Framework | Configuration |
|-----------|--------------|
| Spring Boot | `server.address=0.0.0.0` in `application.properties` |
| Quarkus | `quarkus.http.host=0.0.0.0` in `application.properties` |
| Micronaut | `micronaut.server.host=0.0.0.0` in `application.yml` |

### Firewall Domains

```
ALLOW repo1.maven.org        ALLOW repo.maven.apache.org
ALLOW plugins.gradle.org     ALLOW services.gradle.org
ALLOW jcenter.bintray.com
```
