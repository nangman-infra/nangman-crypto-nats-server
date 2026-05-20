# nats-server-app

Shared NATS JetStream server for on-prem application event publishing.

This server is intentionally separate from application containers.

```text
nats-server
  -> JetStream enabled
  -> RAW_INTEL stream for raw_intel_event.>
  -> STRUCTURED_INTEL stream for structured_intel_packet.created
  -> STRUCTURED_INTEL stream for context_flag_packet.created
  -> STRUCTURED_INTEL stream for structuring_health_event.created
  -> INTEL_CANDIDATE stream for intel_candidate_evidence_bundle.created
  -> INTEL_CANDIDATE stream for intel_candidate_screening_event.created
  -> INTEL_CANDIDATE stream for intel_candidate_hypothesis_state.created
  -> INTEL_CANDIDATE stream for intel_candidate_health_event.created
  -> Docker network: nangman-crypto-bus
  -> intel-crawl-app connects with NATS_URL=nats://nats:4222
  -> intel-structuring-app publishes L1 pointers to STRUCTURED_INTEL
```

Start it before app workers:

```bash
cd /Volumes/WD/Developments/nangman-crypto/apps/nats-server-app
scripts/setup-host.sh
scripts/deploy.sh
```

Default host ports are bound to `127.0.0.1`:

```text
4222 = NATS client port
8222 = NATS monitor port
```

Default durable data path:

```text
/opt/nangman-crypto/data/nats
```

Default stream retention:

```text
RAW_INTEL = 168h
STRUCTURED_INTEL = 336h
STRUCTURED_INTEL duplicate window = 24h
INTEL_CANDIDATE = 336h
INTEL_CANDIDATE duplicate window = 24h
```

Verify streams:

```bash
sudo docker run --rm --network host natsio/nats-box:0.17.0 \
  nats --server nats://127.0.0.1:4222 stream info RAW_INTEL

sudo docker run --rm --network host natsio/nats-box:0.17.0 \
  nats --server nats://127.0.0.1:4222 stream info STRUCTURED_INTEL

sudo docker run --rm --network host natsio/nats-box:0.17.0 \
  nats --server nats://127.0.0.1:4222 stream info INTEL_CANDIDATE
```

Re-apply stream definitions without restarting the server:

```bash
cd /Volumes/WD/Developments/nangman-crypto/apps/nats-server-app
scripts/ensure-streams.sh
```
