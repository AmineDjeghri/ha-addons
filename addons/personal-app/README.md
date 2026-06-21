<img src="docs/images/logo.svg" width="200" />
<h1>Personal App</h1>


[![python](https://img.shields.io/badge/python-3.12+-blue?logo=python)](https://www.python.org/downloads/release/python-3120/)
[![Debian](https://img.shields.io/badge/Debian-A81D33?logo=debian&logoColor=fff)](https://www.debian.org/)
[![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=F0F0F0)](#)

[![Hugging Face](https://img.shields.io/badge/Hugging%20Face-FFD21E?logo=huggingface&logoColor=000)](#)
[![OpenAI](https://img.shields.io/badge/OpenAI-%23412991?logo=openai&logoColor=white)](https://pytorch.org/get-started/locally/)
[![Microsoft Azure](https://custom-icon-badges.demolab.com/badge/Microsoft%20Azure-0089D6?logo=msazure&logoColor=white)](#)

[![NiceGUI](https://img.shields.io/badge/NiceGUI-526CFE?logo=nicegui&logoColor=fff)](#)
[![FastAPI](https://img.shields.io/badge/FastAPI-009485.svg?logo=fastapi&logoColor=white)](#)

[![Style: Ruff](https://img.shields.io/badge/style-ruff-41B5BE?style=flat)](https://github.com/charliermarsh/ruff)
[![MkDocs](https://img.shields.io/badge/MkDocs-526CFE?logo=materialformkdocs&logoColor=fff)](#)
[![mkdocs-material](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/juftin/mkdocs-material/66d65cf/src/templates/assets/images/badge.json)]()
[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=fff)](#)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=github-actions&logoColor=white)](#)


<img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="400" />
# Home Assistant Addon

## 1. Installation in Home Assistant
1. Add this addon repository to Home Assistant (`https://github.com/aminedjeghri/ha-addons`)
2. Install the "Personal App" addon
3. Configure your settings (see below)
4. Start the addon
5. Open the Web UI from the addon page


## 2. Installation in a local environment
This project is a monorepo containing two main packages:

- `frontend`: A [NiceGUI](https://nicegui.io/) application.
- `backend`: A [FastAPI](https://fastapi.tiangolo.com/) application that serves the AI models and business logic.

The project uses `uv` as a package manager and is configured as a workspace, so dependencies for both packages can be installed with a single command.

### 2.1. Local Prerequisites

- Ubuntu 22.04 or macOS
- UV & python (will be installed by the Makefile)
- Create a ``.env`` file *(take a look at the ``.env.example`` file)*


### 2.2 ⚙️ Steps for Installation
This project uses a `Makefile` to simplify the installation and execution process.

#### Running the Application
Once installed (either locally or via Docker), you can run the services.

- **Run Everything:**
  The `make run-app` command is the easiest way to start all services, including the frontend, backend, database, and Ollama.

- **Run Services Individually:**
  - **Run Backend:** `make run-backend`
  - **Run Frontend:** `make run-frontend`

You can then access:
- Frontend (NiceGUI): [http://localhost:8080](http://localhost:8080) (or the configured port)
- Backend (FastAPI): [http://localhost:8000](http://localhost:8000) (or the configured port). Docs [http://localhost:8000/docs](http://localhost:8000/docs)


## 3. Contributing
Check the [CONTRIBUTING.md](CONTRIBUTING.md) file for more information.
