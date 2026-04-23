# I40-SmartPlugs

SmartPlug monitoring demo built on top of [I40-Stack](../I40-Stack).

## What this is

Collects power and weather sensor data which has been published into an MQTT Broker via a node red flow, stores it in InfluxDB, and visualizes it in Grafana.

It doesn't really matter how the data gets into the MQTT broker, but we expect the following topics to be published:
| Topic | Description |
|---|---|
|"KTBMES/TWIX/#/smartplugs/#/switch:0/apower"| Active power (W)(*) |

(*) The '#' is a wildcard for the location and smartplug name.  The location names can be:

| Location | Description |
|---|---|
|'garage'| EV smartplug |
|'office'| Contains the Lab and the Production Smartplugs|

The smartplug names can be:
| Smartplug name | Description |
|---|---|
| Shelly_EV | EV smartplug |
| Shelly_Lab_01 | Lab smartplug |
| Shelly_Prod | Production smartplug |   

See the "Weather_Sensors_and_Smartplugs_with_MQTT" project for details on how these values are published into these topics.

## Prerequisites

I40-Stack must be running before using anything here:

```bash
cd ../I40-Stack && ./start-I40-stack
```

Weather_Sensors_and_Smartplugs_with_MQTT project must be running to feed data into the MQTT broker

## Contents

 Path | Purpose |
|---|---|
| `flows/shelly-prod.json` | Node-RED flow: Shelly_Prod (office) → InfluxDB (apower, total, tF) |
| `flows/shelly-ev.json` | Node-RED flow: Shelly_EV (garage) → InfluxDB (apower, total, tF) |
| `flows/pi1-temperature.json` | Node-RED flow: Pi1 temperature sensor → InfluxDB |
| `scripts/watch-temperature` | Poll InfluxDB and print latest temperature readings |

## Loading flows into Node-RED

1. Open Node-RED at `http://localhost:1881`
2. Menu → Import → select the JSON file(s) from `flows/`
3. Deploy

Each flow file is self-contained and can be imported independently. Shared config nodes (MQTT broker, InfluxDB) are deduplicated by Node-RED on import.

## Services (provided by I40-Stack)

| Service | URL |
|---|---|
| MQTT broker | `localhost:1883` |
| InfluxDB | `http://localhost:8181` |
| Node-RED | `http://localhost:1881` |
| Grafana | `http://localhost:3000` |
