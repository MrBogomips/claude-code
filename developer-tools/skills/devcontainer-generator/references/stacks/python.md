# Python

## Base Image
mcr.microsoft.com/devcontainers/base:ubuntu-24.04

## Detection
- `requirements.txt` — pip dependencies
- `pyproject.toml` — modern Python project (check `[tool.poetry]` for Poetry, `[project]` for PEP 621)
- `setup.py` — legacy setuptools project
- `Pipfile` — pipenv project
- `setup.cfg` — setuptools declarative config
- `.python-version` — pinned Python version
- `uv.lock` — uv project

## Frameworks

### Flask
- Detection: `flask` in requirements or pyproject dependencies
- CLI: `flask run`
- Dev port: 5000
- Config: `FLASK_APP`, `FLASK_ENV=development`

### Django
- Detection: `manage.py`, `django` in requirements or pyproject dependencies
- CLI: `python manage.py runserver`
- Dev port: 8000
- Config: `DJANGO_SETTINGS_MODULE`

### FastAPI
- Detection: `fastapi` in requirements or pyproject dependencies
- CLI: `uvicorn app:app --reload`
- Dev port: 8000

## Package Managers

| Lock File | Manager | Install Command | Cache Volume |
|-----------|---------|-----------------|--------------|
| `requirements.txt` | pip | `pip install -r requirements.txt` | `devcontainer-{{PROJECT_NAME}}-pip` mounted at `/home/vscode/.cache/pip` |
| `poetry.lock` | poetry | `poetry install --no-interaction` | `devcontainer-{{PROJECT_NAME}}-poetry` mounted at `/home/vscode/.cache/pypoetry` |
| `Pipfile.lock` | pipenv | `pipenv install --deploy` | `devcontainer-{{PROJECT_NAME}}-pipenv` mounted at `/home/vscode/.cache/pipenv` |
| `uv.lock` | uv | `uv sync` | `devcontainer-{{PROJECT_NAME}}-uv` mounted at `/home/vscode/.cache/uv` |

## Dockerfile Layers

When added as a secondary stack in a multi-stack project:

```dockerfile
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && pip3 install --no-cache-dir --upgrade pip
```

## Devcontainer Features

```json
{
  "ghcr.io/devcontainers/features/python:1": {
    "version": "3.12"
  }
}
```

## VS Code Extensions

- `ms-python.python` — Python language support, debugging, IntelliSense
- `ms-python.vscode-pylance` — fast, feature-rich language server

## Port Forwarding

| Port | Label | Condition |
|------|-------|-----------|
| 5000 | Flask | `flask` in dependencies |
| 8000 | Django / FastAPI | `django` or `fastapi` in dependencies |
| 8888 | Jupyter | `jupyter` in dependencies |

## Host Binding

Bind to `0.0.0.0` so the dev server is reachable from the host:

- **Flask**: `flask run --host=0.0.0.0`
- **Django**: `python manage.py runserver 0.0.0.0:8000`
- **FastAPI**: `uvicorn app:app --host 0.0.0.0`

## Environment Variables

```json
{
  "PYTHONUNBUFFERED": "1",
  "PYTHONDONTWRITEBYTECODE": "1"
}
```

## Post-Create Steps

```bash
# Create venv and install dependencies
if [ -f poetry.lock ]; then
  pip install poetry && poetry install --no-interaction
elif [ -f Pipfile.lock ]; then
  pip install pipenv && pipenv install --deploy
elif [ -f uv.lock ]; then
  pip install uv && uv sync
elif [ -f requirements.txt ]; then
  pip install -r requirements.txt
fi
```

## Aliases

```bash
alias venv="python3 -m venv .venv && source .venv/bin/activate"
alias pipi="pip install -r requirements.txt"
```

## Firewall Domains

```
ALLOW pypi.org
ALLOW *.pypi.org
ALLOW files.pythonhosted.org
```

## Credential Files

### ~/.pip/pip.conf

- **Description**: pip configuration with private index URLs and authentication for private PyPI registries
- **Host path**: `~/.pip/pip.conf`
- **Mount target**: `/tmp/.pip-conf-host`
- **Pre-select**: Always pre-selected when Python is selected
- **Extraction type**: YAML — copy entire file (INI-style config, safer to copy whole)
- **initializeCommand**: `mkdir -p "$HOME/.pip" && (test -f "$HOME/.pip/pip.conf" || touch "$HOME/.pip/pip.conf")`
- **Mount**: `source=${localEnv:HOME}/.pip/pip.conf,target=/tmp/.pip-conf-host,type=bind,readonly`
- **Fallback env var**: `PIP_INDEX_URL`

#### Post-Create Extraction

```bash
if [ -s /tmp/.pip-conf-host ]; then
  log "Copying pip config from host ~/.pip/pip.conf..."
  mkdir -p ~/.pip
  cp /tmp/.pip-conf-host ~/.pip/pip.conf
elif [ -n "${PIP_INDEX_URL:-}" ]; then
  log "Using PIP_INDEX_URL environment variable..."
  mkdir -p ~/.pip
  cat > ~/.pip/pip.conf << PIPEOF
[global]
index-url = ${PIP_INDEX_URL}
PIPEOF
else
  log "⚠ No pip credentials found. Set PIP_INDEX_URL or populate ~/.pip/pip.conf on the host."
fi
```

#### DEVCONTAINER.md Block

| Host File | Container Path | Purpose | Fallback Env Var |
|-----------|---------------|---------|-----------------|
| `~/.pip/pip.conf` | `/tmp/.pip-conf-host` | Private PyPI index configuration | `PIP_INDEX_URL` |

### ~/.pypirc

- **Description**: PyPI publishing credentials for uploading packages to private registries
- **Host path**: `~/.pypirc`
- **Mount target**: `/tmp/.pypirc-host`
- **Pre-select**: Not pre-selected (optional — only needed for publishing)
- **Extraction type**: Dotfile — grep repository/username/password sections
- **initializeCommand**: `test -f "$HOME/.pypirc" || touch "$HOME/.pypirc"`
- **Mount**: `source=${localEnv:HOME}/.pypirc,target=/tmp/.pypirc-host,type=bind,readonly`
- **Fallback env var**: `TWINE_PASSWORD`

#### Post-Create Extraction

```bash
if [ -s /tmp/.pypirc-host ]; then
  log "Extracting PyPI publishing credentials from host ~/.pypirc..."
  cp /tmp/.pypirc-host ~/.pypirc
  chmod 600 ~/.pypirc
elif [ -n "${TWINE_PASSWORD:-}" ]; then
  log "Using TWINE_PASSWORD environment variable..."
  cat > ~/.pypirc << PYPIEOF
[pypi]
username = __token__
password = ${TWINE_PASSWORD}
PYPIEOF
  chmod 600 ~/.pypirc
else
  log "⚠ No PyPI publishing credentials found. Set TWINE_PASSWORD or populate ~/.pypirc on the host."
fi
```

#### DEVCONTAINER.md Block

| Host File | Container Path | Purpose | Fallback Env Var |
|-----------|---------------|---------|-----------------|
| `~/.pypirc` | `/tmp/.pypirc-host` | PyPI publishing credentials | `TWINE_PASSWORD` |

