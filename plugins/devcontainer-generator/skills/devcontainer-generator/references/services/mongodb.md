# MongoDB

## Docker Compose Service

```yaml
mongodb:
  image: mongo:7
  restart: unless-stopped
  volumes:
    - devcontainer-{{PROJECT_NAME}}-mongodb-data:/data/db
  environment:
    MONGO_INITDB_ROOT_USERNAME: admin
    MONGO_INITDB_ROOT_PASSWORD: admin
  ports:
    - "27017:27017"
  healthcheck:
    test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
    interval: 10s
    timeout: 5s
    retries: 5
```

## Connection Strings

| Language | Connection String |
|----------|------------------|
| Node.js  | `mongodb://admin:admin@mongodb:27017/{{PROJECT_NAME}}?authSource=admin` |
| Python   | `mongodb://admin:admin@mongodb:27017/{{PROJECT_NAME}}?authSource=admin` |
| .NET     | `mongodb://admin:admin@mongodb:27017/{{PROJECT_NAME}}?authSource=admin` |
| Go       | `mongodb://admin:admin@mongodb:27017/{{PROJECT_NAME}}?authSource=admin` |
| Java     | `mongodb://admin:admin@mongodb:27017/{{PROJECT_NAME}}?authSource=admin` |

## Default Credentials

- Username: `admin`
- Password: `admin`
- Database: `{{PROJECT_NAME}}`
- Auth Source: `admin`

## Environment Variables

| Variable | Value |
|----------|-------|
| `ConnectionStrings__MongoDB` | `mongodb://admin:admin@mongodb:27017/{{PROJECT_NAME}}?authSource=admin` |

## Named Volumes

| Volume Name | Mount Path |
|-------------|------------|
| `devcontainer-{{PROJECT_NAME}}-mongodb-data` | `/data/db` |

## Ports

| Port  | Protocol | Description |
|-------|----------|-------------|
| 27017 | TCP      | MongoDB wire protocol |

## VS Code Extensions

- `mongodb.mongodb-vscode` — MongoDB explorer, playground, and query support

## Client Tools (apt)

- `mongosh` — MongoDB Shell for interactive queries and administration
