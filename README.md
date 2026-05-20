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

Default client access is LAN/WireGuard-ready. The NATS client port is published
on all host interfaces by default, while the monitoring port stays local-only:

```text
0.0.0.0:4222 = NATS client port
127.0.0.1:8222 = NATS monitor port
```

On a host such as `phy-nangman-dev-lattepanda-seokchon-01`, LAN clients can use:

```text
nats://192.168.10.45:4222
```

If the host has multiple networks and the service should be reachable only on a
specific LAN address, set this in `.env` before running `scripts/deploy.sh`:

```text
NATS_CLIENT_BIND=192.168.10.45
```

Do not bind the monitor port to a LAN address unless there is a separate access
control layer in front of it.

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

Verify LAN reachability from another host:

```bash
docker run --rm natsio/nats-box:0.17.0 \
  nats --server nats://192.168.10.45:4222 server check connection

docker run --rm natsio/nats-box:0.17.0 \
  nats --server nats://192.168.10.45:4222 stream info RAW_INTEL
```

Re-apply stream definitions without restarting the server:

```bash
cd /Volumes/WD/Developments/nangman-crypto/apps/nats-server-app
scripts/ensure-streams.sh
```
