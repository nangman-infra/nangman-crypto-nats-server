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

Default client and monitoring access are LAN/WireGuard-ready. Both ports are
published on all host interfaces by default:

```text
0.0.0.0:4222 = NATS client port
0.0.0.0:8222 = NATS monitor HTTP port
```

On a host such as `phy-nangman-dev-lattepanda-seokchon-01`, LAN clients can use:

```text
nats://<private-nats-host>:4222
```

The monitoring endpoints are available in a browser at:

```text
http://<private-nats-host>:8222/
http://<private-nats-host>:8222/varz
http://<private-nats-host>:8222/connz
http://<private-nats-host>:8222/jsz
http://<private-nats-host>:8222/healthz
```

If the host has multiple networks and the service should be reachable only on
one specific LAN address, set these in `.env` before running
`scripts/deploy.sh`:

```text
NATS_CLIENT_BIND=<private-nats-host>
NATS_MONITOR_BIND=<private-nats-host>
```

Do not expose the monitoring port to the public internet. NATS monitoring
endpoints do not provide their own authentication or authorization.

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
  nats --server nats://<private-nats-host>:4222 server check connection

docker run --rm natsio/nats-box:0.17.0 \
  nats --server nats://<private-nats-host>:4222 stream info RAW_INTEL

curl http://<private-nats-host>:8222/healthz
curl http://<private-nats-host>:8222/jsz
```

Re-apply stream definitions without restarting the server:

```bash
cd /Volumes/WD/Developments/nangman-crypto/apps/nats-server-app
scripts/ensure-streams.sh
```

Validate the standalone repository before pushing:

```bash
cd /Volumes/WD/Developments/nangman-crypto/apps/nats-server-app
scripts/validate.sh
```
