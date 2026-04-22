"""
MQTT topic definitions for the LineFeed Simulator.

Defines the ISA-95-structured topic tree rooted at the NewCo/Soledad facility.
All simulator metrics are published under these topics so downstream consumers
(Telegraf, Node-RED, Grafana) can subscribe to a consistent namespace.
"""
LINE = "NewCo/Soledad/RawProductDump/Line1"
CELL = f"{LINE}/CutterFeed"

TOPICS: dict[str, str] = {
    # Line-level
    "state":            f"{LINE}/State",
    "state_label":      f"{LINE}/StateLabel",
    "sku":              f"{LINE}/SKU",
    "availability":     f"{LINE}/OEE/Availability",
    "downtime_total":   f"{LINE}/Downtime/TotalSeconds",
    "downtime_events":  f"{LINE}/Downtime/EventCount",
    # Cell-level
    "speed_current":    f"{CELL}/LineSpeed/Current",
    "speed_set":        f"{CELL}/LineSpeed/Set",
    "speed_recommended":f"{CELL}/LineSpeed/Recommended",
    "speed_delta":      f"{CELL}/LineSpeed/Delta",
    "speed_delta_pct":  f"{CELL}/LineSpeed/DeltaPct",
    "speed_avg_1min":   f"{CELL}/LineSpeed/Avg1Min",
    "speed_avg_5min":   f"{CELL}/LineSpeed/Avg5Min",
    "speed_avg_run":    f"{CELL}/LineSpeed/AvgRun",
}
