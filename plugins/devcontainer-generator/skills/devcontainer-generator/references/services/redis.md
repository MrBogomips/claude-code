# Redis

## Docker Compose Service

```yaml
redis:
  image: redis:7-alpine
  restart: unless-stopped
  volumes:
    - devcontainer-{{PROJECT_NAME}}-redis-data:/data
  ports:
    - "6379:6379"
  healthcheck:
    test: ["CMD", "redis-cli", "ping"]
    interval: 10s
    timeout: 5s
    retries: 5
```

## Connection Strings

| Language | Connection String |
|----------|------------------|
| Node.js  | `redis://redis:6379` |
| Python   | `redis://redis:6379/0` |
| .NET     | `redis:6379` |
| Go       | `redis://redis:6379/0` |
| Java     | `redis://redis:6379` |

## Default Credentials

- No authentication by default
- Database: `0` (default)

## Environment Variables

| Variable | Value |
|----------|-------|
| `ConnectionStrings__Redis` | `redis:6379` |

## Named Volumes

| Volume Name | Mount Path |
|-------------|------------|
| `devcontainer-{{PROJECT_NAME}}-redis-data` | `/data` |

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 6379 | TCP      | Redis protocol |

## VS Code Extensions

- `cweijan.vscode-redis-client` — Redis explorer and command interface

## Client Tools (apt)

- `redis-tools` — provides `redis-cli` for interactive command-line access
