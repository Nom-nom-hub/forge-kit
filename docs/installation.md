# Installation Guide

## Prerequisites

- **Python 3.11+**
- **uv** (recommended) or pipx
- **Git**

## Install Forge CLI

### Using uv (recommended)

```bash
uv tool install forge-cli --from git+https://github.com/teck/forge-kit.git
```

### Using pipx

```bash
pipx install forge-cli --from git+https://github.com/teck/forge-kit.git
```

### From source

```bash
git clone https://github.com/teck/forge-kit.git
cd forge-kit
uv sync
uv run forge --help
```

## Verify Installation

```bash
forge version
```

## Initialize a Project

```bash
forge init my-project --integration copilot
cd my-project
```
