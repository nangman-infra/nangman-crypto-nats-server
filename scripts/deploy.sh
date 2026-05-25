#!/usr/bin/env bash
set -euo pipefail

cat >&2 <<'MSG'
nats-server local compose deploy is disabled.

Current runtime source of truth:
  active NATS runtime endpoint
  JetStream stream and consumer state
  app runtime configuration that points to NATS

Use the current infrastructure deployment workflow for runtime changes.
MSG

exit 2
