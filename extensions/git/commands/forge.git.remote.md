---
description: "Detect Git remote URL for repository integration"
---

# Detect Git Remote URL

Detect the Git remote URL for integration with repository hosting services.

## Prerequisites

- Check if Git is available by running `git rev-parse --is-inside-work-tree 2>/dev/null`
- If Git is not available, output a warning and return empty:
  ```
  [forge] Warning: Git repository not detected; cannot determine remote URL
  ```

## Execution

Run the following command to get the remote URL:

```bash
git config --get remote.origin.url
```

## Output

Parse the remote URL and determine:

1. **Repository owner**: Extract from the URL (e.g., `forge-kit` from `https://github.com/forge-kit/forge-kit.git`)
2. **Repository name**: Extract from the URL (e.g., `forge-kit` from `https://github.com/forge-kit/forge-kit.git`)
3. **Host**: The git hosting provider (github.com, gitlab.com, bitbucket.org, etc.)

Supported URL formats:
- HTTPS: `https://<host>/<owner>/<repo>.git`
- SSH: `git@<host>:<owner>/<repo>.git`

## Graceful Degradation

If Git is not installed, the directory is not a Git repository, or no remote is configured:
- Return an empty result
- Do NOT error — other workflows should continue without Git remote information
