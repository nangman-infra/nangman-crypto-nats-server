#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
APP_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd -P)"
ENV_FILE="$APP_DIR/.env"
ENV_EXAMPLE="$APP_DIR/.env.example"
COMPOSE="$APP_DIR/compose.yml"

log() {
  printf '%s\n' "$*"
}

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    printf 'missing required file: %s\n' "$file" >&2
    printf 'run scripts/setup-host.sh first\n' >&2
    exit 1
  fi
}

ensure_env_file() {
  if [[ ! -f "$ENV_FILE" ]]; then
    require_file "$ENV_EXAMPLE"
    cp "$ENV_EXAMPLE" "$ENV_FILE"
    log "created $ENV_FILE from .env.example"
  fi
}

log "[1/5] config check"
ensure_env_file
require_file "$ENV_FILE"

log "[2/5] compose config"
sudo docker compose -f "$COMPOSE" --env-file "$ENV_FILE" config >/dev/null

log "[3/5] start NATS"
sudo docker compose -f "$COMPOSE" --env-file "$ENV_FILE" up -d

log "[4/5] ensure JetStream streams"
ENV_FILE="$ENV_FILE" COMPOSE="$COMPOSE" "$APP_DIR/scripts/ensure-streams.sh"

log "[5/5] service status"
sudo docker compose -f "$COMPOSE" --env-file "$ENV_FILE" ps

cat <<EOF
Follow NATS logs with:

sudo docker compose -f $COMPOSE --env-file $ENV_FILE logs -f nats
EOF
