# Session Notes

## Session 1 — 2026-04-12/13

### What was built

- Full project structure at `~/Development/KTBCS/I40-Demo/`
- Three platform-specific Docker Compose files (m3, x86_64, cloud) covering all 6 services
- Custom Dockerfiles for Node-RED (adds npm packages) and Ignition (bakes in Cirrus Link modules)
- Passthrough Dockerfiles for Mosquitto, InfluxDB, Grafana (flagged for removal — see below)
- `start` script with pre-flight checks and arch-aware compose file selection
- `scripts/build-and-push-*` per-service scripts using Docker Buildx for multi-arch images
- Mosquitto, Telegraf, and Grafana configs
- Grafana datasource auto-provisioning
- Private GitHub repo created: `github.com/karltbraun/i40-demo`
- Docker authenticated to GHCR (`ghcr.io/karltbraun`)
- `docs/requirements.md` v0.2 — project purpose, audience, narrative, data strategy, registry
- `DEPLOYMENT.md` — full build/push/deploy workflow

### What was NOT done yet

Images have not been built or pushed. The stack has not been started.

---

## Pending rework (before first image build)

These issues were identified in a design critique. Address them before building images — it's much cleaner to fix the structure before publishing anything.

### 1. Remove passthrough Dockerfiles (Mosquitto, InfluxDB, Grafana)
`Dockerfile.mosquitto`, `Dockerfile.influxdb`, `Dockerfile.grafana` are each just `FROM base-image` with nothing added. They add a build step and image variable for no benefit.
- Delete the three Dockerfiles and their `build-and-push-*` scripts
- Remove `MOSQUITTO_IMAGE`, `INFLUXDB_IMAGE`, `GRAFANA_IMAGE` from `.env.template` and compose files
- Replace with hardcoded upstream image references in compose files
- Remove their pre-flight checks from `start`

### 2. Resolve Telegraf inconsistency
Telegraf is the only service without an image variable — uses `telegraf:latest` inline. Once issue #1 is resolved (upstream images used directly), Telegraf becomes consistent. Pin it to a specific version tag rather than `latest`.

### 3. Delete `scripts/pull-and-start`
Single-line wrapper that just calls `./start`. No added value.

### 4. Fix Node-RED `flows/` mount
Currently mounted read-only over an empty directory. Should be read-write so flows built in the Node-RED UI are written to `./flows/` and can be committed to git.

### 5. Add Mosquitto healthcheck
So Telegraf and Node-RED can use `condition: service_healthy` consistently.
Healthcheck command: `mosquitto_sub -t '$$SYS/#' -C 1 -i healthcheck -W 3`

---

## Next steps after rework

1. `./scripts/build-and-push-nodered`
2. `./scripts/build-and-push-ignition`
3. Set `NODE_RED_IMAGE` and `IGNITION_IMAGE` in `.env`
4. `./start` — first full stack run
5. Verify all 6 services healthy, connect MQTT Explorer, test data flow

---

## Session 2 — 2026-04-14/15

### What was built

All pending rework items from Session 1 completed (commits `71add57` through `5215c9d`):
- Removed passthrough Dockerfiles and image variables for Mosquitto, InfluxDB, Grafana
- Pinned Telegraf to `telegraf:1.33`
- Deleted `scripts/pull-and-start`
- Fixed Node-RED `flows/` mount to read-write
- Added Mosquitto healthcheck

Stack brought up and all 6 services verified healthy.

**Node-RED → InfluxDB pipeline built and tested:**

- Flow file: `flows/pi1-temperature.json`
- Subscribes to `Pi1/sensors/raw/152/temperature_F` on the Vultr2 MQTT broker (100.100.164.105:1883)
- Payload is a raw float (e.g. `65.0`)
- Function node parses float, sets `msg.measurement = 'temperature'`, formats `msg.payload` as `[{value}, {tags}]`
- Writes to InfluxDB measurement `temperature`, database `i40demo`, tags: `device=Pi1`, `sensor_id=152`, `unit=F`
- Verified with `./scripts/watch-temperature`

**Grafana datasource verified working** — InfluxDB (I40 Demo) datasource auto-provisioned via
`config/grafana/provisioning/datasources/influxdb.yml`. Uses InfluxQL mode against `i40demo` database.
Tested via Explore with:
```sql
SELECT mean("value") FROM "temperature" WHERE $timeFilter GROUP BY time($__interval) fill(none)
```
Dashboard created with a temperature time series panel using the above query.

**Key gotchas learned:**
- `node-red-contrib-influxdb` 0.7.0 out node reads measurement from `msg.measurement` or the node's
  static config field — NOT from inside the payload array. Set `msg.measurement` in the function node.
- The influxdb config node requires `hostname`, `port`, and `protocol` in the flow JSON even when
  using v2.0 mode (they are marked `required: true` in the UI schema). Omitting them causes an
  "invalid properties" error on import.
- Correct payload format for `influxdb out` with tags: `msg.payload = [{value: temp}, {device: 'Pi1', ...}]`

### Data sources and pipeline architecture

**RTL_433 → Pi1 → TWIX pipeline:**
- RTL_433 on Pi1 receives 433MHz sensor transmissions and publishes per-attribute topics:
  `Pi1/sensors/raw/<sensor_id>/<attribute>` (e.g. `Pi1/sensors/raw/152/temperature_F`)
- A Python script on TWIX subscribes to Pi1 topics, aggregates by sensor_id into a local JSON
  database, then periodically republishes as per-sensor topics with full JSON payloads:
  `KTBMES/TWIX/sensors/house_weather_sensors/<device_name>`

**The DECK sensor IS sensor_id 152.** Both topics carry the same underlying sensor data:

| Topic | Payload | Notes |
|---|---|---|
| `Pi1/sensors/raw/152/temperature_F` | Raw float e.g. `65.0` | Wired ✓ — writing to InfluxDB |
| `KTBMES/TWIX/sensors/house_weather_sensors/DECK` | Full JSON (temperature_F, humidity, battery_ok, RSSI, timestamps, etc.) | Same sensor — wire if additional fields (humidity etc.) are needed |

### What remains (after Session 2)

- Extend InfluxDB ingestion to capture additional DECK fields (humidity, battery) via TWIX topic if desired
- Explore Ignition MQTT Engine integration

---

## Session 3 — 2026-04-15

### What was built

**Shelly smartplug pipeline (Shelly_Prod):**

- Explored MQTT data available from `KTBMES/TWIX/office/smartplugs/Shelly_Prod/#`
- TWIX republishes Shelly data as flat per-attribute topics under `switch:0/`
- Selected fields to store: `apower` (W), `total` (cumulative Wh), `tF` (plug temp °F)
- Flow file: `flows/shelly-prod.json`
- Three MQTT-in nodes, each writing one field to InfluxDB measurement `smartplug`
- Tags: `device=Shelly_Prod`, `room=office`
- Publishes approximately every 60 seconds

**InfluxDB schema for smartplug:**
- Measurement: `smartplug`
- Fields: `apower` (float, W), `total` (float, cumulative Wh), `tF` (float, °F)
- Tags: `device`, `room`
- Storing raw `total` (odometer-style counter) — Grafana computes delta with `non_negative_difference()`

**Grafana dashboard "I40 Demo 1"** — three panels:
| Panel | Query | Unit |
|---|---|---|
| Office-Prod Power Draw (W) | `SELECT mean("apower") FROM "smartplug" WHERE $timeFilter GROUP BY time($__interval) fill(none)` | Watts (W) |
| Energy Consumption (Wh/hr) | `SELECT non_negative_difference(last("total")) FROM "smartplug" WHERE $timeFilter GROUP BY time(1h)` | Watt-hour (Wh) |
| Plug Temperature (°F) | `SELECT mean("tF") FROM "smartplug" WHERE $timeFilter GROUP BY time($__interval) fill(none)` | Fahrenheit (°F) |

**Key gotchas learned:**
- InfluxDB 3 field names are case-sensitive in SQL queries — `"tF"` must be quoted exactly, `tf` fails
- `WHERE tF IS NOT NULL` does not work reliably in InfluxDB 3 — use `WHERE "tF" IS NOT NULL` or omit the filter
- `non_negative_difference(last("total"))` with `GROUP BY time(1h)` gives Wh/hour — partial hours show partial values
- Grafana query area defaults to Builder mode — click pencil icon to switch to Code (raw SQL) mode

### What remains

- Rename Grafana dashboard from "I40 Demo 1" to "I40 Demo"
- Add more smartplugs (Shelly_Lab_01, others) using same flow pattern with different device tags
- Extend InfluxDB ingestion to capture additional DECK sensor fields (humidity, battery) if desired
- Explore Ignition MQTT Engine integration
