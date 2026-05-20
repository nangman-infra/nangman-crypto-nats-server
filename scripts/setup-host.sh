#!/usr/bin/env bash
set -euo pipefail

HOST_ROOT="/opt/nangman-crypto"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
APP_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd -P)"
DATA_ROOT="$HOST_ROOT/data/nats"
CONFIG_ROOT="$HOST_ROOT/apps/nats-server-app"
ENV_FILE="$APP_DIR/.env"

HOST_USER="${SUDO_USER:-${USER:-$(id -un)}}"

log() {
  printf '%s\n' "$*"
}

set_env_value() {
  local key="$1"
  local value="$2"
  if grep -q "^$key=" "$ENV_FILE"; then
    sed -i "s|^$key=.*|$key=$value|" "$ENV_FILE"
  else
    printf '%s=%s\n' "$key" "$value" >> "$ENV_FILE"
  fi
}

log "[1/4] create host directories"
sudo mkdir -p "$DATA_ROOT" "$CONFIG_ROOT"
sudo chown -R "$HOST_USER:$HOST_USER" "$HOST_ROOT"

log "[2/4] install NATS config"
install -m 0644 "$APP_DIR/nats-server.conf" "$CONFIG_ROOT/nats-server.conf"

log "[3/4] create env file"
if [[ ! -e "$ENV_FILE" ]]; then
  cp "$APP_DIR/.env.example" "$ENV_FILE"
  log "created $ENV_FILE from .env.example"
else
  log "$ENV_FILE already exists; preserving local values"
fi

log "[4/4] pin host paths"
set_env_value "NATS_CONFIG_PATH" "$CONFIG_ROOT/nats-server.conf"
set_env_value "NATS_DATA_ROOT" "$DATA_ROOT"

log "setup complete. run scripts/deploy.sh next"
