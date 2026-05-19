---
description: "Validate current branch follows FORGE branch naming conventions"
---

# Validate Feature Branch

Validate that the current Git branch follows the expected FORGE feature branch naming conventions.

## Prerequisites

- Check if Git is available by running `git rev-parse --is-inside-work-tree 2>/dev/null`
- If Git is not available, output a warning and skip validation:
  ```
  [forge] Warning: Git repository not detected; skipped branch validation
  ```

## Validation Rules

Get the current branch name:

```bash
git rev-parse --abbrev-ref HEAD
```

The branch name must match one of these patterns:

1. **Sequential**: `^[0-9]{3,}-` (e.g., `001-signal-name`, `042-fix-auth`, `1000-big-feature`)
2. **Timestamp**: `^[0-9]{8}-[0-9]{6}-` (e.g., `20260601-143022-signal-name`)

## Execution

If on a feature branch (matches either pattern):
- Output: `✓ On feature branch: <branch-name>`
- Check if the corresponding signal/hypothesis directory exists under `.forge/`:
  - For sequential branches, look for `.forge/signals/<prefix>-*` where prefix matches the numeric portion
  - For timestamp branches, look for `.forge/signals/<prefix>-*` where prefix matches the `YYYYMMDD-HHMMSS` portion
- If signal directory exists: `✓ Signal directory found: <path>`
- If signal directory missing: `⚠ No signal directory found for prefix <prefix>`

If NOT on a feature branch:
- Output: `✗ Not on a feature branch. Current branch: <branch-name>`
- Output: `Feature branches should be named like: 001-signal-name or 20260601-143022-signal-name`

## Graceful Degradation

If Git is not installed or the directory is not a Git repository:
- Check the `FORGE_FEATURE` environment variable as a fallback
- If set, validate that value against the naming patterns
- If not set, skip validation with a warning
