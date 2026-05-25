#!/usr/bin/env bash
set -euo pipefail

cat >&2 <<'MSG'
nats-server local host setup is disabled.

Do not create local .env files or compose host state from this app repository.
Validate the active NATS runtime from its deployed endpoint and JetStream state.
MSG

exit 2
