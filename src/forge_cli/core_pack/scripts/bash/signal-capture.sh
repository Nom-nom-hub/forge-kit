#!/usr/bin/env bash
# FORGE: Quick Signal Capture
# Usage: ./scripts/bash/signal-capture.sh --observation "users can't find export"
#   --source "support_ticket" --severity "high"
# Outputs JSON: { "signal_id": "sig-{nanoid}", "signal_path": ".forge/signals/sig-{nanoid}.yaml" }

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Parse arguments
OBSERVATION=""
SOURCE="team_observation"
SEVERITY="medium"
CATEGORY="user_pain"
TAGS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --observation) OBSERVATION="$2"; shift 2 ;;
    --source) SOURCE="$2"; shift 2 ;;
    --severity) SEVERITY="$2"; shift 2 ;;
    --category) CATEGORY="$2"; shift 2 ;;
    --tags) TAGS="$2"; shift 2 ;;
    --json) JSON_OUTPUT=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$OBSERVATION" ]]; then
  echo '{"error": "Missing required --observation argument"}'
  exit 1
fi

# Generate nanoid using available tools
if command -v python3 &>/dev/null; then
  NANOID=$(python3 -c "
import secrets, string
alphabet = string.ascii_lowercase + string.digits
print(''.join(secrets.choice(alphabet) for _ in range(8)))
")
elif command -v openssl &>/dev/null; then
  NANOID=$(openssl rand -hex 4 | head -c 8)
else
  NANOID=$(date +%s | md5sum 2>/dev/null | head -c 8 || date +%s | md5 2>/dev/null | head -c 8)
fi

SIGNAL_ID="sig-${NANOID}"
SIGNAL_DIR="$ROOT_DIR/.forge/signals"
mkdir -p "$SIGNAL_DIR"

SIGNAL_FILE="$SIGNAL_DIR/${SIGNAL_ID}.yaml"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create signal YAML
cat > "$SIGNAL_FILE" <<EOF
forge_type: signal
id: ${SIGNAL_ID}
version: "1.0.0"
created_at: ${TIMESTAMP}
created_by: cli
status: raw

signal:
  category: ${CATEGORY}
  source:
    type: ${SOURCE}
    reference: ""
    confidence: 0.8
  observation: |
    ${OBSERVATION}
  evidence: []
  affected_dimensions:
    - users: ""
      frequency: sometimes
      severity: ${SEVERITY}
  raw_tags: [${TAGS}]

context:
  business_area: []
  technical_area: []
  time_sensitivity: medium

links:
  decisions: []
  features: []
  experiments: []
EOF

echo "{\"signal_id\": \"${SIGNAL_ID}\", \"signal_path\": \"${SIGNAL_FILE}\", \"observation\": \"${OBSERVATION}\"}"
