#!/usr/bin/env bash
set -euo pipefail

NATS_URL="${NATS_URL:?NATS_URL must point to the active runtime NATS endpoint}"
NATS_RAW_INTEL_STREAM_MAX_AGE="${NATS_RAW_INTEL_STREAM_MAX_AGE:-168h}"
NATS_STRUCTURED_INTEL_STREAM_MAX_AGE="${NATS_STRUCTURED_INTEL_STREAM_MAX_AGE:-336h}"
NATS_STRUCTURED_INTEL_STREAM_DUPLICATE_WINDOW="${NATS_STRUCTURED_INTEL_STREAM_DUPLICATE_WINDOW:-24h}"
NATS_INTEL_CANDIDATE_STREAM_MAX_AGE="${NATS_INTEL_CANDIDATE_STREAM_MAX_AGE:-336h}"
NATS_INTEL_CANDIDATE_STREAM_DUPLICATE_WINDOW="${NATS_INTEL_CANDIDATE_STREAM_DUPLICATE_WINDOW:-24h}"
NATS_MARKET_LIVE_STREAM_MAX_AGE="${NATS_MARKET_LIVE_STREAM_MAX_AGE:-24h}"
NATS_MARKET_LIVE_STREAM_DUPLICATE_WINDOW="${NATS_MARKET_LIVE_STREAM_DUPLICATE_WINDOW:-2m}"

if ! command -v nats >/dev/null 2>&1; then
  printf 'missing required command: nats\n' >&2
  exit 1
fi

until nats --server "$NATS_URL" server check connection >/dev/null 2>&1; do
  sleep 1
done

if nats --server "$NATS_URL" stream info RAW_INTEL >/dev/null 2>&1; then
  nats --server "$NATS_URL" stream info RAW_INTEL
else
  nats --server "$NATS_URL" stream add RAW_INTEL \
    --subjects "raw_intel_event.>" \
    --storage file \
    --retention limits \
    --discard old \
    --max-age "$NATS_RAW_INTEL_STREAM_MAX_AGE" \
    --dupe-window 2m \
    --defaults
fi

if nats --server "$NATS_URL" stream info STRUCTURED_INTEL >/dev/null 2>&1; then
  nats --server "$NATS_URL" stream update STRUCTURED_INTEL \
    --subjects "structured_intel_packet.created" \
    --subjects "context_flag_packet.created" \
    --subjects "structuring_health_event.created" \
    --discard old \
    --max-age "$NATS_STRUCTURED_INTEL_STREAM_MAX_AGE" \
    --dupe-window "$NATS_STRUCTURED_INTEL_STREAM_DUPLICATE_WINDOW" \
    --force
else
  nats --server "$NATS_URL" stream add STRUCTURED_INTEL \
    --subjects "structured_intel_packet.created" \
    --subjects "context_flag_packet.created" \
    --subjects "structuring_health_event.created" \
    --storage file \
    --retention limits \
    --discard old \
    --max-age "$NATS_STRUCTURED_INTEL_STREAM_MAX_AGE" \
    --dupe-window "$NATS_STRUCTURED_INTEL_STREAM_DUPLICATE_WINDOW" \
    --defaults
fi
nats --server "$NATS_URL" stream info STRUCTURED_INTEL

if nats --server "$NATS_URL" stream info INTEL_CANDIDATE >/dev/null 2>&1; then
  nats --server "$NATS_URL" stream update INTEL_CANDIDATE \
    --subjects "intel_candidate_evidence_bundle.created" \
    --subjects "intel_candidate_screening_event.created" \
    --subjects "intel_candidate_hypothesis_state.created" \
    --subjects "intel_candidate_health_event.created" \
    --discard old \
    --max-age "$NATS_INTEL_CANDIDATE_STREAM_MAX_AGE" \
    --dupe-window "$NATS_INTEL_CANDIDATE_STREAM_DUPLICATE_WINDOW" \
    --force
else
  nats --server "$NATS_URL" stream add INTEL_CANDIDATE \
    --subjects "intel_candidate_evidence_bundle.created" \
    --subjects "intel_candidate_screening_event.created" \
    --subjects "intel_candidate_hypothesis_state.created" \
    --subjects "intel_candidate_health_event.created" \
    --storage file \
    --retention limits \
    --discard old \
    --max-age "$NATS_INTEL_CANDIDATE_STREAM_MAX_AGE" \
    --dupe-window "$NATS_INTEL_CANDIDATE_STREAM_DUPLICATE_WINDOW" \
    --defaults
fi
nats --server "$NATS_URL" stream info INTEL_CANDIDATE

if nats --server "$NATS_URL" stream info MARKET_LIVE >/dev/null 2>&1; then
  nats --server "$NATS_URL" stream update MARKET_LIVE \
    --subjects "market_live_tick.created.>" \
    --discard old \
    --max-age "$NATS_MARKET_LIVE_STREAM_MAX_AGE" \
    --dupe-window "$NATS_MARKET_LIVE_STREAM_DUPLICATE_WINDOW" \
    --force
else
  nats --server "$NATS_URL" stream add MARKET_LIVE \
    --subjects "market_live_tick.created.>" \
    --storage file \
    --retention limits \
    --discard old \
    --max-age "$NATS_MARKET_LIVE_STREAM_MAX_AGE" \
    --dupe-window "$NATS_MARKET_LIVE_STREAM_DUPLICATE_WINDOW" \
    --defaults
fi
nats --server "$NATS_URL" stream info MARKET_LIVE
