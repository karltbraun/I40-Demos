# Perplexity Conversation

## Answers to specific questions

### A - Scope and naming of the umbrella

A1: I40-Demos is for demos - not for client-sponsored projects. But this doesn't mean throw-away. May be used and will be built on to demonstrate various aspects for Industry 4.0 (I40) technology, techniques, value-propositions, etc. We will borrow (copy?) from this to initiate formal customer-oriented projects.

A2: I want to treat all of these related demos as part of a large VSCode workspace, where we have all of these containers managed under one Repo, adding additional folders when we come up with additional stacks or containers to add to the overall collection. This will utlimately result in us re-working our github repositories and some existing VSCode workspaces or project folders. To be clear, I want a folder named "I40-Demos" and under that would be "I40-stack", "I40-LineFeedSimulator", etc. I'm willing to look at your recommendation (a) - a plain parent directory - but I want to understand the benefits and problems associated with these two designs.

### B - What goes in the core stack vs. what leaves it

B: Clarification for the stack. We want to spin up the core stack, and have these services - all of them - available for any additional demo work we want to produce. We don't want a separate Ignition, MQTT, Node Red, Telegraf, or Grafana instance for each feeder / demo.

B1: Ignition will go in the core stack, because eventually it will have a similar functionality to the Mosquitto MQTT broker - it will hold the tag namespace. In some Ignition projects it will consume from the MQTT broker and reproduce that namespace in the Ignition tag structure. In other Ignition projects, it will consume raw information from either devices or other simulartors feeding OPC/UA information (or simulated modbus, etc.) to the broker and subsequent tag namespace, then publishing that tag data to an MQTT broker. This demonstrates how Ignition can both produce information to the MQTT broker (to be consumed by other processes) or consume from the MQTT broker to produce localized dashboards within Ignition.

B2: Node-Red will also be part of the stack for similar reasons as ignition. It can both consume/transform and then produce new information for other consumers (like InfluxDB); likewise it can produce information like a simulator and publish to either/both Ignition and the MQTT broker.

### C - The "producer stack" boundary

C: Understanding this requires an understanding of how some of these 'feeder' or 'producer' modules work. See "Temperature Sensor Work Flow" and "Shelly Smartplug Work Flow" below. Bascially the core stack are utilities which might be common to multiple specific demos - I think of them as utiliies, although Ignition can have a functionality as producer, consumer, and visualization platform. We will probably add other things to this stack, or we may pull Ignition and combine them with other like platforms for separate use.

C1: Where does the Shelly Python republisher live - see "Shelly Smartplug Work Flow", below.

C2: What defines a "producer stack"?

These will be components which actually consume and report on data from edge devices or simulate such behavior. We have the LineFeedSimulator simulating the management and monitoring of a line feed conveyor, which normally would be feeding something like Ignition via OPC/UA from the motor controller or some other platform which can communicate with a device controller (or PLC) and produce data with minimal modification (as close to raw edge data as possible).

C3: Who owns the topic-tree contract?

Short answer: I do. This is a good idea, but let's defer this until we have our folder tree defined (because that information will go in an as yet not defined folder.

### D - Deployment and image strategy

D1: I'm not very familiar at all with ghcr - this is the first time I've used it. Given your description under "Today:", I would say we want ghcr.io/karltbraun/Iro/I40-nodered, etc. But I'm open to suggestions.

D2: Having the core running is a prerequisit for consumers to run.

- Or, more specifically, specific parts of the core running:
  - No one is dependent on Ignition at the moment.
  - But everyone (at the moment) is expecting the MQTT broker to be running.

So you _could_ start each of these containers separately, but generally you want them all running.

D3: networking across stacks.

We want the flexibility for producers to publish to the MQTT broker or Ignition platform on the local-to-the-producer or to an MQTT borker (or Ignition platform) running on another server. For example, we might run the Line Feed Simulator locally, but publish to an MQTT Broker running in a container on our Vultr server. We might be consuming information from that MQTT Broker (or Ignition platform) from a 3rd system for visualization. I want to demonstrate that kind of flexibility.

### E - Visulations

Right now, visualization is in the core stack. This may change as we have different visualization tools. These all run in their own containers, so the idea of "producer, core, and visualzation" stacks is a little bit fluid. I imagine we will move things around a bit as we get more experience and add to the overall collection of tools and demos.

### F - Minor but worth pinning down

F1: We will want all of these related demos to begin with "I40-". that will be part of our modifications in this project.

F2 "Temp Sensor" scope: we will probably roll this in in some fashion, but the temperature sensors and Shelly Smartplugs started as personal projects to determine energy consumption and environmental conditions around my property. But they have obvious value as a demo for how to use MQTT, Node Red, and Grafana (even Ignition) to consume and visualize data from edge devices. So while I intend to containerize these producer nodes, they will most likely not have the I40 prefix or be part of this specific project.

F3 Shared code / shared configs: At the moment, I don't see any specific action here.

## Work Flows

### Temperature Sensor Work Flow

Temperature (and other sensors in this project) transmit their current sensor data over 433MHz unlicensed radio spectrum (US spectrum allocations).

We have a Raspberry Pi (Pi1) with an attached dongle and antenna facilitating Software Defined Radio (SDR) protocols and analog-to-digital transformations for 433MHz radio signals received. RTL_433 knows how to read and translate these signals and make them available for further processing. We configure RTL_433 to transmit this data to an MQTT broker. The RTL_433 software takes an MQTT topic prefix (in this case, "Pi1/sensors/raw", append the device ID for the sensor (in the device data transmission packet), and then the specific device attribute, to the topic, and then transmitting the timestamp and attribute value. So you would have, for instance, topics and values that look like this in the MQTT Broker:

- Pi1/sensors/raw/152/temperature_F: 60.8
- Pi1/sensors/raw/152/humidity: 73
- Pi1/sensors/raw/152/battery_ok: 1
- Pi1/sensors/raw/152/id: 152

The RTL software is running continuously on the Pi1 Raspberry Pi.

On another machine (Twix - a lenovo laptop running Ubuntu), we have a python script which:

- Subscribes to the topic "Pi1/sensors/raw/#" so it gets all of the sensor and attribute topics and updated values.
- Collects attributes and values associated with a particular device id (152 in the example above) in an internal database (python dictionary, actually)
- This collection of scripts has a json file which maps device names (device_name) to device ids (device_id) so we have human-friendly ways to reference the sensor.
- Periodically this python code on Twix will publish the data associated with each device (by device_name) to a different MQTT namespace (same broker), e.g.:
  - KTBMES/TWIX/sensors/house_weather_sensors/DECK: {"device_id": "152", "device_name": "DECK", "protocol_id": "91", "protocol_name": "Multiple Temp & Humidty\*SC91", "protocol_description": "inFactory, nor-tec, FreeTec NC-3982-913 temperature humidity sensor", "temperature_C": 1.6, "temperature_F": "60.9", "humidity": 73.0, "battery_ok": "1", "channel": "2", "rssi": -999.0, "snr": -999.0, "noise": -999.0, "freq": -999.0, "mic": "CRC", "mod": "NO_MOD", "time": "2026-04-21 15:45:45", "time_last_seen_ts": 1776811550.719577, "time_last_seen_iso": "2026-04-21T15:45:50.719577", "time_last_published_ts": 1776811550.72026, "time_last_published_iso": "2026-04-21T15:45:50.720260", "button": "0", "status": "3", "transmit": "AUTO", "moisture": "0"}

Consumers can consume data from the P1 namespace or from the KTBMES namespace as best suits their application.

### Shelly Smartplug Work Flow

The Shelly smatplugs can be configured to transmit their information to an MQTT broker. Like above, we provide a topic prefix, and shelly transmits the data according to its own internal logic. The Shelly topic tree has "Shelly" at the topic root, followed by the "room" in which the sensor lives. This follows the concept of the ISA-95 namespace definition of Enterprise/Site/Area/Line/Cell: "Shelly" is the Enterprise, {"Shelly_EV", "Shelly_Lab_01", and "Shelly_Prod""} are the sites. Everything else below that are areas of the sensor and specific attributes. So, for instance Shelly_EV is the smart plug into which my plug-in hybrid vehicle charger is connected, and SHelly_Lab_01 is one of the smartplugs in my computer lab area. Shelly publishes this in a sparkplug-like format, which makes it a little more unsuitable for graphing a specific attribute value. So we have another python script, also running on Twix, which consumes the information published by the Shelly smartplugs reformats that data, and republishes it under the KTBMES namespace:

- KTBMES/TWIX/office/smartplugs/Shelly_Lab_01/switch:0/apower: 14.6
- KTBMES/TWIX/office/smartplugs/Shelly_Lab_01/switch:0/current: 0.158
  etc.

Consumers can consume data from the KTBMES namespace or Shelly namespace as they deem best, and process the information for visulation or further transformation.
