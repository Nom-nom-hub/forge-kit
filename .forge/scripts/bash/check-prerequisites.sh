#!/usr/bin/env bash
# FORGE: Check Project Prerequisites and Health
# Usage: ./scripts/bash/check-prerequisites.sh --json
# Outputs JSON with project health status

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
JSON_OUTPUT=false
REQUIRE_TASKS=false
INCLUDE_TASKS=false
PATHS_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON_OUTPUT=true; shift ;;
    --require-tasks) REQUIRE_TASKS=true; shift ;;
    --include-tasks) INCLUDE_TASKS=true; shift ;;
    --paths-only) PATHS_ONLY=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Check FORGE directory structure
FORGE_DIR="$ROOT_DIR/.forge"
FORGE_EXISTS=false
SIGNALS_COUNT=0
HYPOTHESES_COUNT=0
DECISIONS_COUNT=0
FEATURES_COUNT=0
EXPERIMENTS_COUNT=0
RELEASES_COUNT=0
CONSTITUTION_EXISTS=false

if [[ -d "$FORGE_DIR" ]]; then
  FORGE_EXISTS=true
  [[ -d "$FORGE_DIR/signals" ]] && SIGNALS_COUNT=$(find "$FORGE_DIR/signals" -name "*.yaml" 2>/dev/null | wc -l)
  [[ -d "$FORGE_DIR/hypotheses" ]] && HYPOTHESES_COUNT=$(find "$FORGE_DIR/hypotheses" -name "*.yaml" 2>/dev/null | wc -l)
  [[ -d "$FORGE_DIR/decisions" ]] && DECISIONS_COUNT=$(find "$FORGE_DIR/decisions" -name "*.yaml" 2>/dev/null | wc -l)
  [[ -d "$FORGE_DIR/features" ]] && FEATURES_COUNT=$(find "$FORGE_DIR/features" -name "*.yaml" 2>/dev/null | wc -l)
  [[ -d "$FORGE_DIR/experiments" ]] && EXPERIMENTS_COUNT=$(find "$FORGE_DIR/experiments" -name "*.yaml" 2>/dev/null | wc -l)
  [[ -d "$FORGE_DIR/releases" ]] && RELEASES_COUNT=$(find "$FORGE_DIR/releases" -name "*.yaml" 2>/dev/null | wc -l)
  [[ -f "$FORGE_DIR/memory/constitution.md" ]] && CONSTITUTION_EXISTS=true
fi

# Find latest feature spec
LATEST_SPEC_DIR=""
if [[ -d "$ROOT_DIR/specs" ]]; then
  LATEST_SPEC_DIR=$(find "$ROOT_DIR/specs" -maxdepth 1 -type d | sort | tail -1 2>/dev/null || echo "")
fi

if [[ "$JSON_OUTPUT" == true ]]; then
  jq -n \
    --arg forge_root "$FORGE_DIR" \
    --argjson forge_exists "$FORGE_EXISTS" \
    --argjson signals "$SIGNALS_COUNT" \
    --argjson hypotheses "$HYPOTHESES_COUNT" \
    --argjson decisions "$DECISIONS_COUNT" \
    --argjson features "$FEATURES_COUNT" \
    --argjson experiments "$EXPERIMENTS_COUNT" \
    --argjson releases "$RELEASES_COUNT" \
    --argjson constitution "$CONSTITUTION_EXISTS" \
    '{
      forge_root: $forge_root,
      forge_exists: $forge_exists,
      artifacts: {
        signals: $signals,
        hypotheses: $hypotheses,
        decisions: $decisions,
        features: $features,
        experiments: $experiments,
        releases: $releases
      },
      constitution_exists: $constitution
    }'
else
  echo "FORGE Health Check:"
  echo "  Directory: $FORGE_DIR"
  echo "  FORGE initialized: $FORGE_EXISTS"
  echo "  Signals: $SIGNALS_COUNT"
  echo "  Hypotheses: $HYPOTHESES_COUNT"
  echo "  Decisions: $DECISIONS_COUNT"
  echo "  Features: $FEATURES_COUNT"
  echo "  Experiments: $EXPERIMENTS_COUNT"
  echo "  Releases: $RELEASES_COUNT"
  echo "  Constitution: $CONSTITUTION_EXISTS"
fi
