#!/usr/bin/env bash
# Git extension: initialize-repo.sh
# Initialize a Git repository with an initial commit for FORGE workflow.

set -e

# Check if git is available
if ! command -v git >/dev/null 2>&1; then
    echo "[forge] Warning: Git is not installed. Skipping repository initialization." >&2
    exit 0
fi

# Skip if already inside a Git repository
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "[forge] Git repository already initialized."
    exit 0
fi

# Determine project root as the current directory
PROJECT_ROOT=$(pwd)

# Check for custom config
CONFIG_FILE="$PROJECT_ROOT/.forge/extensions/git/git-config.yml"
INIT_MESSAGE="[Forge Kit] Initial commit"
if [ -f "$CONFIG_FILE" ]; then
    CUSTOM_MSG=$(grep 'init_commit_message:' "$CONFIG_FILE" | sed 's/.*init_commit_message: *"\(.*\)"/\1/' 2>/dev/null || echo "")
    if [ -n "$CUSTOM_MSG" ]; then
        INIT_MESSAGE="$CUSTOM_MSG"
    fi
fi

git init
git add .
git commit -m "$INIT_MESSAGE"
echo "✓ Git repository initialized"
