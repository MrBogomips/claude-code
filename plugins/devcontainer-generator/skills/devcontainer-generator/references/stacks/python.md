# Python

## Base Image
mcr.microsoft.com/devcontainers/python:3.12

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

When layered on a non-native base image:

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

## Combo Templates

- `python-3-postgres` — Python + PostgreSQL
