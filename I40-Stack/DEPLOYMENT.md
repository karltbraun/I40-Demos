# I40 Demo Deployment Flow (Build Once, Pull Everywhere)

This project uses a pull-only startup flow on target machines. Images are built
once (on a build workstation) and pushed to GHCR; target machines only pull and run.

---

## Prerequisites: GHCR Authentication

Before building or pulling images, authenticate Docker with GitHub Container Registry:

```bash
# Generate a GitHub Personal Access Token (PAT) at:
# https://github.com/settings/tokens
# Required scopes: write:packages, read:packages, delete:packages
#
# Then log in:
echo YOUR_GITHUB_PAT | docker login ghcr.io -u karltbraun --password-stdin
```

You only need to do this once per machine. Docker stores the credentials securely.

---

## 1. Build and publish images

Run from this repo on your build workstation. Scripts default to `ghcr.io/karltbraun`
and auto-generate a tag from today's date and the current git commit.

```bash
./scripts/build-and-push-nodered
./scripts/build-and-push-ignition
./scripts/build-and-push-influxdb
./scripts/build-and-push-mosquitto
./scripts/build-and-push-grafana
```

Each script prints the full image reference on completion, e.g.:

```
Published: ghcr.io/karltbraun/i40-nodered:2026-04-13.e414414
Next step: set NODE_RED_IMAGE=ghcr.io/karltbraun/i40-nodered:2026-04-13.e414414 in .env
```

**Override defaults** (registry, image name, or tag) with flags:

```bash
./scripts/build-and-push-nodered --registry ghcr.io/karltbraun --image i40-nodered --tag 2026-04-13.e414414
```

Default values:

| Script | Default registry | Default image |
|--------|-----------------|---------------|
| build-and-push-nodered | `ghcr.io/karltbraun` | `i40-nodered` |
| build-and-push-ignition | `ghcr.io/karltbraun` | `i40-ignition` |
| build-and-push-influxdb | `ghcr.io/karltbraun` | `i40-influxdb` |
| build-and-push-mosquitto | `ghcr.io/karltbraun` | `i40-mosquitto` |
| build-and-push-grafana | `ghcr.io/karltbraun` | `i40-grafana` |

Default tag: `YYYY-MM-DD.<git-short-commit>`

Each build pushes a **multi-architecture manifest** covering `linux/amd64` and `linux/arm64`.

> **Important:** The `i40-ignition` image embeds Cirrus Link modules.
> Ensure the GHCR package visibility is set to **private** after the first push.

---

## 2. Configure each target machine

```bash
cp .env.template .env
```

Edit `.env` and set the image references published in step 1:

```
NODE_RED_IMAGE=ghcr.io/karltbraun/i40-nodered:2026-04-13.e414414
IGNITION_IMAGE=ghcr.io/karltbraun/i40-ignition:2026-04-13.e414414
INFLUXDB_IMAGE=ghcr.io/karltbraun/i40-influxdb:2026-04-13.e414414
MOSQUITTO_IMAGE=ghcr.io/karltbraun/i40-mosquitto:2026-04-13.e414414
GRAFANA_IMAGE=ghcr.io/karltbraun/i40-grafana:2026-04-13.e414414
```

Also set the Ignition admin password secret:

```bash
echo "your-password" > secrets/IGNITION_ADMIN_PASSWORD
```

Authenticate Docker with GHCR (same as above — required to pull private images):

```bash
echo YOUR_GITHUB_PAT | docker login ghcr.io -u karltbraun --password-stdin
```

---

## 3. Start the stack

```bash
./start-I40-stack
```

The startup script will:
1. Verify `.env` and `secrets/IGNITION_ADMIN_PASSWORD` exist
2. Verify all image variables are set in `.env`
3. Auto-detect platform (ARM64 / x86_64 / cloud)
4. Pull all images from GHCR
5. Start all containers

---

## Notes

- No local image builds occur on target machines — pull only
- Keep image tags immutable; never re-push a different image to the same tag
- The Ignition trial license runs 2-hour sessions; restart the container to reset:
  `docker restart i40-ignition`
