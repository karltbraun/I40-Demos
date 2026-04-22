# I40 Demo — Requirements

> **Status: DRAFT — v0.3**
> Last updated: 2026-04-15

---

## 1. Purpose

This project is a self-contained, portable demonstration stack for Industrial 4.0 (I40) capabilities. Its primary goal is to show potential clients "the art of the possible" — how modern, open-standard tools can be assembled into a cohesive I40 architecture that connects the shop floor to data historians, SCADA systems, and dashboards; and that it can be set up quickly and cost-effectively for just about any environment.

The demo is intended to be opinionated but not prescriptive: it shows one well-reasoned way to build an I40 stack, not the only way.

---

## 2. Target Audience

**Industry:** Fresh Foods manufacturing.

**Role:** IT and OT management who are not deeply familiar with Industry 4.0 methods and concepts, and want to understand how these kinds of tools and processes can benefit their organizations.

**Technical level:** Mixed.
- Some attendees are business/executive types — outcomes-focused, minimal technical depth
- Others are OT/IT staff with some familiarity with SCADA, PLC/HMI, or IT systems

The demo must work at both levels simultaneously: visually compelling for the business audience, architecturally legible for the technical audience. It should not assume prior knowledge of I40 integration patterns.

---

## 3. Demo Narrative

### Core story

> *A single MQTT broker acts as the Unified Namespace — the central message bus for all operational data. Raw data arrives from the shop floor, is contextualized close to the source (turning raw signals into meaningful information), and then flows up into the broader I40 stack where multiple independent systems consume it: Ignition for full SCADA/HMI capability, Node-RED for low-code transformation and routing, Telegraf for zero-configuration data collection, and Grafana for operational dashboards — all from the same source, with no point-to-point integrations.*

### Key points to land

1. **Edge contextualization** — Data is captured and given context (engineering units, equipment names, thresholds) as close to the source as possible, before it flows upward. Raw signals become meaningful information at the edge.
2. **Decoupling** — Producers and consumers are independent. Adding a new consumer requires no changes to existing systems.
3. **Bidirectionality** — Ignition can both consume data from MQTT *and* publish tag changes back to the broker, enabling write-down to edge devices (e.g., setpoint changes, commands).
4. **Multiple paths, same data** — Node-RED and Telegraf both write to InfluxDB via different approaches (visual/low-code vs. zero-config). This demonstrates that there is no single "right" tool at each layer.
5. **Open standards** — MQTT, InfluxDB line protocol, REST APIs. No proprietary lock-in at the integration layer.

### Demo arc (suggested)

1. Show raw MQTT data arriving from the source — uncontextualized, just numbers
2. Show Node-RED adding context (labels, units, equipment hierarchy)
3. Show InfluxDB receiving the enriched data via both Node-RED and Telegraf
4. Show Grafana displaying a production-quality Fresh Foods dashboard
5. Show Ignition with tags auto-populated by MQTT Engine — then demonstrate a bidirectional setpoint change flowing back to the broker

---

## 4. Simulated Data / Demo Scenario

### Phase 1 (current — development and testing)

Live data from the existing temperature sensor and smart plug environment (KTB home lab). This provides real, varied data for building and testing Node-RED flows, Grafana dashboards, and Ignition tag configurations.

Note: Phase 1 has an external dependency on the physical sensor environment. It does not satisfy the "fully self-contained" requirement and is not suitable for presenting to a client away from the home lab.

### Phase 2 (demo-ready — target for client presentations)

A self-contained data simulator will replace the live sensor dependency, allowing the demo to run anywhere. Two candidates under consideration:

- **Packaging manufacturer MQTT simulator** — an external MQTT broker simulating a packaging line; can be connected as a data source when available
- **Built-in simulator container** — a lightweight publisher included in the stack (Python or Node-RED inject nodes) that generates realistic Fresh Foods data (temperatures, energy consumption, production counts) without any external dependency

Phase 2 is required before this demo is presented to a client off-site.

### Fresh Foods data model (indicative)

Suggested signals to simulate, mapped to the Fresh Foods context:

| Signal | Unit | Equipment | MQTT Topic (example) |
|--------|------|-----------|---------------------|
| Zone temperature | °C / °F | Cold storage, prep area | `i40/site/zone/temp` |
| Chiller setpoint | °C / °F | Refrigeration unit | `i40/site/chiller/setpoint` |
| Energy consumption | kW | Production equipment | `i40/site/equipment/power` |
| Conveyor speed | m/min | Production line | `i40/site/line1/speed` |
| Units produced | count | Production line | `i40/site/line1/count` |
| Equipment fault | bool | Any | `i40/site/equipment/fault` |

---

## 5. Services and Their Roles

| Service | Image | Role in Demo |
|---------|-------|-------------|
| **Mosquitto** | `eclipse-mosquitto:latest` | MQTT broker — the Unified Namespace hub |
| **InfluxDB 3** | `influxdb:3.9.0-core` | Time-series historian for all signal data |
| **Node-RED** | Custom (see §5.2) | Visual/low-code MQTT consumer; adds context and routes to InfluxDB |
| **Grafana** | `grafana/grafana:latest` | Operational dashboards; queries InfluxDB |
| **Ignition** | Custom (see §5.1) | Full SCADA/HMI; bidirectional MQTT integration |
| **Telegraf** | `telegraf:1.33` | Zero-config MQTT → InfluxDB pipeline; contrasts with Node-RED approach |

### 5.1 Ignition

The demo runs under Ignition's **trial license** (2-hour gateway sessions; no activation required). This covers both the Ignition gateway and the Cirrus Link modules, which also operate in trial mode.

Cirrus Link modules included in the custom Ignition image:

| Module | Role |
|--------|------|
| MQTT Engine | Subscribes to broker; auto-creates Ignition tags from MQTT payloads |
| MQTT Transmission | Publishes Ignition tag changes back to the broker (bidirectional) |
| MQTT Distributor | Sparkplug-aware MQTT server within Ignition (available, optional use) |
| MQTT Recorder | Records Sparkplug data to a database from Ignition (available, optional use) |

JDBC driver modules also included for potential database connectivity demonstrations:
- MariaDB, MSSQL, PostgreSQL

### 5.2 Node-RED

Custom image built from `Dockerfile.nodered`. Adds:
- `node-red-contrib-influxdb` — InfluxDB read/write nodes (v1/v2/v3 API support)
- `@flowfuse/node-red-dashboard` — dashboard UI nodes for in-browser visualization

---

## 6. Non-Functional Requirements

### 6.1 Portability

- Runs on Apple Silicon (ARM64) and x86_64 (Intel/AMD) without code changes
- Separate compose variant for cloud/server deployments (`restart: always`)
- Single command to start: `./start`

### 6.2 Manageability

- Stack is manageable via **Docker Desktop + Portainer extension** on Mac
- All services pull pre-built images from a registry — no on-machine builds required
- Image versions pinned via `.env` for repeatable deployments

### 6.3 Self-Contained (Phase 2 target)

- No external dependencies at demo runtime
- Data simulator included in the stack (Phase 2)
- Grafana datasource and starter dashboard auto-provisioned on first start
- Note: Phase 1 depends on live sensor hardware — not suitable for off-site client demos

### 6.4 Image Registry

**Chosen registry: GitHub Container Registry (GHCR)** — `ghcr.io/karltbraun/`

Rationale over Docker Hub:
- Docker Hub free tier limits private repos to 1 (this project needs 2 custom images at minimum)
- GHCR is free for unlimited private packages on a personal GitHub account
- Single set of credentials — same GitHub PAT used for git access and image pulls
- Native integration with the GitHub source repository

Image naming convention: `ghcr.io/karltbraun/i40-<service>:<tag>`

Example: `ghcr.io/karltbraun/i40-ignition:2026-04-13.d3283f5`

The custom Ignition image (which embeds Cirrus Link modules) **must remain in a private GHCR repository** at all times.

### 6.5 Source Control

- Remote: private GitHub repository under `karltbraun`
- Local: `~/Development/KTBCS/I40-Stack/`
- Never committed: `.env`, `secrets/`, `modules/*.modl`

---

## 7. Out of Scope

- Production security hardening (TLS on MQTT, auth tokens, network segmentation)
- Real PLC/device connectivity
- High availability or clustering
- Cloud historian / remote data replication
- Mobile or responsive UI

---

## 8. Open Items

| # | Question | Priority |
|---|----------|----------|
| 1 | Phase 2 simulator — built-in container vs. packaging manufacturer broker | High |
