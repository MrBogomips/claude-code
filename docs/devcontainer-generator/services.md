---
sidebar_position: 7
sidebar_label: Docker Compose Services
title: Docker Compose Services
---

# Docker Compose Services

When you select infrastructure services during generation, each one is added to `docker-compose.yml` with sensible defaults, a health check, and a named volume.

## PostgreSQL (with PostGIS)

| Property | Value |
|----------|-------|
| Image | `postgis/postgis:16-3.4` |
| Port | 5432 |
| Username | `postgres` |
| Password | `postgres` |
| Database | `{{PROJECT_NAME}}` |
| Volume | `devcontainer-{{PROJECT_NAME}}-postgres-data` |
| Health check | `pg_isready -U postgres` |

**Connection string** (set as an environment variable on the devcontainer service):

```
Host=postgres;Port=5432;Database={{PROJECT_NAME}};Username=postgres;Password=postgres
```

PostGIS is included by default for spatial data support. If you do not need it, replace the image with `postgres:16`.

## MySQL

| Property | Value |
|----------|-------|
| Image | `mysql:8` |
| Port | 3306 |
| Root password | `root` |
| Username | `dev` |
| Password | `dev` |
| Database | `{{PROJECT_NAME}}` |
| Volume | `devcontainer-{{PROJECT_NAME}}-mysql-data` |
| Health check | `mysqladmin ping -h localhost` |

## MongoDB

| Property | Value |
|----------|-------|
| Image | `mongo:7` |
| Port | 27017 |
| Root username | `admin` |
| Root password | `admin` |
| Volume | `devcontainer-{{PROJECT_NAME}}-mongodb-data` |
| Health check | `mongosh --eval "db.adminCommand('ping')"` |

**Connection string:**

```
mongodb://admin:admin@mongodb:27017
```

## Redis

| Property | Value |
|----------|-------|
| Image | `redis:7-alpine` |
| Port | 6379 |
| Volume | `devcontainer-{{PROJECT_NAME}}-redis-data` |
| Health check | `redis-cli ping` |

**Connection string:**

```
redis:6379
```

## RabbitMQ (with Management UI)

| Property | Value |
|----------|-------|
| Image | `rabbitmq:3.13-management` |
| AMQP port | 5672 |
| Management UI port | 15672 |
| Username | `guest` |
| Password | `guest` |
| Volume | `devcontainer-{{PROJECT_NAME}}-rabbitmq-data` |
| Health check | `rabbitmq-diagnostics check_running` |

The management UI is available at `http://localhost:15672` after starting the container.

## Kafka (with Zookeeper)

Kafka requires Zookeeper, so two services are added:

### Zookeeper

| Property | Value |
|----------|-------|
| Image | `confluentinc/cp-zookeeper:7.5.0` |
| Client port | 2181 |
| Volumes | `devcontainer-{{PROJECT_NAME}}-zookeeper-data`, `devcontainer-{{PROJECT_NAME}}-zookeeper-logs` |

### Kafka

| Property | Value |
|----------|-------|
| Image | `confluentinc/cp-kafka:7.5.0` |
| External port | 9092 |
| Internal port | 29092 |
| Volume | `devcontainer-{{PROJECT_NAME}}-kafka-data` |
| Health check | `kafka-broker-api-versions --bootstrap-server localhost:9092` |
| Depends on | Zookeeper |

Kafka advertises two listeners: `PLAINTEXT` on port 29092 (for inter-broker communication) and `PLAINTEXT_HOST` on port 9092 (for host access).

## Azurite (Azure Storage Emulator)

| Property | Value |
|----------|-------|
| Image | `mcr.microsoft.com/azure-storage/azurite` |
| Blob port | 10000 |
| Queue port | 10001 |
| Table port | 10002 |
| Volume | `devcontainer-{{PROJECT_NAME}}-azurite-data` |

**Connection string:**

```
DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://azurite:10000/devstoreaccount1;QueueEndpoint=http://azurite:10001/devstoreaccount1;TableEndpoint=http://azurite:10002/devstoreaccount1
```

This is the well-known Azurite development key, not a secret.

## LocalStack (AWS Emulator)

| Property | Value |
|----------|-------|
| Image | `localstack/localstack:latest` |
| Port | 4566 |
| Default services | S3, SQS, SNS, DynamoDB, Lambda |
| Volume | `devcontainer-{{PROJECT_NAME}}-localstack-data` |

## Named volume convention

All service volumes follow the pattern:

```
devcontainer-{{PROJECT_NAME}}-<service>-data
```

This avoids collisions when running multiple devcontainers on the same Docker host. The `{{PROJECT_NAME}}` is derived from the project directory name in kebab-case.

## Adding a custom service

To add a service not covered by the generator, add it to the `services:` section of `.devcontainer/docker-compose.yml` and declare its volume under `volumes:`. Follow the naming convention above. For example:

```yaml
services:
  # ... existing services ...

  elasticsearch:
    image: elasticsearch:8.12.0
    restart: unless-stopped
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    volumes:
      - devcontainer-my-project-elasticsearch-data:/usr/share/elasticsearch/data
    healthcheck:
      test: ["CMD-SHELL", "curl -sf http://localhost:9200/_cluster/health"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  devcontainer-my-project-elasticsearch-data:
```

If the service needs to be accessible from the devcontainer via hostname, add it to `depends_on` on the `devcontainer` service.

See [Customization](customization.md) for more extension points and [Generated Files](generated-files.md) for the full docker-compose.yml structure.
