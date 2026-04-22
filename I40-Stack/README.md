# I40-Stack

Core Docker infrastructure for I40 demo projects. Provides the shared services that
all demo applications (I40-LineFeedSimulator, I40-SmartPlugs) run on top of.

## Services

| Service | URL | Role |
|---|---|---|
| Mosquitto | `mqtt://localhost:1883` | MQTT broker — Unified Namespace hub |
| InfluxDB | `http://localhost:8181` | Time-series historian |
| Node-RED | `http://localhost:1881` | Visual flow builder |
| Grafana | `http://localhost:3000` | Dashboards |
| Ignition | `http://localhost:8088` | SCADA / HMI |
| Telegraf | (internal) | MQTT → InfluxDB pipeline |

## Starting the Stack

```bash
./start-I40-stack
```

Auto-detects platform (Apple M-series, x86_64 Mac, or Linux/cloud) and starts all services.

### Prerequisites

- Docker running
- `.env` file present (`cp .env.template .env` and fill in image tags)
- `secrets/IGNITION_ADMIN_PASSWORD` file present

See [DEPLOYMENT.md](DEPLOYMENT.md) for full build/push/deploy instructions.

## Demo Applications

Start I40-Stack first, then launch either or both independently:

| Application | Repo | How to start |
|---|---|---|
| LineFeed Simulator | `../I40-LineFeedSimulator` | `./start-lfs` (also starts stack if needed) |
| SmartPlugs | `../I40-SmartPlugs` | Import flows into Node-RED at `http://localhost:1881` |

## Platforms

| Compose file | Target |
|---|---|
| `docker-compose.m3.yml` | Apple Silicon (ARM64) |
| `docker-compose.x86_64.yml` | Intel/AMD Mac or Linux (x86_64) |
