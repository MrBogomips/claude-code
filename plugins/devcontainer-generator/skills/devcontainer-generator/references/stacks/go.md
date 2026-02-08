# Go

## Base Image
mcr.microsoft.com/devcontainers/go:1.23

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

When layered on a non-native base image:

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

## Combo Templates

- `go-postgres` — Go + PostgreSQL
