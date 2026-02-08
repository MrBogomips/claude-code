# MySQL

## Docker Compose Service

```yaml
mysql:
  image: mysql:8
  restart: unless-stopped
  volumes:
    - devcontainer-{{PROJECT_NAME}}-mysql-data:/var/lib/mysql
  environment:
    MYSQL_ROOT_PASSWORD: root
    MYSQL_DATABASE: {{PROJECT_NAME}}
    MYSQL_USER: dev
    MYSQL_PASSWORD: dev
  ports:
    - "3306:3306"
  healthcheck:
    test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
    interval: 10s
    timeout: 5s
    retries: 5
```

## Connection Strings

| Language | Connection String |
|----------|------------------|
| Node.js  | `mysql://dev:dev@mysql:3306/{{PROJECT_NAME}}` |
| Python   | `mysql+pymysql://dev:dev@mysql:3306/{{PROJECT_NAME}}` |
| .NET     | `Server=mysql;Port=3306;Database={{PROJECT_NAME}};User=dev;Password=dev` |
| Go       | `dev:dev@tcp(mysql:3306)/{{PROJECT_NAME}}` |
| Java     | `jdbc:mysql://mysql:3306/{{PROJECT_NAME}}` |

## Default Credentials

- Root — Username: `root`, Password: `root`
- Application — Username: `dev`, Password: `dev`
- Database: `{{PROJECT_NAME}}`

## Environment Variables

| Variable | Value |
|----------|-------|
| `ConnectionStrings__MySQL` | `Server=mysql;Port=3306;Database={{PROJECT_NAME}};User=dev;Password=dev` |

## Named Volumes

| Volume Name | Mount Path |
|-------------|------------|
| `devcontainer-{{PROJECT_NAME}}-mysql-data` | `/var/lib/mysql` |

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 3306 | TCP      | MySQL wire protocol |

## VS Code Extensions

- `cweijan.vscode-mysql-client2` — MySQL client with query editor and table viewer

## Client Tools (apt)

- `mysql-client` — provides `mysql`, `mysqldump`, and other CLI utilities
