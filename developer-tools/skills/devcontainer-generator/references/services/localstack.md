# LocalStack (AWS Cloud Emulator)

## Docker Compose Service

```yaml
localstack:
  image: localstack/localstack:latest
  restart: unless-stopped
  environment:
    - SERVICES=s3,sqs,sns,dynamodb,lambda
    - DEBUG=0
    - DATA_DIR=/var/lib/localstack/data
  ports:
    - "4566:4566"
  volumes:
    - devcontainer-{{PROJECT_NAME}}-localstack-data:/var/lib/localstack
```

## Connection Strings

| Language | Endpoint Configuration |
|----------|----------------------|
| AWS CLI  | `--endpoint-url http://localstack:4566` |
| Node.js  | `{ endpoint: 'http://localstack:4566', region: 'us-east-1' }` |
| Python   | `boto3.client('s3', endpoint_url='http://localstack:4566', region_name='us-east-1')` |
| .NET     | `ServiceURL = "http://localstack:4566"` with `ForcePathStyle = true` |
| Go       | `aws.String("http://localstack:4566")` as endpoint resolver |
| Java     | `.endpointOverride(URI.create("http://localstack:4566"))` |

## Default Credentials

- Access Key ID: `test`
- Secret Access Key: `test`
- Region: `us-east-1`

These are dummy credentials used by LocalStack and are not secret.

## Environment Variables

| Variable | Value |
|----------|-------|
| `AWS_DEFAULT_REGION` | `us-east-1` |
| `AWS_ACCESS_KEY_ID` | `test` |
| `AWS_SECRET_ACCESS_KEY` | `test` |
| `AWS_ENDPOINT_URL` | `http://localstack:4566` |

## Named Volumes

| Volume Name | Mount Path |
|-------------|------------|
| `devcontainer-{{PROJECT_NAME}}-localstack-data` | `/var/lib/localstack` |

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 4566 | TCP      | All AWS services (unified gateway) |

## Health Check

```bash
curl http://localstack:4566/_localstack/health
```

Returns JSON with the status of each enabled service.

## Supported Services

The `SERVICES` environment variable controls which AWS services are started. Default configuration enables:

- **S3** — Object storage
- **SQS** — Message queuing
- **SNS** — Pub/sub notifications
- **DynamoDB** — NoSQL database
- **Lambda** — Serverless functions

Add more services by appending to the comma-separated list (e.g., `SERVICES=s3,sqs,sns,dynamodb,lambda,ses,secretsmanager`).

## VS Code Extensions

No widely-adopted VS Code extension for LocalStack. Use the AWS CLI or the LocalStack web UI (available in LocalStack Pro).

## Client Tools (apt)

- `awscli` — AWS CLI for interacting with all LocalStack services

```bash
# Example: create an S3 bucket
aws --endpoint-url http://localhost:4566 s3 mb s3://my-bucket

# Example: list SQS queues
aws --endpoint-url http://localhost:4566 sqs list-queues

# Example: create a DynamoDB table
aws --endpoint-url http://localhost:4566 dynamodb create-table \
  --table-name my-table \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```
