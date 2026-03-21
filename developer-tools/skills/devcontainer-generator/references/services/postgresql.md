# PostgreSQL (with PostGIS)

## Docker Compose Service

```yaml
postgres:
  image: postgis/postgis:16-3.4
  restart: unless-stopped
  volumes:
    - devcontainer-{{PROJECT_NAME}}-postgres-data:/var/lib/postgresql/data
  environment:
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: postgres
    POSTGRES_DB: {{PROJECT_NAME}}
  ports:
    - "5432:5432"
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U postgres"]
    interval: 10s
    timeout: 5s
    retries: 5
```

## Connection Strings

| Language | Connection String |
|----------|------------------|
| Node.js  | `postgresql://postgres:postgres@postgres:5432/{{PROJECT_NAME}}` |
| Python   | `postgresql://postgres:postgres@postgres:5432/{{PROJECT_NAME}}` |
| .NET     | `Host=postgres;Port=5432;Database={{PROJECT_NAME}};Username=postgres;Password=postgres` |
| Go       | `postgres://postgres:postgres@postgres:5432/{{PROJECT_NAME}}?sslmode=disable` |
| Java     | `jdbc:postgresql://postgres:5432/{{PROJECT_NAME}}` |

## Default Credentials

- Username: `postgres`
- Password: `postgres`
- Database: `{{PROJECT_NAME}}`

## Environment Variables

| Variable | Value |
|----------|-------|
| `ConnectionStrings__PostgreSQL` | `Host=postgres;Port=5432;Database={{PROJECT_NAME}};Username=postgres;Password=postgres` |

## Named Volumes

| Volume Name | Mount Path |
|-------------|------------|
| `devcontainer-{{PROJECT_NAME}}-postgres-data` | `/var/lib/postgresql/data` |

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 5432 | TCP      | PostgreSQL wire protocol |

## VS Code Extensions

- `ckolkman.vscode-postgres` — PostgreSQL explorer and query runner

## Client Tools (apt)

- `postgresql-client` — provides `psql`, `pg_dump`, `pg_restore` and other CLI utilities
