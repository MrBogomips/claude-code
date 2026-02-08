# RabbitMQ

## Docker Compose Service

```yaml
rabbitmq:
  image: rabbitmq:3.13-management
  restart: unless-stopped
  volumes:
    - devcontainer-{{PROJECT_NAME}}-rabbitmq-data:/var/lib/rabbitmq
  environment:
    RABBITMQ_DEFAULT_USER: guest
    RABBITMQ_DEFAULT_PASS: guest
  ports:
    - "5672:5672"
    - "15672:15672"
  healthcheck:
    test: ["CMD", "rabbitmq-diagnostics", "check_running"]
    interval: 10s
    timeout: 5s
    retries: 5
```

## Connection Strings

| Language | Connection String |
|----------|------------------|
| Node.js  | `amqp://guest:guest@rabbitmq:5672` |
| Python   | `amqp://guest:guest@rabbitmq:5672/` |
| .NET     | `amqp://guest:guest@rabbitmq:5672` |
| Go       | `amqp://guest:guest@rabbitmq:5672/` |
| Java     | `amqp://guest:guest@rabbitmq:5672` |

## Default Credentials

- Username: `guest`
- Password: `guest`
- Management UI: `http://localhost:15672`

## Environment Variables

| Variable | Value |
|----------|-------|
| `ConnectionStrings__RabbitMQ` | `amqp://guest:guest@rabbitmq:5672` |

## Named Volumes

| Volume Name | Mount Path |
|-------------|------------|
| `devcontainer-{{PROJECT_NAME}}-rabbitmq-data` | `/var/lib/rabbitmq` |

## Ports

| Port  | Protocol | Description |
|-------|----------|-------------|
| 5672  | TCP      | AMQP protocol (messaging) |
| 15672 | TCP      | Management UI and HTTP API |

## VS Code Extensions

No widely-adopted VS Code extension for RabbitMQ. Use the Management UI at `http://localhost:15672` for monitoring and administration.

## Client Tools (apt)

No dedicated apt package required. Use the Management UI or language-specific client libraries (e.g., `amqplib` for Node.js, `pika` for Python).
