# Apache Kafka

## Docker Compose Service

```yaml
zookeeper:
  image: confluentinc/cp-zookeeper:7.5.0
  restart: unless-stopped
  environment:
    ZOOKEEPER_CLIENT_PORT: 2181
    ZOOKEEPER_TICK_TIME: 2000
  volumes:
    - devcontainer-{{PROJECT_NAME}}-zookeeper-data:/var/lib/zookeeper/data
    - devcontainer-{{PROJECT_NAME}}-zookeeper-logs:/var/lib/zookeeper/log

kafka:
  image: confluentinc/cp-kafka:7.5.0
  restart: unless-stopped
  depends_on:
    - zookeeper
  ports:
    - "9092:9092"
  environment:
    KAFKA_BROKER_ID: 1
    KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
    KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:29092,PLAINTEXT_HOST://localhost:9092
    KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
    KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
    KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
  volumes:
    - devcontainer-{{PROJECT_NAME}}-kafka-data:/var/lib/kafka/data
  healthcheck:
    test: ["CMD", "kafka-broker-api-versions", "--bootstrap-server", "localhost:9092"]
    interval: 10s
    timeout: 5s
    retries: 5
```

## Connection Strings

| Language | Bootstrap Servers |
|----------|-------------------|
| Node.js  | `kafka:29092` (from container) / `localhost:9092` (from host) |
| Python   | `kafka:29092` (from container) / `localhost:9092` (from host) |
| .NET     | `kafka:29092` (from container) / `localhost:9092` (from host) |
| Go       | `kafka:29092` (from container) / `localhost:9092` (from host) |
| Java     | `kafka:29092` (from container) / `localhost:9092` (from host) |

## Default Credentials

- No authentication by default
- Zookeeper connection: `zookeeper:2181`

## Environment Variables

| Variable | Value |
|----------|-------|
| `Kafka__BootstrapServers` | `kafka:29092` |

## Named Volumes

| Volume Name | Mount Path |
|-------------|------------|
| `devcontainer-{{PROJECT_NAME}}-zookeeper-data` | `/var/lib/zookeeper/data` |
| `devcontainer-{{PROJECT_NAME}}-zookeeper-logs` | `/var/lib/zookeeper/log` |
| `devcontainer-{{PROJECT_NAME}}-kafka-data` | `/var/lib/kafka/data` |

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 9092 | TCP      | Kafka broker (host access) |
| 29092| TCP      | Kafka broker (inter-container) |
| 2181 | TCP      | Zookeeper client port |

## VS Code Extensions

No widely-adopted VS Code extension for Kafka. Use CLI tools or the Confluent Control Center for monitoring.

## Client Tools (apt)

No dedicated apt package. The Kafka CLI tools are available inside the `kafka` container:

```bash
# Create a topic
docker exec -it kafka kafka-topics --create --topic my-topic --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1

# Produce messages
docker exec -it kafka kafka-console-producer --topic my-topic --bootstrap-server localhost:9092

# Consume messages
docker exec -it kafka kafka-console-consumer --topic my-topic --bootstrap-server localhost:9092 --from-beginning
```
