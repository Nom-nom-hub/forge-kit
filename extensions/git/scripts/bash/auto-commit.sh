#!/usr/bin/env bash
# Git extension: auto-commit.sh
# Config-driven auto-commit for FORGE workflow hooks.

set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <event_name>" >&2
    echo "Example: $0 after_signal" >&2
    exit 1
fi

EVENT_NAME="$1"

# Determine project root
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT=""
dir="$SCRIPT_DIR"
while [ "$dir" != "/" ]; do
    if [ -d "$dir/.forge" ] || [ -d "$dir/.git" ]; then
        PROJECT_ROOT="$dir"
        break
    fi
    dir="$(dirname "$dir")"
done

if [ -z "$PROJECT_ROOT" ]; then
    if git rev-parse --show-toplevel >/dev/null 2>&1; then
        PROJECT_ROOT=$(git rev-parse --show-toplevel)
    else
        exit 0  # No git repo, skip silently
    fi
fi

cd "$PROJECT_ROOT"

# Check if git is available
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    exit 0  # Not a git repo, skip
fi

# Check for config file
CONFIG_FILE="$PROJECT_ROOT/.forge/extensions/git/git-config.yml"
if [ ! -f "$CONFIG_FILE" ]; then
    exit 0  # No config, skip (disabled by default)
fi

# Parse the event's config
# Use grep and sed to extract simple YAML values
DEFAULT_ENABLED=$(grep -A1 '^  default:' "$CONFIG_FILE" | grep -E 'true|false' | head -1 | grep -q 'true' && echo true || echo false)

# Check if this event is explicitly configured
EVENT_BLOCK=$(sed -n "/^  ${EVENT_NAME}:/,/^  [a-z_]*:/p" "$CONFIG_FILE" 2>/dev/null || true)

if echo "$EVENT_BLOCK" | grep -q 'enabled:'; then
    ENABLED=$(echo "$EVENT_BLOCK" | grep 'enabled:' | head -1 | grep -q 'true' && echo true || echo false)
    COMMIT_MSG=$(echo "$EVENT_BLOCK" | grep 'message:' | head -1 | sed 's/.*message: *"\(.*\)"/\1/' 2>/dev/null || echo "")
else
    ENABLED="$DEFAULT_ENABLED"
    COMMIT_MSG=""
fi

if [ "$ENABLED" != "true" ]; then
    exit 0  # Auto-commit disabled for this event
fi

if [ -z "$COMMIT_MSG" ]; then
    # Generate default message
    case "$EVENT_NAME" in
        after_signal)    COMMIT_MSG="[Forge Kit] Capture signal" ;;
        after_hypothesize) COMMIT_MSG="[Forge Kit] Formulate hypothesis" ;;
        after_decide)    COMMIT_MSG="[Forge Kit] Record decision" ;;
        after_feature)   COMMIT_MSG="[Forge Kit] Add feature specification" ;;
        after_experiment) COMMIT_MSG="[Forge Kit] Design experiment" ;;
        after_release)   COMMIT_MSG="[Forge Kit] Create release manifest" ;;
        after_retrospect) COMMIT_MSG="[Forge Kit] Run retrospective" ;;
        after_constitution) COMMIT_MSG="[Forge Kit] Add project constitution" ;;
        before_signal)   COMMIT_MSG="[Forge Kit] Save progress before signal capture" ;;
        before_hypothesize) COMMIT_MSG="[Forge Kit] Save progress before hypothesis" ;;
        before_decide)   COMMIT_MSG="[Forge Kit] Save progress before decision" ;;
        before_feature)  COMMIT_MSG="[Forge Kit] Save progress before feature spec" ;;
        before_experiment) COMMIT_MSG="[Forge Kit] Save progress before experiment" ;;
        before_release)  COMMIT_MSG="[Forge Kit] Save progress before release" ;;
        before_retrospect) COMMIT_MSG="[Forge Kit] Save progress before retrospective" ;;
        after_check)     COMMIT_MSG="[Forge Kit] Quality check results" ;;
        before_check)    COMMIT_MSG="[Forge Kit] Save progress before quality check" ;;
        after_graph)     COMMIT_MSG="[Forge Kit] Graph update" ;;
        before_graph)    COMMIT_MSG="[Forge Kit] Save progress before graph update" ;;
        after_analyze)   COMMIT_MSG="[Forge Kit] Analysis results" ;;
        before_analyze)  COMMIT_MSG="[Forge Kit] Save progress before analysis" ;;
        after_clarify)   COMMIT_MSG="[Forge Kit] Clarification results" ;;
        before_clarify)  COMMIT_MSG="[Forge Kit] Save progress before clarification" ;;
        after_checklist) COMMIT_MSG="[Forge Kit] Checklist results" ;;
        before_checklist) COMMIT_MSG="[Forge Kit] Save progress before checklist" ;;
        after_ai_analyze) COMMIT_MSG="[Forge Kit] AI analysis results" ;;
        before_ai_analyze) COMMIT_MSG="[Forge Kit] Save progress before AI analysis" ;;
        after_ai_critique) COMMIT_MSG="[Forge Kit] AI critique results" ;;
        before_ai_critique) COMMIT_MSG="[Forge Kit] Save progress before AI critique" ;;
        after_ai_blind_spots) COMMIT_MSG="[Forge Kit] Blind spot detection results" ;;
        before_ai_blind_spots) COMMIT_MSG="[Forge Kit] Save progress before blind spot detection" ;;
        *)               COMMIT_MSG="[Forge Kit] Auto-commit" ;;
    esac
fi

# Check if there are changes to commit
if git diff --quiet && git diff --cached --quiet; then
    echo "[forge] Nothing to commit."
    exit 0
fi

git add .
git commit -m "$COMMIT_MSG"
echo "[forge] Auto-committed: $COMMIT_MSG"
