# Azurite (Azure Storage Emulator)

## Docker Compose Service

```yaml
azurite:
  image: mcr.microsoft.com/azure-storage/azurite
  restart: unless-stopped
  volumes:
    - devcontainer-{{PROJECT_NAME}}-azurite-data:/data
  command: "azurite --blobHost 0.0.0.0 --queueHost 0.0.0.0 --tableHost 0.0.0.0 --location /data --debug /data/debug.log"
  ports:
    - "10000:10000"
    - "10001:10001"
    - "10002:10002"
```

## Connection Strings

| Language | Connection String |
|----------|------------------|
| All      | `DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://azurite:10000/devstoreaccount1;QueueEndpoint=http://azurite:10001/devstoreaccount1;TableEndpoint=http://azurite:10002/devstoreaccount1;` |

## Default Credentials

- Account Name: `devstoreaccount1`
- Account Key: `Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==`

These are the well-known Azurite development credentials and are not secret.

## Environment Variables

| Variable | Value |
|----------|-------|
| `AzureStorage__ConnectionString` | `DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://azurite:10000/devstoreaccount1;QueueEndpoint=http://azurite:10001/devstoreaccount1;TableEndpoint=http://azurite:10002/devstoreaccount1;` |

## Named Volumes

| Volume Name | Mount Path |
|-------------|------------|
| `devcontainer-{{PROJECT_NAME}}-azurite-data` | `/data` |

## Ports

| Port  | Protocol | Description |
|-------|----------|-------------|
| 10000 | TCP      | Blob Storage |
| 10001 | TCP      | Queue Storage |
| 10002 | TCP      | Table Storage |

## Health Check

Azurite does not ship a built-in health check command. No `healthcheck` block is included in the Compose service.

## VS Code Extensions

- `Azurite.azurite` — Start/stop Azurite directly from VS Code and browse storage

## Client Tools (apt)

No dedicated apt package. Use language-specific Azure Storage SDKs or install the Azure CLI:

```bash
# Install Azure CLI (if needed for blob/queue/table operations)
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Example: list blob containers
az storage container list --connection-string "$AzureStorage__ConnectionString"
```
