# Go

## Base Image
mcr.microsoft.com/devcontainers/base:ubuntu-24.04

## Detection
- `go.mod` — primary indicator; contains module path and Go version
- `go.sum` — dependency checksums

## Frameworks

### Gin
- Detection: `github.com/gin-gonic/gin` in `go.mod`
- Default port: 8080

### Echo
- Detection: `github.com/labstack/echo` in `go.mod`
- Default port: 8080

### Fiber
- Detection: `github.com/gofiber/fiber` in `go.mod`
- Default port: 3000

## Package Managers

| Lock File | Manager | Install Command | Cache Volume |
|-----------|---------|-----------------|--------------|
| `go.sum` | go modules | `go mod download` | `devcontainer-{{PROJECT_NAME}}-gomod` mounted at `/home/vscode/go/pkg/mod` |

## Dockerfile Layers

When added as a secondary stack in a multi-stack project:

```dockerfile
RUN wget https://go.dev/dl/go1.23.0.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz \
    && rm go1.23.0.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/home/vscode/go"
ENV PATH="${GOPATH}/bin:${PATH}"
```

## Devcontainer Features

```json
{
  "ghcr.io/devcontainers/features/go:1": {
    "version": "1.23"
  }
}
```

## VS Code Extensions

- `golang.go` — Go language support (IntelliSense, debugging, testing, linting)

## Port Forwarding

| Port | Label | Condition |
|------|-------|-----------|
| 8080 | Go HTTP server | default for Gin, Echo, standard library |
| 3000 | Fiber | `github.com/gofiber/fiber` in `go.mod` |

## Host Binding

Go applications typically bind to a port via `net.Listen` or framework config. Ensure the listen address includes `0.0.0.0`:

- **Standard library**: `http.ListenAndServe(":8080", handler)` or `http.ListenAndServe("0.0.0.0:8080", handler)`
- **Gin**: `router.Run(":8080")` — binds to all interfaces by default
- **Echo**: `e.Start(":8080")` — binds to all interfaces by default
- **Fiber**: `app.Listen(":3000")` — binds to all interfaces by default

## Environment Variables

```json
{
  "GOPATH": "/home/vscode/go",
  "GOFLAGS": "-buildvcs=false"
}
```

## Post-Create Steps

```bash
# Download module dependencies
go mod download

# Install common tools
go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install honnef.co/go/tools/cmd/staticcheck@latest
```

## Aliases

```bash
alias gr="go run ."
alias gb="go build"
alias gt="go test ./..."
```

## Firewall Domains

```
ALLOW proxy.golang.org
ALLOW sum.golang.org
ALLOW storage.googleapis.com
ALLOW go.dev
```

## Credential Files

### ~/.netrc

- **Description**: Machine credentials for private Go modules (used by `go mod download` for authentication)
- **Host path**: `~/.netrc`
- **Mount target**: `/tmp/.netrc-host`
- **Pre-select**: Always pre-selected when Go is selected
- **Extraction type**: Dotfile — grep machine/login/password lines
- **initializeCommand**: `test -f "$HOME/.netrc" || touch "$HOME/.netrc"`
- **Mount**: `source=${localEnv:HOME}/.netrc,target=/tmp/.netrc-host,type=bind,readonly`
- **Fallback env var**: `GONOSUMDB`

#### Post-Create Extraction

```bash
if [ -s /tmp/.netrc-host ]; then
  log "Extracting .netrc credentials from host..."
  grep -E '^(machine|login|password|account|default)' /tmp/.netrc-host >> ~/.netrc 2>/dev/null || true
  chmod 600 ~/.netrc
elif [ -n "${GONOSUMDB:-}" ]; then
  log "⚠ No .netrc found but GOPRIVATE/GONOSUMDB are set. Private modules may require manual auth."
else
  log "⚠ No .netrc credentials found. Populate ~/.netrc on the host for private Go module access."
fi
```

#### DEVCONTAINER.md Block

| Host File | Container Path | Purpose | Fallback Env Var |
|-----------|---------------|---------|-----------------|
| `~/.netrc` | `/tmp/.netrc-host` | Go private module credentials | `GONOSUMDB` |

### Environment Variables (no mount required)

`GOPRIVATE` and `GONOSUMCHECK` control which Go modules bypass the public proxy and checksum database. These are shared via `remoteEnv` in `devcontainer.json` — no file mount or extraction is needed.

- **GOPRIVATE**: Comma-separated module path prefixes (e.g., `github.com/myorg/*`)
- **GONOSUMCHECK**: Module paths to skip checksum verification
- **remoteEnv entry**: `"GOPRIVATE": "${localEnv:GOPRIVATE}"`, `"GONOSUMCHECK": "${localEnv:GONOSUMCHECK}"`

