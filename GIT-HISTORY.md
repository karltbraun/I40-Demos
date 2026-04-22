# Pre-Monorepo Git History

This document preserves the commit history from the three standalone repos that were consolidated into the `I40-Demos` monorepo. The original repos remain available at their prior paths for full `git log`/`git blame` access.

Consolidation date: **2026-04-22**

---

## I40-Stack

**Summary:** Built from scratch over 2026-04-12 to 2026-04-19. Started as a MING + Ignition + Telegraf stack, quickly evolved to support multi-platform deployment (m3/x86_64/cloud). Key milestones: switched from Docker Hub to GHCR, added per-service build-and-push scripts, wired in Telegraf + InfluxDB 3 for the LineFeed Simulator, added Grafana dashboards for both line feed and smart plugs, extracted SmartPlugs artifacts to their own repo, and consolidated cloud/x86_64 compose files into a single x86_64.yml.

| Hash | Date | Message |
|------|------|---------|
| `9d0be2b` | 2026-04-19 | Add Shelly_Prod flow configuration for InfluxDB integration |
| `6db78a0` | 2026-04-19 | Add Shelly_Prod configuration for InfluxDB integration |
| `96b8e22` | 2026-04-19 | Remove cloud.yml — x86_64.yml now covers all x86_64 hosts (Mac + cloud) |
| `a499132` | 2026-04-19 | Add mosquitto to cloud compose; remove deprecated mosquitto-basic dependency |
| `bacc866` | 2026-04-18 | Remove cloud.yml from platform table; x86_64.yml covers Linux |
| `8bb57b1` | 2026-04-18 | Use x86_64 compose on Linux; add MOSQUITTO_IMAGE preflight check |
| `872b6df` | 2026-04-17 | Add SmartPlugs Grafana dashboard (power, energy, temperature) |
| `571869f` | 2026-04-17 | Add README; fix DEPLOYMENT.md start script name; fix I40-Demo path ref; remove REORGANIZATION.md |
| `832537f` | 2026-04-17 | Rename start-smartplug-demo → start-I40-stack; remove stale image checks |
| `cf73f0e` | 2026-04-17 | Remove SmartPlug artifacts (moved to I40-SmartPlugs) |
| `c24e99b` | 2026-04-17 | Rename start → start-smartplug-demo for clarity |
| `771def7` | 2026-04-17 | Remove mosquitto from cloud stack; use external mosquitto-basic container |
| `30cd3c5` | 2026-04-17 | Change Current speed series color to yellow in Line Speed History |
| `d78a1f7` | 2026-04-17 | Add Set Speed to Line Speed History chart and stat panels |
| `70b50c4` | 2026-04-16 | Fix Grafana crash: remove hardcoded datasource uid, use template variable |
| `463945e` | 2026-04-16 | Add LineFeed Simulator support: Telegraf subscription, Grafana dashboard |
| `1dbfa29` | 2026-04-15 | Update requirements docs: sensors v0.3, smartplugs v0.1 full draft |
| `31fcae0` | 2026-04-15 | Add Shelly smartplug pipeline and Session 3 notes |
| `8ca8afd` | 2026-04-15 | Rename requirements.md → requirements-sensors.md; update session notes |
| `edfcd38` | 2026-04-15 | Add Node-RED flow and watch-temperature script; update gitignore |
| `5215c9d` | 2026-04-14 | test-influxdb: suppress deprecated LOG_FILTER warnings from CLI |
| `f45642b` | 2026-04-14 | Add scripts/test-influxdb hello-world test script |
| `d63dffb` | 2026-04-14 | InfluxDB: disable auth for demo stack (--without-auth) |
| `6d8fa36` | 2026-04-14 | Fix InfluxDB 3.9.0 startup: --node-id arg and healthcheck |
| `71add57` | 2026-04-14 | Cleanup: healthchecks, flows mount, Telegraf pin, remove pull-and-start |
| `97131db` | 2026-04-14 | Switch to pull-only deployment: all services via GHCR images |
| `d2564b8` | 2026-04-13 | Add session notes and pending rework items |
| `e64ee81` | 2026-04-13 | requirements: close resolved open items |
| `6868c4d` | 2026-04-13 | Switch registry from Docker Hub to GHCR (ghcr.io/karltbraun) |
| `e414414` | 2026-04-13 | requirements: incorporate answers, clean up to v0.2 |
| `daf3f10` | 2026-04-13 | Add draft requirements document |
| `d3283f5` | 2026-04-12 | Initial I40 Demo stack — MING + Ignition + Telegraf |

---

## I40-LineFeedSimulator

**Summary:** Built over 2026-04-16 to 2026-04-18. Started with project setup and requirements brainstorm, then built the full simulator core in one commit (all modules: config, mes, production, scheduler, speed_tracker, state, topics, mqtt_publisher). Key evolution: switched to python-dotenv for config, replaced biased random walk with a mean-reverting speed model, added operator Set Speed topic, built the `start-lfs` helper script with platform auto-detection and I40-Stack dependency check, and cleaned up docs/brainstorm artifacts.

| Hash | Date | Message |
|------|------|---------|
| `c6e0f1c` | 2026-04-18 | Use x86_64 compose on Linux (full stack with i40-mosquitto) |
| `d0574eb` | 2026-04-17 | Update README: fix I40-Demo refs, lead with start-lfs, remove brainstorm/next-steps |
| `1fa2183` | 2026-04-17 | Add i40-mosquitto to container health check in start-lfs |
| `8aefdca` | 2026-04-17 | Remove workspace file (moved to KTBCS root) |
| `970a6a3` | 2026-04-17 | Add I40-Demos workspace file pointing to LineFeedSimulator and I40-Stack |
| `fd050da` | 2026-04-17 | Update stack path: I40-Demo → I40-Stack |
| `e5cb9cf` | 2026-04-17 | Fix start-lfs path resolution; reformat README tables |
| `5e11ddc` | 2026-04-17 | Fix start-lfs: auto-select compose file by platform, remove mosquitto, launch simulator |
| `14136da` | 2026-04-17 | Rename start-stack → start-lfs for clarity |
| `f5bc321` | 2026-04-17 | Use python-dotenv for env config; default MQTT broker to localhost |
| `ec4e27d` | 2026-04-17 | Allow MQTT_HOST and MQTT_PORT env vars to override config.toml |
| `7bacfc0` | 2026-04-17 | Add Set Speed topic and publish operator setpoint each tick |
| `819ed2f` | 2026-04-17 | Replace biased random walk with mean-reverting speed model |
| `2b48ec2` | 2026-04-17 | Clear NEXT_STEPS.md — requirements moved to project memory |
| `51118c5` | 2026-04-17 | Add NEXT_STEPS notes and start-stack helper script |
| `1081106` | 2026-04-16 | Fix InfluxDB int/float conflict, add --loop flag, and README |
| `08ec187` | 2026-04-16 | Add simulator core: all components, config, and entry point |
| `d3669b4` | 2026-04-16 | Initial project setup: uv environment, core dependencies, requirements |

---

## I40-SmartPlugs

**Summary:** Extracted from I40-Stack on 2026-04-17 with a clean initial commit containing all flows and scripts. One follow-up commit to fix the README's reference to the I40-Stack start script.

| Hash | Date | Message |
|------|------|---------|
| `65a732a` | 2026-04-17 | Fix I40-Stack start command in Prerequisites (use start-I40-stack script) |
| `1ff4096` | 2026-04-17 | Initial commit: SmartPlugs flows and scripts |

---

## Notes

- `Container_Mosquitto/` had no git repo — no history to preserve.
- `I40-VirtualFatory/` had no git commits — no history to preserve.
- The `CRW/` repo is unrelated to this project and was not included.
