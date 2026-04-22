# I40-SmartPlugs

SmartPlug monitoring demo built on top of [I40-Stack](../I40-Stack).

## What this is

Collects power and temperature data from Shelly smart plugs and a Raspberry Pi temperature
sensor, routes it through the I40-Stack MQTT broker and Node-RED into InfluxDB, and
visualizes it in Grafana.

## Prerequisites

I40-Stack must be running before using anything here:

```bash
cd ../I40-Stack && ./start-I40-stack
```

## Contents

| Path | Purpose |
|---|---|
| `flows/shelly-prod.json` | Node-RED flow: Shelly plug → InfluxDB (apower, total, tF) |
| `flows/pi1-temperature.json` | Node-RED flow: Pi1 temperature sensor → InfluxDB |
| `scripts/watch-temperature` | Poll InfluxDB and print latest temperature readings |

## Loading flows into Node-RED

1. Open Node-RED at `http://localhost:1881`
2. Menu → Import → select the JSON file from `flows/`
3. Deploy

## Services (provided by I40-Stack)

| Service | URL |
|---|---|
| MQTT broker | `localhost:1883` |
| InfluxDB | `http://localhost:8181` |
| Node-RED | `http://localhost:1881` |
| Grafana | `http://localhost:3000` |
