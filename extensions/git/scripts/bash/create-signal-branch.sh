#!/usr/bin/env bash
# Git extension: create-signal-branch.sh
# Creates FORGE feature branches with sequential or timestamp numbering.
# Adapted from spec-kit's create-new-feature.sh for FORGE signal-driven workflow.

set -e

JSON_MODE=false
DRY_RUN=false
ALLOW_EXISTING=false
SHORT_NAME=""
BRANCH_NUMBER=""
USE_TIMESTAMP=false
ARGS=()

i=1
while [ $i -le $# ]; do
    arg="${!i}"
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        --allow-existing-branch)
            ALLOW_EXISTING=true
            ;;
        --short-name)
            if [ $((i + 1)) -gt $# ]; then
                echo 'Error: --short-name requires a value' >&2
                exit 1
            fi
            i=$((i + 1))
            next_arg="${!i}"
            if [[ "$next_arg" == --* ]]; then
                echo 'Error: --short-name requires a value' >&2
                exit 1
            fi
            SHORT_NAME="$next_arg"
            ;;
        --number)
            if [ $((i + 1)) -gt $# ]; then
                echo 'Error: --number requires a value' >&2
                exit 1
            fi
            i=$((i + 1))
            next_arg="${!i}"
            if [[ "$next_arg" == --* ]]; then
                echo 'Error: --number requires a value' >&2
                exit 1
            fi
            BRANCH_NUMBER="$next_arg"
            if [[ ! "$BRANCH_NUMBER" =~ ^[0-9]+$ ]]; then
                echo 'Error: --number must be a non-negative integer' >&2
                exit 1
            fi
            ;;
        --timestamp)
            USE_TIMESTAMP=true
            ;;
        --help|-h)
            echo "Usage: $0 [--json] [--dry-run] [--allow-existing-branch] [--short-name <name>] [--number N] [--timestamp] <description>"
            echo ""
            echo "Options:"
            echo "  --json              Output in JSON format"
            echo "  --dry-run           Compute branch name without creating the branch"
            echo "  --allow-existing-branch  Switch to branch if it already exists instead of failing"
            echo "  --short-name <name> Provide a custom short name (2-4 words) for the branch"
            echo "  --number N          Specify branch number manually (overrides auto-detection)"
            echo "  --timestamp         Use timestamp prefix (YYYYMMDD-HHMMSS) instead of sequential"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "Environment variables:"
            echo "  GIT_BRANCH_NAME     Use this exact branch name, bypassing all prefix/suffix generation"
            exit 0
            ;;
        *)
            ARGS+=("$arg")
            ;;
    esac
    i=$((i + 1))
done

FEATURE_DESCRIPTION="${ARGS[*]}"
if [ -z "$FEATURE_DESCRIPTION" ]; then
    echo "Usage: $0 [--json] [--dry-run] [--allow-existing-branch] [--short-name <name>] [--number N] [--timestamp] <description>" >&2
    exit 1
fi

FEATURE_DESCRIPTION=$(echo "$FEATURE_DESCRIPTION" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')
if [ -z "$FEATURE_DESCRIPTION" ]; then
    echo "Error: Feature description cannot be empty or contain only whitespace" >&2
    exit 1
fi

# --- Utility functions ---

_extract_highest_number() {
    local highest=0
    while IFS= read -r name; do
        [ -z "$name" ] && continue
        if echo "$name" | grep -Eq '^[0-9]{3,}-' && ! echo "$name" | grep -Eq '^[0-9]{8}-[0-9]{6}-'; then
            number=$(echo "$name" | grep -Eo '^[0-9]+' || echo "0")
            number=$((10#$number))
            if [ "$number" -gt "$highest" ]; then
                highest=$number
            fi
        fi
    done
    echo "$highest"
}

get_highest_from_signals() {
    local signals_dir="$1"
    local highest=0

    if [ -d "$signals_dir" ]; then
        for dir in "$signals_dir"/*; do
            [ -d "$dir" ] || continue
            dirname=$(basename "$dir")
            if echo "$dirname" | grep -Eq '^[0-9]{3,}-' && ! echo "$dirname" | grep -Eq '^[0-9]{8}-[0-9]{6}-'; then
                number=$(echo "$dirname" | grep -Eo '^[0-9]+')
                number=$((10#$number))
                if [ "$number" -gt "$highest" ]; then
                    highest=$number
                fi
            fi
        done
    fi
    echo "$highest"
}

get_highest_from_branches() {
    git branch -a 2>/dev/null | sed 's/^[* ]*//; s|^remotes/[^/]*/||' | _extract_highest_number
}

get_highest_from_remote_refs() {
    local highest=0
    for remote in $(git remote 2>/dev/null); do
        local remote_highest
        remote_highest=$(GIT_TERMINAL_PROMPT=0 git ls-remote --heads "$remote" 2>/dev/null | sed 's|.*refs/heads/||' | _extract_highest_number)
        if [ "$remote_highest" -gt "$highest" ]; then
            highest=$remote_highest
        fi
    done
    echo "$highest"
}

check_existing_branches() {
    local signals_dir="$1"
    local skip_fetch="${2:-false}"

    if [ "$skip_fetch" = true ]; then
        local highest_remote=$(get_highest_from_remote_refs)
        local highest_branch=$(get_highest_from_branches)
        if [ "$highest_remote" -gt "$highest_branch" ]; then
            highest_branch=$highest_remote
        fi
    else
        git fetch --all --prune >/dev/null 2>&1 || true
        local highest_branch=$(get_highest_from_branches)
    fi

    local highest_signal=$(get_highest_from_signals "$signals_dir")

    local max_num=$highest_branch
    if [ "$highest_signal" -gt "$max_num" ]; then
        max_num=$highest_signal
    fi
    echo $((max_num + 1))
}

clean_branch_name() {
    local name="$1"
    echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//'
}

# --- Determine project root ---

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
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
        echo "Error: Could not determine project root." >&2
        exit 1
    fi
fi

cd "$PROJECT_ROOT"

SIGNALS_DIR="$PROJECT_ROOT/.forge/signals"

# Determine if git is available
HAS_GIT=false
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    HAS_GIT=true
fi

# --- Branch name generation ---

generate_branch_name() {
    local description="$1"
    local stop_words="^(i|a|an|the|to|for|of|in|on|at|by|with|from|is|are|was|were|be|been|being|have|has|had|do|does|did|will|would|should|could|can|may|might|must|shall|this|that|these|those|my|your|our|their|want|need|add|get|set)$"
    local clean_name=$(echo "$description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/ /g')
    local meaningful_words=()

    for word in $clean_name; do
        [ -z "$word" ] && continue
        if ! echo "$word" | grep -qiE "$stop_words"; then
            if [ ${#word} -ge 3 ]; then
                meaningful_words+=("$word")
            elif echo "$description" | grep -qw -- "${word^^}"; then
                meaningful_words+=("$word")
            fi
        fi
    done

    if [ ${#meaningful_words[@]} -gt 0 ]; then
        local max_words=3
        if [ ${#meaningful_words[@]} -eq 4 ]; then max_words=4; fi
        local result=""
        local count=0
        for word in "${meaningful_words[@]}"; do
            if [ $count -ge $max_words ]; then break; fi
            if [ -n "$result" ]; then result="$result-"; fi
            result="$result$word"
            count=$((count + 1))
        done
        echo "$result"
    else
        local cleaned=$(clean_branch_name "$description")
        echo "$cleaned" | tr '-' '\n' | grep -v '^$' | head -3 | tr '\n' '-' | sed 's/-$//'
    fi
}

# Check for GIT_BRANCH_NAME env var override
if [ -n "${GIT_BRANCH_NAME:-}" ]; then
    BRANCH_NAME="$GIT_BRANCH_NAME"
    if echo "$BRANCH_NAME" | grep -Eq '^[0-9]{8}-[0-9]{6}-'; then
        FEATURE_NUM=$(echo "$BRANCH_NAME" | grep -Eo '^[0-9]{8}-[0-9]{6}')
        BRANCH_SUFFIX="${BRANCH_NAME#${FEATURE_NUM}-}"
    elif echo "$BRANCH_NAME" | grep -Eq '^[0-9]+-'; then
        FEATURE_NUM=$(echo "$BRANCH_NAME" | grep -Eo '^[0-9]+')
        BRANCH_SUFFIX="${BRANCH_NAME#${FEATURE_NUM}-}"
    else
        FEATURE_NUM="$BRANCH_NAME"
        BRANCH_SUFFIX="$BRANCH_NAME"
    fi
else
    if [ -n "$SHORT_NAME" ]; then
        BRANCH_SUFFIX=$(clean_branch_name "$SHORT_NAME")
    else
        BRANCH_SUFFIX=$(generate_branch_name "$FEATURE_DESCRIPTION")
    fi

    if [ "$USE_TIMESTAMP" = true ] && [ -n "$BRANCH_NUMBER" ]; then
        >&2 echo "[forge] Warning: --number is ignored when --timestamp is used"
        BRANCH_NUMBER=""
    fi

    if [ "$USE_TIMESTAMP" = true ]; then
        FEATURE_NUM=$(date +%Y%m%d-%H%M%S)
        BRANCH_NAME="${FEATURE_NUM}-${BRANCH_SUFFIX}"
    else
        if [ -z "$BRANCH_NUMBER" ]; then
            if [ "$DRY_RUN" = true ] && [ "$HAS_GIT" = true ]; then
                BRANCH_NUMBER=$(check_existing_branches "$SIGNALS_DIR" true)
            elif [ "$DRY_RUN" = true ]; then
                HIGHEST=$(get_highest_from_signals "$SIGNALS_DIR")
                BRANCH_NUMBER=$((HIGHEST + 1))
            elif [ "$HAS_GIT" = true ]; then
                BRANCH_NUMBER=$(check_existing_branches "$SIGNALS_DIR")
            else
                HIGHEST=$(get_highest_from_signals "$SIGNALS_DIR")
                BRANCH_NUMBER=$((HIGHEST + 1))
            fi
        fi

        FEATURE_NUM=$(printf "%03d" "$((10#$BRANCH_NUMBER))")
        BRANCH_NAME="${FEATURE_NUM}-${BRANCH_SUFFIX}"
    fi
fi

# GitHub enforces a 244-byte limit on branch names
MAX_BRANCH_LENGTH=244
_byte_length() { printf '%s' "$1" | LC_ALL=C wc -c | tr -d ' '; }
BRANCH_BYTE_LEN=$(_byte_length "$BRANCH_NAME")
if [ -n "${GIT_BRANCH_NAME:-}" ] && [ "$BRANCH_BYTE_LEN" -gt $MAX_BRANCH_LENGTH ]; then
    >&2 echo "Error: GIT_BRANCH_NAME must be 244 bytes or fewer. Provided value is ${BRANCH_BYTE_LEN} bytes."
    exit 1
elif [ "$BRANCH_BYTE_LEN" -gt $MAX_BRANCH_LENGTH ]; then
    PREFIX_LENGTH=$(( ${#FEATURE_NUM} + 1 ))
    MAX_SUFFIX_LENGTH=$((MAX_BRANCH_LENGTH - PREFIX_LENGTH))
    TRUNCATED_SUFFIX=$(echo "$BRANCH_SUFFIX" | cut -c1-$MAX_SUFFIX_LENGTH)
    TRUNCATED_SUFFIX=$(echo "$TRUNCATED_SUFFIX" | sed 's/-$//')
    ORIGINAL_BRANCH_NAME="$BRANCH_NAME"
    BRANCH_NAME="${FEATURE_NUM}-${TRUNCATED_SUFFIX}"
    >&2 echo "[forge] Warning: Branch name exceeded GitHub's 244-byte limit"
    >&2 echo "[forge] Original: $ORIGINAL_BRANCH_NAME (${#ORIGINAL_BRANCH_NAME} bytes)"
    >&2 echo "[forge] Truncated to: $BRANCH_NAME (${#BRANCH_NAME} bytes)"
fi

if [ "$DRY_RUN" != true ]; then
    if [ "$HAS_GIT" = true ]; then
        branch_create_error=""
        if ! branch_create_error=$(git checkout -q -b "$BRANCH_NAME" 2>&1); then
            if git branch --list "$BRANCH_NAME" | grep -q .; then
                if [ "$ALLOW_EXISTING" = true ]; then
                    current_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
                    if [ "$current_branch" != "$BRANCH_NAME" ]; then
                        if ! git checkout -q "$BRANCH_NAME" 2>&1; then
                            >&2 echo "Error: Failed to switch to existing branch '$BRANCH_NAME'."
                            exit 1
                        fi
                    fi
                elif [ "$USE_TIMESTAMP" = true ]; then
                    >&2 echo "Error: Branch '$BRANCH_NAME' already exists. Rerun to get a new timestamp."
                    exit 1
                else
                    >&2 echo "Error: Branch '$BRANCH_NAME' already exists. Use a different feature name or --number."
                    exit 1
                fi
            else
                >&2 echo "Error: Failed to create git branch '$BRANCH_NAME'."
                if [ -n "$branch_create_error" ]; then
                    >&2 printf '%s\n' "$branch_create_error"
                fi
                exit 1
            fi
        fi
    else
        >&2 echo "[forge] Warning: Git repository not detected; skipped branch creation for $BRANCH_NAME"
    fi
    printf '# To persist: export FORGE_FEATURE=%q\n' "$BRANCH_NAME" >&2
fi

if $JSON_MODE; then
    if command -v jq >/dev/null 2>&1; then
        if [ "$DRY_RUN" = true ]; then
            jq -cn --arg branch_name "$BRANCH_NAME" --arg feature_num "$FEATURE_NUM" '{BRANCH_NAME:$branch_name, FEATURE_NUM:$feature_num, DRY_RUN:true}'
        else
            jq -cn --arg branch_name "$BRANCH_NAME" --arg feature_num "$FEATURE_NUM" '{BRANCH_NAME:$branch_name, FEATURE_NUM:$feature_num}'
        fi
    else
        if [ "$DRY_RUN" = true ]; then
            printf '{"BRANCH_NAME":"%s","FEATURE_NUM":"%s","DRY_RUN":true}\n' "$BRANCH_NAME" "$FEATURE_NUM"
        else
            printf '{"BRANCH_NAME":"%s","FEATURE_NUM":"%s"}\n' "$BRANCH_NAME" "$FEATURE_NUM"
        fi
    fi
else
    echo "BRANCH_NAME: $BRANCH_NAME"
    echo "FEATURE_NUM: $FEATURE_NUM"
    if [ "$DRY_RUN" != true ]; then
        printf '# To persist in your shell: export FORGE_FEATURE=%q\n' "$BRANCH_NAME"
    fi
fi
