# LineFeed Simulator

Simulates a fresh-foods raw-product-dump production line (NewCo / Soledad facility) and streams real-time metrics via MQTT → Telegraf → InfluxDB 3 → Grafana.

The core demo story: a line operator running the cutter feed faster than the SKU 102 recipe specifies, causing cumulative equipment damage — visible live on the dashboard as the speed delta climbs.

---

## Prerequisites

- Docker running
- [I40-Stack](../I40-Stack/) running (provides the MQTT broker, InfluxDB, Grafana)
- `.env` configured (see Setup below)

---

## Setup (first time)

```bash
cp .env.template .env
```

Edit `.env` and set:

| Variable | Value |
|---|---|
| `LFS_IMAGE` | Published image tag — run `./scripts/build-and-push-lfs` to build, or use `ghcr.io/karltbraun/i40-lfs:2026-04-22.5f6a613` |
| `MQTT_BROKER` | `host.docker.internal` if I40-Stack is on the same Mac; LAN IP or hostname otherwise |

---

## Starting the Demo

```bash
./start-lfs                    # start with defaults (--speed 5 --loop)
./start-lfs --speed 10 --loop  # start then apply faster speed
```

Auto-detects platform (Apple M-series or x86_64) and starts the container. Pulls the image on first run.

### Changing speed while running

```bash
docker exec i40-lfs lfs-restart --speed 10 --loop
```

Restarts the simulator inside the running container with new parameters — no container restart needed.

### Monitoring logs

```bash
tail -f logs/simulator.log
```

---

## Stopping the Demo

```bash
docker stop i40-lfs
```

---

## Grafana Dashboard

Open: **http://localhost:3000/d/linefeed-v1/**

The dashboard auto-refreshes and shows:

- Current line state and SKU
- Live and historical cutter feed speed vs. recommended
- Speed delta % (watch this climb during the SKU 102 run)
- OEE Availability and downtime events

---

## Options

| Flag                 | Description                                             |
| -------------------- | ------------------------------------------------------- |
| `--speed MULTIPLIER` | Compress sim time (e.g. `5` = 5× faster than real-time) |
| `--loop`             | Repeat the order schedule indefinitely until stopped    |

At `--speed 5` one full schedule cycle (SKU 101 → 102 → 103) takes about **3 minutes** of wall-clock time.

---

## Order Schedule (default `config.toml`)

| Order | SKU | Name              | Sim Duration | Notes                                                  |
| ----- | --- | ----------------- | ------------ | ------------------------------------------------------ |
| 1     | 101 | Fresh Cut Lettuce | 300 s        | Normal run                                             |
| 2     | 102 | Shredded Cabbage  | 420 s        | **22% overspeed bias** kicks in at 40% through the run |
| 3     | 103 | Diced Onion       | 240 s        | Normal run                                             |
