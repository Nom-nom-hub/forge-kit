# Git Branching Workflow Extension (FORGE)

Git repository initialization, feature branch creation, signal-driven numbering (sequential/timestamp), validation, remote detection, and auto-commit hooks for FORGE Kit.

## Overview

This extension provides Git operations as an optional, self-contained module for FORGE workflows. It manages:

- **Repository initialization** with configurable commit messages
- **Feature branch creation** with sequential (`001-signal-name`) or timestamp (`20260601-143022-signal-name`) numbering
- **Branch validation** to ensure branches follow FORGE naming conventions
- **Git remote detection** for repository integration
- **Auto-commit hooks** before/after every FORGE command (configurable per-command with custom messages)

## Commands

| Command | Description |
|---------|-------------|
| `forge.git.initialize` | Initialize a Git repository with a configurable commit message |
| `forge.git.branch` | Create a feature branch with sequential or timestamp numbering |
| `forge.git.validate` | Validate current branch follows FORGE branch naming conventions |
| `forge.git.remote` | Detect Git remote URL for repository integration |
| `forge.git.commit` | Auto-commit changes (configurable per-command enable/disable and messages) |

## Hooks

The extension hooks into every FORGE workflow command. Key hooks include:

| Event | Command | Optional | Description |
|-------|---------|----------|-------------|
| `before_constitution` | `forge.git.initialize` | No | Init git repo before constitution |
| `before_signal` | `forge.git.commit` | Yes | Commit before signal capture |
| `before_feature` | `forge.git.branch` | No | Create feature branch before specification |
| `after_signal` | `forge.git.commit` | Yes | Auto-commit after signal capture |
| `after_feature` | `forge.git.commit` | Yes | Auto-commit after feature specification |
| `after_release` | `forge.git.commit` | Yes | Auto-commit after release manifest |

See `extension.yml` for the complete hook table (27 hooks covering all FORGE commands).

## Configuration

Configuration is stored in `.forge/extensions/git/git-config.yml`:

```yaml
branch_numbering: sequential       # "sequential" or "timestamp"
init_commit_message: "[Forge Kit] Initial commit"

auto_commit:
  default: false                    # Global toggle
  after_signal:
    enabled: true                    # Per-command override
    message: "[Forge Kit] Capture signal"
```

## Installation

```bash
# Install the bundled git extension (no network required)
forge extension add git
```

## Disabling

```bash
# Disable the git extension (signal capture continues without branching)
forge extension disable git

# Re-enable it
forge extension enable git
```

## Graceful Degradation

When Git is not installed or the directory is not a Git repository:
- Signal/hypothesis/decision directories are still created under `.forge/`
- Branch creation is skipped with a warning
- Branch validation is skipped with a warning
- Remote detection returns empty results

## Scripts

The extension bundles cross-platform scripts:

- `scripts/bash/create-signal-branch.sh` — Bash implementation with nanoid generation
- `scripts/bash/auto-commit.sh` — Config-driven auto-commit (Bash)
- `scripts/bash/initialize-repo.sh` — Git init with configurable message (Bash)
- `scripts/powershell/create-signal-branch.ps1` — PowerShell implementation
- `scripts/powershell/auto-commit.ps1` — Config-driven auto-commit (PowerShell)
- `scripts/powershell/initialize-repo.ps1` — Git init with configurable message (PowerShell)
