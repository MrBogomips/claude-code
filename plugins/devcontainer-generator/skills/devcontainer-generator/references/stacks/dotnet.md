# .NET

## Base Image
mcr.microsoft.com/devcontainers/dotnet:10.0

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

When layered on a non-native base image:

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

## Combo Templates

- `dotnet-postgres` — .NET + PostgreSQL
- `dotnet-mssql` — .NET + SQL Server
