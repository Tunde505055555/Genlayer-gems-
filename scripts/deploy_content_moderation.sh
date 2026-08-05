#!/usr/bin/env bash
# Deploy the Content Moderation contract.
#
# Usage: ./scripts/deploy_content_moderation.sh [path/to/guidelines.txt]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GUIDELINES_FILE="${1:-$ROOT/examples/guidelines.txt}"

command -v genlayer >/dev/null 2>&1 || {
  echo "genlayer CLI not found. Install: npm i -g genlayer" >&2
  exit 1
}

GUIDELINES="$(python3 -c 'import json,sys; print(json.dumps(open(sys.argv[1]).read()))' "$GUIDELINES_FILE")"

genlayer deploy \
  --contract "$ROOT/contracts/content_moderation.py" \
  --args "[$GUIDELINES]"
