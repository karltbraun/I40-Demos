# I40-Demos

Industry 4.0 demonstration projects built around a shared MQTT → InfluxDB 3 → Grafana stack.

## Structure

| Directory | Description |
|---|---|
| [`I40-Stack/`](I40-Stack/) | Core services: Mosquitto, InfluxDB 3, Telegraf, Grafana, Node-RED, Ignition |
| [`I40-LineFeedSimulator/`](I40-LineFeedSimulator/) | Production line simulator — publishes live metrics via MQTT |
| [`I40-SmartPlugs/`](I40-SmartPlugs/) | Shelly smart plug monitoring via Node-RED |
| [`I40-VirtualFactory/`](I40-VirtualFactory/) | (nascent) Virtual factory simulation |

## Quick Start

**1. Start the core stack:**

```bash
cd I40-Stack && ./start-I40-stack
```

**2. Start a producer** (can run on the same host or a different one):

```bash
cd I40-LineFeedSimulator && ./start-lfs
```

Producers connect to the stack via MQTT — each configures its broker address in its own `.env`.

## Platforms

All compose files ship in two variants. The `start-*` scripts auto-detect and select the right one:

| File | Target |
|---|---|
| `docker-compose.m3.yml` | Apple Silicon (ARM64) |
| `docker-compose.x86_64.yml` | Intel/AMD Mac or Linux |

## Dashboard

Once the stack and a producer are running, open Grafana at **http://localhost:3000**.
