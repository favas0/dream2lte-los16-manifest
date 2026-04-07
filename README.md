# dream2lte LOS16 Manifest

This repository is a reproducible meta-source for the working LineageOS 16 `dream2lte` tree.

It is meant to be used as the manifest source for `repo init`, then synced into the workspace as `manifest-support/` so the pinned manifest snapshot, local patches, and Docker build tooling are available in-tree.

## What It Captures

- Bootstrap manifest plus compressed pinned `repo` manifest snapshot for the working LOS16 source state
- Samsung signal-bars fix in framework telephony
- ClearKey DRM build fix
- Docker build environment used for the successful full ROM build
- Small local source patches needed to preserve the current known-good state

## Known-Good Build

- Artifact: `lineage-16.0-20260407-UNOFFICIAL-dream2lte.zip`
- SHA-256: `9cbf48c4bcd2c7ae939d211c309b6b0f379368802de1508e6e11f6a78a57c145`

## Quick Start

```bash
mkdir -p ~/android/dream2lte-los16
cd ~/android/dream2lte-los16
repo init -u https://github.com/favas0/dream2lte-los16-manifest.git -b main
repo sync -c --no-clone-bundle --no-tags -j1
bash manifest-support/scripts/bootstrap-workspace.sh
repo sync -c --no-clone-bundle --no-tags -j"$(nproc)"
bash manifest-support/scripts/apply-patches.sh
docker build -t lineage16-buildenv:latest -f manifest-support/docker/Dockerfile manifest-support/docker
bash manifest-support/scripts/build-docker.sh
```

`manifest-support/scripts/build-docker.sh` defaults to `JOBS=20`. Override `JOBS` explicitly only when you want a different parallelism level.

## Patch Contents

- `frameworks/opt/telephony`: Samsung vendor radio callback bridge that restores signal bars
- `frameworks/av`: ClearKey compile fix already known to be required
- `build/make`, `external/clang`: Python compatibility helpers preserved from the working tree
- `vendor/samsung/universal8895-common`: keep stock `librilutils` / `libreference-ril` packaging instead of the failed radio-swap experiment
- `device/samsung/universal8895-common`: quiet non-fatal Samsung `RILC` log spam by default

## Notes

- This repo intentionally does not ship `.repo`, build outputs, or host-only symlink hacks.
- The root `default.xml` is a bootstrap manifest. `scripts/bootstrap-workspace.sh` expands the pinned compressed snapshot into `.repo/manifests/default.xml` before the real source sync.
- The remaining Samsung `secbridge` noise is treated as non-fatal. The functional radio fix is the telephony callback bridge.
- The host build experiments created extra compatibility changes; the Docker path is the preferred build path.
