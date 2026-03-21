# .NET

## Base Image
mcr.microsoft.com/devcontainers/base:ubuntu-24.04

## Detection
- `*.csproj` — C# project file
- `*.fsproj` — F# project file
- `*.sln` — solution file
- `global.json` — check `sdk.version` for pinned SDK version
- `.mvn/` — should NOT be present (distinguishes from Java)
- `Directory.Build.props` — shared build properties
- `*.slnx` — new XML solution format

## Frameworks

### ASP.NET Core
- Detection: `Microsoft.AspNetCore` references in `*.csproj`, `Program.cs` with `WebApplication.CreateBuilder`
- CLI: `dotnet run`
- Dev port: 5000 (HTTP), 5001 (HTTPS)
- Config: `launchSettings.json` for port overrides

### Blazor
- Detection: `Microsoft.AspNetCore.Components` in `*.csproj`, `_Imports.razor`
- CLI: `dotnet run`
- Dev port: 5000

### .NET Aspire
- Detection: `.NET Aspire` packages in `*.csproj` (e.g., `Aspire.Hosting`, `Aspire.Dashboard`)
- CLI: `dotnet run --project *.AppHost`
- Setup: install Aspire workload via `dotnet workload install aspire`

## Package Managers

| Lock File | Manager | Install Command | Cache Volume |
|-----------|---------|-----------------|--------------|
| `packages.lock.json` | NuGet | `dotnet restore --locked-mode` | `devcontainer-{{PROJECT_NAME}}-nuget` mounted at `/home/vscode/.nuget` |

## Dockerfile Layers

When added as a secondary stack in a multi-stack project:

```dockerfile
RUN wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh \
    && chmod +x dotnet-install.sh \
    && ./dotnet-install.sh --channel 10.0 --install-dir /usr/share/dotnet \
    && ln -sf /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet-install.sh
```

## Devcontainer Features

```json
{
  "ghcr.io/devcontainers/features/dotnet:2": {
    "version": "10.0"
  }
}
```

## VS Code Extensions

- `ms-dotnettools.csdevkit` — C# Dev Kit (project system, test explorer, solution management)
- `ms-dotnettools.csharp` — C# language support (IntelliSense, debugging, refactoring)
- `ms-dotnettools.vscode-dotnet-runtime` — .NET runtime install tool

## Port Forwarding

| Port | Label | Condition |
|------|-------|-----------|
| 5000 | ASP.NET Core (HTTP) | `Microsoft.AspNetCore` in `*.csproj` |
| 5001 | ASP.NET Core (HTTPS) | `Microsoft.AspNetCore` in `*.csproj` |
| 18888 | Aspire Dashboard | Aspire packages detected |

## Host Binding

Bind to `0.0.0.0` so the dev server is reachable from the host:

- **dotnet run**: `dotnet run --urls http://0.0.0.0:5000`
- **dotnet watch**: `dotnet watch --urls http://0.0.0.0:5000`
- **launchSettings.json**: set `"applicationUrl": "http://0.0.0.0:5000"`

## Environment Variables

```json
{
  "DOTNET_CLI_TELEMETRY_OPTOUT": "1",
  "ASPNETCORE_ENVIRONMENT": "Development",
  "DOTNET_RUNNING_IN_CONTAINER": "true"
}
```

## Post-Create Steps

```bash
# Restore packages
dotnet restore

# Install global tools
dotnet tool install --global dotnet-ef
dotnet tool install --global dotnet-outdated-tool

# Trust dev certificates
dotnet dev-certs https --trust

# Install Aspire workload if needed
if grep -rq "Aspire" *.csproj 2>/dev/null; then
  dotnet workload install aspire
fi
```

## Aliases

```bash
alias dn="dotnet"
alias dnr="dotnet run"
alias dnb="dotnet build"
alias dnt="dotnet test"
alias dnw="dotnet watch"
```

## Firewall Domains

```
ALLOW api.nuget.org
ALLOW *.nuget.org
ALLOW dotnet.microsoft.com
ALLOW dotnetcli.azureedge.net
ALLOW *.microsoft.com
```

## Credential Files

### ~/.nuget/NuGet.Config

- **Description**: NuGet configuration with private feed credentials (Azure Artifacts, GitHub Packages, private NuGet servers)
- **Host path**: `~/.nuget/NuGet.Config`
- **Mount target**: `/tmp/.nuget-config-host`
- **Pre-select**: Always pre-selected when .NET is selected
- **Extraction type**: XML — copy entire file (XML splicing is unsafe)
- **initializeCommand**: `mkdir -p "$HOME/.nuget" && (test -f "$HOME/.nuget/NuGet.Config" || touch "$HOME/.nuget/NuGet.Config")`
- **Mount**: `source=${localEnv:HOME}/.nuget/NuGet.Config,target=/tmp/.nuget-config-host,type=bind,readonly`
- **Fallback env var**: `NUGET_AUTH_TOKEN`

#### Post-Create Extraction

```bash
if [ -s /tmp/.nuget-config-host ]; then
  log "Copying NuGet config from host ~/.nuget/NuGet.Config..."
  mkdir -p ~/.nuget
  cp /tmp/.nuget-config-host ~/.nuget/NuGet.Config
elif [ -n "${NUGET_AUTH_TOKEN:-}" ]; then
  log "Using NUGET_AUTH_TOKEN environment variable..."
  mkdir -p ~/.nuget
  dotnet nuget update source "private-feed" --username "deploy" --password "${NUGET_AUTH_TOKEN}" --store-password-in-clear-text 2>/dev/null || \
  cat > ~/.nuget/NuGet.Config << 'NUGETEOF'
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" />
  </packageSources>
</configuration>
NUGETEOF
else
  log "⚠ No NuGet credentials found. Set NUGET_AUTH_TOKEN or populate ~/.nuget/NuGet.Config on the host."
fi
```

#### DEVCONTAINER.md Block

| Host File | Container Path | Purpose | Fallback Env Var |
|-----------|---------------|---------|-----------------|
| `~/.nuget/NuGet.Config` | `/tmp/.nuget-config-host` | NuGet private feed credentials | `NUGET_AUTH_TOKEN` |

