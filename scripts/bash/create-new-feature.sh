#!/usr/bin/env bash
# FORGE: Create New Feature Directory Structure
# Usage: ./scripts/bash/create-new-feature.sh --name "export-shortcut" --feature-id "fea-x7kp"
# Outputs JSON: { "feature_directory": ".forge/features/fea-x7kp", "spec_directory": "specs/fea-x7kp-export-shortcut" }

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Parse arguments
NAME=""
FEATURE_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="$2"; shift 2 ;;
    --feature-id) FEATURE_ID="$2"; shift 2 ;;
    --json) JSON_OUTPUT=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$FEATURE_ID" ]]; then
  echo '{"error": "Missing required --feature-id argument"}'
  exit 1
fi

# Generate name from feature ID if not provided
if [[ -z "$NAME" ]]; then
  NAME="${FEATURE_ID#fea-}"
fi

# Create directories
FEATURE_DIR="$ROOT_DIR/.forge/features/$FEATURE_ID"
mkdir -p "$FEATURE_DIR"

SPEC_DIR="$ROOT_DIR/specs"
mkdir -p "$SPEC_DIR"

# Output JSON
echo "{\"feature_directory\": \"$FEATURE_DIR\", \"spec_directory\": \"$SPEC_DIR\"}"
