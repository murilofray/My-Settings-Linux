# My Dev Environment

Automated setup for my Linux Mint (Ubuntu 24.04 base) development environment.

## Quick Start

```bash
git clone git@github.com:YOUR_USER/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

---

## Terminal

| Tool | Description |
|---|---|
| **zsh** | Shell |
| **oh-my-zsh** | Plugin/theme framework |
| **powerlevel10k** | Prompt theme |
| **MesloLGS NF** | Nerd Font with icons |
| **Terminator** | Terminal emulator with split panes |

### Zsh Plugins

```
git  zsh-autosuggestions  zsh-syntax-highlighting  z  copypath
jsontools  docker  docker-compose  pip  python  virtualenv
command-not-found  you-should-use
```

### Custom Aliases

| Alias | Command |
|---|---|
| `ezalt` | `eza --git --group-directories-first --tree --level=2` |
| `myhelp` | Shows all shortcuts and commands |

---

## CLI Tools

| Tool | Description | Install |
|---|---|---|
| **eza** | Modern `ls` with icons and git | `apt` |
| **ruff** | Python linter + formatter | `pip` |
| **py-spy** | Python profiler | `pip` |
| **pre-commit** | Pre-commit hooks | `pip` |
| **uv** | Modern Python package manager | `curl` |
| **hadolint** | Dockerfile linter | `binary` |
| **trivy** | Vulnerability scanner | `apt` |
| **claude** | Claude Code CLI | `curl` |
| **flameshot** | Screenshot with annotations | `apt` |
| **albert** | App launcher | `apt (external repo)` |

---

## Docker

| Tool | Description |
|---|---|
| **Docker** | Container runtime |
| **Docker Compose** | Container orchestration (v2 plugin) |
| **lazydocker** | TUI for managing containers |

### Docker Compose - Auxiliary Services

```bash
# With Redis (when project doesn't have its own Redis)
docker compose -f docker/docker-compose.services.yml up -d

# Without Redis (when the project already includes Redis in its app compose)
docker compose -f docker/docker-compose.services-no-redis.yml up -d

# Stop
docker compose -f docker/docker-compose.services.yml down
```

| Service | Port | Usage |
|---|---|---|
| **Redis** | `localhost:6379` | Cache, sessions, queues (only in compose with Redis) |
| **SonarQube** | `localhost:9000` | Code analysis (login: admin/admin) |
| **MLflow** | `localhost:5000` | ML experiment tracking |
| **Prefect** | `localhost:4200` | Pipeline orchestration |

### Docker Compose - App (Backend + Frontend + Redis)

```bash
# Start backend (FastAPI) + frontend (Next.js) + Redis
docker compose -f docker/docker-compose.app.yml up -d --build

# Stop all
docker compose -f docker/docker-compose.app.yml down
```

| Service | Port | Dockerfile |
|---|---|---|
| **Backend** | `localhost:8000` | `docker/backend.Dockerfile` (Python 3.13 + uv) |
| **Frontend** | `localhost:3000` | `docker/frontend.Dockerfile` (Node 24 + Next.js) |
| **Redis** | `localhost:6379` | Official image |

---

## Apps

| App | Description |
|---|---|
| **Cursor** | IDE (VS Code fork with AI) |
| **Bruno** | API client |
| **Zen Browser** | Browser |
| **Chrome** | Browser |
| **DBeaver** | Database client |

### Cursor Extensions

| Extension | Description |
|---|---|
| GitLens | Git blame, history |
| Path Intellisense | Path autocomplete |
| Python (Anysphere) | Type checking |
| Python (ms-python) | Python support |
| Python Debugger | Python debugging |
| Todo Tree | Find TODOs in code |
| YAML (Red Hat) | YAML support |

---

## MCP Servers (Cursor)

Config at `cursor/mcp.json` → copy to `~/.cursor/mcp.json`

| MCP | Description | Requires config? |
|---|---|---|
| **SonarQube** | Code analysis via local SonarQube | SonarQube token |
| **Playwright** | Browser automation / E2E tests | No |
| **Docker** | Manage containers from Cursor | No |
| **PostgreSQL** | Read-only database queries | Connection string |
| **Apidog** | OpenAPI specs in AI context | Token + Project ID |

> **Note:** Context7 is used via Cursor plugin, not via MCP.

---

## Stack

| Area | Technologies |
|---|---|
| **Backend** | Python, FastAPI |
| **Frontend** | React, Next.js |
| **Infra** | Docker, Docker Compose, Azure CLI |
| **CI/CD** | Azure DevOps, GitHub Actions |
| **DB** | PostgreSQL (via DBeaver) |
| **Cache** | Redis |
| **MLOps** | MLflow, Prefect |

---

## Repository Structure

```
dotfiles/
├── install.sh                              # Main setup script
├── README.md
├── zsh/
│   ├── .zshrc                              # Zsh config
│   ├── .p10k.zsh                           # Powerlevel10k config
│   └── help.zsh                            # myhelp function + aliases
├── cursor/
│   ├── mcp.json                            # MCP servers config
│   └── settings.json                       # Cursor config
├── docker/
│   ├── backend.Dockerfile                  # Python 3.13 + uv (FastAPI)
│   ├── frontend.Dockerfile                 # Node 24 + Next.js (multi-stage)
│   ├── docker-compose.services.yml         # Auxiliary services with Redis
│   ├── docker-compose.services-no-redis.yml # Auxiliary services without Redis
│   └── docker-compose.app.yml              # Backend + Frontend + Redis
└── templates/
    ├── .pre-commit-config.yaml             # Pre-commit template for projects
    └── .gitignore                          # Gitignore template
```

---

## Post-install

1. Restart terminal or `source ~/.zshrc`
2. Run `p10k configure` to setup prompt
3. Set terminal font to **MesloLGS NF**
4. Install Cursor manually: https://cursor.com
5. Install Zen Browser manually: https://zen-browser.app
6. Configure SonarQube token at `localhost:9000`
7. Configure Apidog token at `apidog.com`
8. Start Docker services: `docker compose -f docker/docker-compose.services.yml up -d`
