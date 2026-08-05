#!/usr/bin/env bash
# Deploy the AI Web Oracle.
#
# Usage: ./scripts/deploy_price_oracle.sh "BTC-USD" "https://example.com/btc"
set -euo pipefail

PAIR="${1:-BTC-USD}"
SOURCE_URL="${2:-https://www.coingecko.com/en/coins/bitcoin}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

command -v genlayer >/dev/null 2>&1 || {
  echo "genlayer CLI not found. Install: npm i -g genlayer" >&2
  exit 1
}

genlayer deploy \
  --contract "$ROOT/contracts/price_oracle.py" \
  --args "[\"$PAIR\", \"$SOURCE_URL\"]"
