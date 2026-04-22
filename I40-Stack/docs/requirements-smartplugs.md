# Requirements — Smart Plugs

> **Status: DRAFT — v0.1**
> Last updated: 2026-04-15

---

## 1. Purpose

Ingest energy and power data from Shelly smart plugs into InfluxDB and visualize it in Grafana. This provides a second live data stream for the I40 demo alongside the temperature sensors, demonstrating energy monitoring as a practical I40 use case.

---

## 2. Data Source

### 2.1 Physical devices

Shelly smart plugs (PlugUS model) publish status data to the Vultr2 MQTT broker (`100.100.164.105:1883`). The plugs are configured to report to `Shelly/<device_name>/...` topics.

### 2.2 TWIX republication

A Python script on TWIX subscribes to the raw Shelly topics, flattens the nested JSON payloads into individual attributes, and republishes them as flat per-attribute topics:

```
KTBMES/TWIX/<room>/smartplugs/<device>/switch:0/<attribute>
```

Example topics for `Shelly_Prod` in the `office` room:
```
KTBMES/TWIX/office/smartplugs/Shelly_Prod/switch:0/apower    → 62.2
KTBMES/TWIX/office/smartplugs/Shelly_Prod/switch:0/voltage   → 124.4
KTBMES/TWIX/office/smartplugs/Shelly_Prod/switch:0/current   → 0.728
KTBMES/TWIX/office/smartplugs/Shelly_Prod/switch:0/total     → 366796.225
KTBMES/TWIX/office/smartplugs/Shelly_Prod/switch:0/by_minute → [1033.646, 1038.427, 1040.34]
KTBMES/TWIX/office/smartplugs/Shelly_Prod/switch:0/tC        → 47.3
KTBMES/TWIX/office/smartplugs/Shelly_Prod/switch:0/tF        → 117.1
```

Publish cadence: approximately every 60 seconds.

### 2.3 Available fields

| Field | Description | Unit | Notes |
|---|---|---|---|
| `apower` | Instantaneous power draw | W | Varies with load — most interesting for real-time monitoring |
| `voltage` | Mains voltage | V | Stable (~124V) — low value for demo |
| `current` | Current draw | A | Derivable from apower/voltage — redundant |
| `total` | Cumulative energy counter | Wh | Odometer-style — use `non_negative_difference()` for consumption |
| `by_minute` | 3-element array of per-minute Wh | Wh | Redundant with apower + total |
| `tC` / `tF` | Plug body temperature | °C / °F | Health/safety signal |

---

## 3. Selected Fields for Storage

Based on analysis of 15 minutes of live data, three fields were chosen:

| Field | Rationale |
|---|---|
| `apower` | Real-time power draw — visually interesting, varies enough to show change |
| `total` | Cumulative Wh counter — enables consumption calculation over any time window |
| `tF` | Plug temperature — health/safety signal, adds variety to the dashboard |

`voltage`, `current`, and `by_minute` are not stored — they are either stable, derivable, or redundant.

---

## 4. InfluxDB Schema

| Property | Value |
|---|---|
| **Measurement** | `smartplug` |
| **Fields** | `apower` (float, W), `total` (float, Wh), `tF` (float, °F) |
| **Tags** | `device` (e.g. `Shelly_Prod`), `room` (e.g. `office`) |

`total` is stored as the raw cumulative counter. Grafana computes energy consumed over a time window using `non_negative_difference(last("total"))`.

---

## 5. Node-RED Flow

Flow file: `flows/shelly-prod.json`

Three MQTT-in nodes subscribe to the three selected topics. Each feeds a function node that parses the float payload, sets `msg.measurement = 'smartplug'`, and formats `msg.payload` as `[{field: value}, {device, room}]` for the InfluxDB out node.

The config nodes (`broker-vultr2`, `cfg-influxdb`) are shared with the sensor temperature flow.

---

## 6. Grafana Dashboard

Dashboard: **I40 Demo 1** (to be renamed I40 Demo)

| Panel | Query | Unit |
|---|---|---|
| Office-Prod Power Draw (W) | `SELECT mean("apower") FROM "smartplug" WHERE $timeFilter GROUP BY time($__interval) fill(none)` | Watts (W) |
| Energy Consumption (Wh/hr) | `SELECT non_negative_difference(last("total")) FROM "smartplug" WHERE $timeFilter GROUP BY time(1h)` | Watt-hour (Wh) |
| Plug Temperature (°F) | `SELECT mean("tF") FROM "smartplug" WHERE $timeFilter GROUP BY time($__interval) fill(none)` | Fahrenheit (°F) |

---

## 7. Known Devices

| Device name | Room | MQTT topic prefix | Status |
|---|---|---|---|
| `Shelly_Prod` | office | `KTBMES/TWIX/office/smartplugs/Shelly_Prod` | Wired ✓ |
| `Shelly_Lab_01` | lab | `KTBMES/TWIX/.../smartplugs/Shelly_Lab_01` | Not yet wired |

---

## 8. What Remains

- Wire up additional smartplugs (Shelly_Lab_01 and others) using same flow pattern
- Rename Grafana dashboard from "I40 Demo 1" to "I40 Demo"
- Consider adding `voltage` panel if mains voltage monitoring is useful for the demo narrative
