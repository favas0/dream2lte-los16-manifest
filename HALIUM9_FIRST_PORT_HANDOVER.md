# Halium 9 First-Port Handover

Use this as the starting brief for a fresh chat or a fresh project focused on the first Halium 9 bring-up for `dream2lte`.

## Repo Model

Start Halium work as a branch in the existing manifest repo, not as a separate top-level project yet.

Recommended approach:

- keep `main` as the known-good LOS16 baseline
- create `halium-9-first-port` as the Halium bring-up branch
- split into a separate Halium manifest repo later only if the manifest, patch flow, or maintenance model diverges significantly

Why this is the right first step:

- it keeps Halium work directly diffable against the working LOS16 state
- it avoids duplicating the manifest and Docker setup too early
- it makes rollback and regression tracking much easier during bring-up

## Paste-Ready Prompt

```text
I want to start the first Halium 9 port for Samsung Galaxy S8+ `dream2lte`, using this published manifest repo as the source baseline:

https://github.com/favas0/dream2lte-los16-manifest

Please treat that repo's `main` branch as the known-good LineageOS 16 baseline, and create a new working branch for the Halium effort:

halium-9-first-port

Important background:
- The LOS16 baseline boots and works.
- Signal bars were fixed in framework telephony by bridging Samsung radio 1.2 callbacks.
- The working source state is represented by the manifest repo and patch set, not by random local workspace edits.
- Do not reintroduce the failed `librilutils` / `libreference-ril` swap experiment.
- The remaining Samsung `secbridge` noise is considered non-fatal for now.

Known-good LOS16 build:
- lineage-16.0-20260407-UNOFFICIAL-dream2lte.zip
- SHA-256: 9cbf48c4bcd2c7ae939d211c309b6b0f379368802de1508e6e11f6a78a57c145

Repos that will likely need Halium work:
- device/samsung/dream2lte
- device/samsung/universal8895-common
- kernel/samsung/universal8895
- vendor/samsung/dream2lte
- vendor/samsung/universal8895-common

Kernel facts:
- device/samsung/dream2lte/BoardConfig.mk uses:
  TARGET_KERNEL_CONFIG := exynos8895-dream2lte_defconfig
- kernel defconfig path:
  kernel/samsung/universal8895/arch/arm64/configs/exynos8895-dream2lte_defconfig

Halium-specific priority:
- We need the kernel adjusted so LXC containers can run.
- Please audit and plan for namespaces, cgroups, container networking, devpts/mount requirements, and any other kernel features Halium/LXC expects on Android 9.
- Keep changes incremental and boot-testable.

What I want first:
1. Clone/sync from the manifest repo baseline.
2. Create/publish the `halium-9-first-port` manifest branch in the existing manifest repo.
3. Prepare a clean Halium bring-up branch strategy for the touched Android subrepos.
4. Review the kernel and identify the minimum LXC-related config changes needed in `exynos8895-dream2lte_defconfig`.
5. Start the first implementation pass without disturbing the known-good LOS16 baseline.
```

## Recommended Branch Strategy

Use `main` in the manifest repo as the LOS16 baseline.

Do not create a separate Halium manifest repo for the first pass unless there is already a strong reason to fork the project structure itself.

Create:

```bash
git checkout -b halium-9-first-port
git push -u origin halium-9-first-port
```

In the synced Android workspace, keep per-project topic branches instead of mixing all Halium work into one dirty tree.

Suggested first branches:

```text
device/samsung/dream2lte                  -> halium9/dream2lte-bringup
device/samsung/universal8895-common      -> halium9/universal8895-common-bringup
kernel/samsung/universal8895             -> halium9/lxc-kernel
vendor/samsung/dream2lte                 -> halium9/dream2lte-vendor
vendor/samsung/universal8895-common      -> halium9/universal8895-vendor
```

## Bootstrap Commands

If the new branch already exists in GitHub:

```bash
mkdir -p ~/android/halium9-dream2lte
cd ~/android/halium9-dream2lte
repo init -u https://github.com/favas0/dream2lte-los16-manifest.git -b halium-9-first-port
repo sync -c --no-clone-bundle --no-tags -j1
bash manifest-support/scripts/bootstrap-workspace.sh
repo sync -c --no-clone-bundle --no-tags -j"$(nproc)"
bash manifest-support/scripts/apply-patches.sh
```

After that, create the per-project branches inside the synced workspace before starting Halium changes.

## Kernel Focus For LXC

The first kernel target is:

`kernel/samsung/universal8895/arch/arm64/configs/exynos8895-dream2lte_defconfig`

The first audit should check at least:

- namespace support: `CONFIG_NAMESPACES`, `UTS_NS`, `IPC_NS`, `PID_NS`, `NET_NS`
- cgroups: `CONFIG_CGROUPS` and the controllers Halium/LXC will need
- container filesystems: `CGROUP_FS`, `TMPFS`, `DEVTMPFS`, `DEVPTS_MULTIPLE_INSTANCES`, `OVERLAY_FS`
- container networking: `VETH`, `BRIDGE`, `BRIDGE_NETFILTER`, `MACVLAN` if needed
- security/process features: `SECCOMP`, `SECCOMP_FILTER`, `CHECKPOINT_RESTORE` if relevant
- Android compatibility pieces already used by LOS16 should be preserved

Do not assume every desktop-LXC option is required for the first boot. Prefer the minimum set that gets Halium containers running while keeping the device bootable.

## Constraints

- Keep the Samsung signal-bars fix.
- Keep the ClearKey build fix.
- Do not revert to the failed radio-library swap experiment.
- Treat `main` in the manifest repo as the stable LOS16 source baseline.
- Keep Halium work isolated on new branches.

## Success Criteria For The First Halium Pass

- manifest branch exists and reproduces the LOS16 baseline plus Halium work
- kernel branch carries the first LXC-related config changes cleanly
- Android workspace remains buildable from Docker
- no accidental regression to the known-good LOS16 radio baseline
