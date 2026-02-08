---
sidebar_position: 4
title: Infrastructure Services
---

# Infrastructure Services

Reference for the 8 supported infrastructure services. Each service is added as a Docker Compose sidecar with health checks, named volumes, connection strings for all 6 language stacks, and client tools.

---

## PostgreSQL (with PostGIS)

| Property | Value |
|----------|-------|
| **Image** | `postgis/postgis:16-3.4` |
| **Port** | 5432 |
| **Username** | `postgres` |
| **Password** | `postgres` |
| **Database** | `{{PROJECT_NAME}}` |
| **Volume** | `devcontainer-{{PROJECT_NAME}}-postgres-data` → `/var/lib/postgresql/data` |
| **Health check** | `pg_isready -U postgres` |
| **VS Code extension** | `ckolkman.vscode-postgres` |
| **Client tools (apt)** | `postgresql-client` — provides `psql`, `pg_dump`, `pg_restore` |

### Connection Strings

| Language | Connection String |
|----------|------------------|
| Node.js | `postgresql://postgres:postgres@postgres:5432/{{PROJECT_NAME}}` |
| Python | `postgresql://postgres:postgres@postgres:5432/{{PROJECT_NAME}}` |
| .NET | `Host=postgres;Port=5432;Database={{PROJECT_NAME}};Username=postgres;Password=postgres` |
| Go | `postgres://postgres:postgres@postgres:5432/{{PROJECT_NAME}}?sslmode=disable` |
| Java | `jdbc:postgresql://postgres:5432/{{PROJECT_NAME}}` |

---

## MySQL

| Property | Value |
|----------|-------|
| **Image** | `mysql:8` |
| **Port** | 3306 |
| **Root credentials** | `root` / `root` |
| **App credentials** | `dev` / `dev` |
| **Database** | `{{PROJECT_NAME}}` |
| **Volume** | `devcontainer-{{PROJECT_NAME}}-mysql-data` → `/var/lib/mysql` |
| **Health check** | `mysqladmin ping -h localhost` |
| **VS Code extension** | `cweijan.vscode-mysql-client2` |
| **Client tools (apt)** | `mysql-client` — provides `mysql`, `mysqldump` |

### Connection Strings

| Language | Connection String |
|----------|------------------|
| Node.js | `mysql://dev:dev@mysql:3306/{{PROJECT_NAME}}` |
| Python | `mysql+pymysql://dev:dev@mysql:3306/{{PROJECT_NAME}}` |
| .NET | `Server=mysql;Port=3306;Database={{PROJECT_NAME}};User=dev;Password=dev` |
| Go | `dev:dev@tcp(mysql:3306)/{{PROJECT_NAME}}` |
| Java | `jdbc:mysql://mysql:3306/{{PROJECT_NAME}}` |

---

## MongoDB

| Property | Value |
|----------|-------|
| **Image** | `mongo:7` |
| **Port** | 27017 |
| **Username** | `admin` |
| **Password** | `admin` |
| **Auth source** | `admin` |
| **Database** | `{{PROJECT_NAME}}` |
| **Volume** | `devcontainer-{{PROJECT_NAME}}-mongodb-data` → `/data/db` |
| **Health check** | `mongosh --eval "db.adminCommand('ping')"` |
| **VS Code extension** | `mongodb.mongodb-vscode` |
| **Client tools (apt)** | `mongosh` — MongoDB Shell |

### Connection Strings

| Language | Connection String |
|----------|------------------|
| All | `mongodb://admin:admin@mongodb:27017/{{PROJECT_NAME}}?authSource=admin` |

---

## Redis

| Property | Value |
|----------|-------|
| **Image** | `redis:7-alpine` |
| **Port** | 6379 |
| **Authentication** | None (no password by default) |
| **Default database** | `0` |
| **Volume** | `devcontainer-{{PROJECT_NAME}}-redis-data` → `/data` |
| **Health check** | `redis-cli ping` |
| **VS Code extension** | `cweijan.vscode-redis-client` |
| **Client tools (apt)** | `redis-tools` — provides `redis-cli` |

### Connection Strings

| Language | Connection String |
|----------|------------------|
| Node.js | `redis://redis:6379` |
| Python | `redis://redis:6379/0` |
| .NET | `redis:6379` |
| Go | `redis://redis:6379/0` |
| Java | `redis://redis:6379` |

---

## RabbitMQ

| Property | Value |
|----------|-------|
| **Image** | `rabbitmq:3.13-management` |
| **Ports** | 5672 (AMQP), 15672 (Management UI) |
| **Username** | `guest` |
| **Password** | `guest` |
| **Management UI** | `http://localhost:15672` |
| **Volume** | `devcontainer-{{PROJECT_NAME}}-rabbitmq-data` → `/var/lib/rabbitmq` |
| **Health check** | `rabbitmq-diagnostics check_running` |
| **VS Code extension** | None — use the Management UI |
| **Client tools** | None — use language-specific libraries (`amqplib`, `pika`, etc.) |

### Connection Strings

| Language | Connection String |
|----------|------------------|
| Node.js | `amqp://guest:guest@rabbitmq:5672` |
| Python | `amqp://guest:guest@rabbitmq:5672/` |
| .NET | `amqp://guest:guest@rabbitmq:5672` |
| Go | `amqp://guest:guest@rabbitmq:5672/` |
| Java | `amqp://guest:guest@rabbitmq:5672` |

---

## Kafka (with Zookeeper)

Kafka is deployed as a two-container setup: Zookeeper + Kafka broker.

| Property | Value |
|----------|-------|
| **Kafka image** | `confluentinc/cp-kafka:7.5.0` |
| **Zookeeper image** | `confluentinc/cp-zookeeper:7.5.0` |
| **Ports** | 9092 (host access), 29092 (inter-container), 2181 (Zookeeper) |
| **Authentication** | None |
| **Kafka health check** | `kafka-broker-api-versions --bootstrap-server localhost:9092` |
| **VS Code extension** | None — use CLI tools inside the Kafka container |

### Volumes

| Volume | Mount Path |
|--------|-----------|
| `devcontainer-{{PROJECT_NAME}}-zookeeper-data` | `/var/lib/zookeeper/data` |
| `devcontainer-{{PROJECT_NAME}}-zookeeper-logs` | `/var/lib/zookeeper/log` |
| `devcontainer-{{PROJECT_NAME}}-kafka-data` | `/var/lib/kafka/data` |

### Connection Strings

| Context | Bootstrap Servers |
|---------|-------------------|
| From container | `kafka:29092` |
| From host | `localhost:9092` |

### CLI Operations

```bash
# Create a topic
docker exec -it kafka kafka-topics \
  --create --topic my-topic \
  --bootstrap-server localhost:9092 \
  --partitions 1 --replication-factor 1

# Produce messages
docker exec -it kafka kafka-console-producer \
  --topic my-topic --bootstrap-server localhost:9092

# Consume messages
docker exec -it kafka kafka-console-consumer \
  --topic my-topic --bootstrap-server localhost:9092 --from-beginning
```

---

## Azurite (Azure Storage Emulator)

| Property | Value |
|----------|-------|
| **Image** | `mcr.microsoft.com/azure-storage/azurite` |
| **Ports** | 10000 (Blob), 10001 (Queue), 10002 (Table) |
| **Account name** | `devstoreaccount1` |
| **Account key** | `Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==` |
| **Volume** | `devcontainer-{{PROJECT_NAME}}-azurite-data` → `/data` |
| **Health check** | None (Azurite has no built-in health check) |
| **VS Code extension** | `Azurite.azurite` |

These are the well-known Azurite development credentials — they are not secret.

### Connection String (all languages)

```
DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://azurite:10000/devstoreaccount1;QueueEndpoint=http://azurite:10001/devstoreaccount1;TableEndpoint=http://azurite:10002/devstoreaccount1;
```

---

## LocalStack (AWS Cloud Emulator)

| Property | Value |
|----------|-------|
| **Image** | `localstack/localstack:latest` |
| **Port** | 4566 (unified gateway for all AWS services) |
| **Access Key ID** | `test` |
| **Secret Access Key** | `test` |
| **Region** | `us-east-1` |
| **Volume** | `devcontainer-{{PROJECT_NAME}}-localstack-data` → `/var/lib/localstack` |
| **Client tools (apt)** | `awscli` — AWS CLI |

These are dummy credentials used by LocalStack — they are not secret.

### Default Services

The `SERVICES` environment variable controls which AWS services are started. Default: `s3,sqs,sns,dynamodb,lambda`

Add more by appending to the comma-separated list (e.g., `SERVICES=s3,sqs,sns,dynamodb,lambda,ses,secretsmanager`).

### Endpoint Configuration

| Language | Configuration |
|----------|--------------|
| AWS CLI | `--endpoint-url http://localstack:4566` |
| Node.js | `{ endpoint: 'http://localstack:4566', region: 'us-east-1' }` |
| Python | `boto3.client('s3', endpoint_url='http://localstack:4566', region_name='us-east-1')` |
| .NET | `ServiceURL = "http://localstack:4566"` with `ForcePathStyle = true` |
| Go | `aws.String("http://localstack:4566")` as endpoint resolver |
| Java | `.endpointOverride(URI.create("http://localstack:4566"))` |

### Health Check

```bash
curl http://localstack:4566/_localstack/health
```

### CLI Examples

```bash
# Create S3 bucket
aws --endpoint-url http://localhost:4566 s3 mb s3://my-bucket

# List SQS queues
aws --endpoint-url http://localhost:4566 sqs list-queues

# Create DynamoDB table
aws --endpoint-url http://localhost:4566 dynamodb create-table \
  --table-name my-table \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```
