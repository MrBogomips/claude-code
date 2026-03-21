# Infrastructure Services

The Devcontainer Generator can add infrastructure services to your development environment. Each service runs as a separate container alongside your application, orchestrated through Docker Compose.

## Supported services

| Service | Image | Port(s) | Default credentials | Health check |
|---------|-------|---------|-------------------|-------------|
| PostgreSQL (with PostGIS) | `postgis/postgis:16-3.4` | 5432 | `postgres` / `postgres` | `pg_isready -U postgres` |
| MySQL 8 | `mysql:8` | 3306 | root: `root` / `root`, app: `dev` / `dev` | `mysqladmin ping -h localhost` |
| MongoDB 7 | `mongo:7` | 27017 | `admin` / `admin` | `mongosh --eval "db.adminCommand('ping')"` |
| Redis 7 | `redis:7-alpine` | 6379 | No authentication | `redis-cli ping` |
| RabbitMQ | `rabbitmq:3.13-management` | 5672, 15672 | `guest` / `guest` | `rabbitmq-diagnostics check_running` |
| Kafka (with Zookeeper) | `confluentinc/cp-kafka:7.5.0` | 9092, 29092, 2181 | No authentication | `kafka-broker-api-versions` |
| Azurite | `mcr.microsoft.com/azure-storage/azurite` | 10000, 10001, 10002 | Well-known dev credentials | None (no built-in check) |
| LocalStack | `localstack/localstack:latest` | 4566 | `test` / `test` | `curl http://localstack:4566/_localstack/health` |

## How services are added

When you select services during the guided workflow, the generator:

1. Adds a service block to `docker-compose.yml` with the correct image, ports, volumes, environment variables, and health checks
2. Adds `depends_on` entries so your application container waits for services to be healthy
3. Adds connection string environment variables to the application container
4. Installs client tools (e.g., `postgresql-client`, `redis-tools`) in the Dockerfile
5. Adds relevant VS Code extensions for database browsing

## Connection strings

Connection strings are set as environment variables in `docker-compose.yml` and documented in the generated `DEVCONTAINER.md`. The format varies by language -- for example, PostgreSQL uses:

- **Node.js / Python**: `postgresql://postgres:postgres@postgres:5432/project-name`
- **.NET**: `Host=postgres;Port=5432;Database=project-name;Username=postgres;Password=postgres`
- **Go**: `postgres://postgres:postgres@postgres:5432/project-name?sslmode=disable`
- **Java**: `jdbc:postgresql://postgres:5432/project-name`

See the generated `DEVCONTAINER.md` file for the exact connection strings for your selected stack and services.
