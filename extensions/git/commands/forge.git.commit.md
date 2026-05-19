---
description: "Auto-commit changes after a FORGE command completes"
---

# Auto-Commit Changes

Automatically stage and commit all changes after a FORGE command completes.

## Behavior

This command is invoked as a hook after (or before) core commands. It:

1. Determines the event name from the hook context (e.g., if invoked as an `after_signal` hook, the event is `after_signal`; if `before_hypothesize`, the event is `before_hypothesize`)
2. Checks `.forge/extensions/git/git-config.yml` for the `auto_commit` section
3. Looks up the specific event key to see if auto-commit is enabled
4. Falls back to `auto_commit.default` if no event-specific key exists
5. Uses the per-command `message` if configured, otherwise a default message
6. If enabled and there are uncommitted changes, runs `git add .` + `git commit`

## Execution

Determine the event name from the hook that triggered this command, then run the script:

- **Bash**: `.forge/extensions/git/scripts/bash/auto-commit.sh <event_name>`
- **PowerShell**: `.forge/extensions/git/scripts/powershell/auto-commit.ps1 <event_name>`

Replace `<event_name>` with the actual hook event (e.g., `after_signal`, `before_hypothesize`, `after_release`).

## Configuration

In `.forge/extensions/git/git-config.yml`:

```yaml
auto_commit:
  default: false           # Global toggle — set true to enable for all commands
  after_signal:
    enabled: true           # Override per-command
    message: "[Forge Kit] Capture signal"
  after_hypothesize:
    enabled: false
    message: "[Forge Kit] Formulate hypothesis"
```

## Graceful Degradation

- If Git is not available or the current directory is not a repository: skips with a warning
- If no config file exists: skips (disabled by default)
- If no changes to commit: skips with a message
