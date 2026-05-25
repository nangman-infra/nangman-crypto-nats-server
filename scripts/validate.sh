#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
APP_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd -P)"
CONFIG="$APP_DIR/nats-server.conf"

for script in "$APP_DIR"/scripts/*.sh; do
  bash -n "$script"
done

docker run --rm \
  -v "$CONFIG:/etc/nats/nats-server.conf:ro" \
  nats:2.11-alpine \
  -c /etc/nats/nats-server.conf \
  -t

docker build -t nats-server-app:ci "$APP_DIR"
