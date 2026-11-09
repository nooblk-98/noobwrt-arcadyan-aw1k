# Firmware definitions

Each `devices/arcadyan-aw1000/variants/<variant>/firmware.json` is its variant’s canonical build recipe. Package selection is `packages.json`; additional configuration is `kconfig`; router defaults are under `files/`; reviewed device policy is in `hooks/`. Edit these files here, not in the builder.

The source and all feeds are locked to full commits. The Go toolchain override and PassWall2 override also use immutable commits; Xray and Tailscale source versions have SHA-256 pins in the device hook. Host compiler/container dependencies and package downloads are not claimed bit-reproducible. The selected OpenWrt baseline is v25.12.5, matching the previous GitHub workflow default.

## Migration baseline

PassWall2: all 48 overlay files are copied byte-for-byte with original modes from builder commit `8bd5548270418c7d8fa93e2a0cdd73bcadfe1634`. PassWall1: all 49 files are preserved from `5316950f953eb7a3ee46b46efd059e30403585ff`, including its PassWall defaults and fragment fix. `overlay-baseline.json` proves initial migration parity. It is a historical baseline, not a restriction against future firmware changes; this repository has no migration test suite. The original src/compile.conf, src/packages.conf and release template are retained as migration reference; they are not sourced by the new engine. Active settings are the JSON manifest, packages.json, kconfig and hooks.

## Modem stack

Both variants use ModemManager with QMI, MBIM and AT-over-D-Bus support. QModem,
its vendor QMI driver and its TTL/voice packages are not selected. The
`mm-uplink` init script waits for the USB modem and brings the `mmwan` netifd
interface up once after ModemManager starts; `5gmodem` sessionwatch handles
ongoing reconnect. Modem metrics, carrier aggregation,
SMS/USSD/AT and band control are provided by `luci-app-5gmodem`. `kmod-usb-acm` and
`kmod-usb-serial-qualcomm` are selected to satisfy the 5G Modem package modem-port
support.

## RJ11 / FXS

`luci-app-fxs` is selected from noobwrt-custom-feeds; its dependencies supply `fxsd` and `kmod-aw1000-fxs`. No legacy aw1000-rj11 submodule or second driver implementation is used. The feed currently does not ship the private ProSLIC DSP patch. The device overlay hook converts a locally supplied `si3226x_stock_tables.h` from `RJ11_PRIVATE_DIR` (default `/private`) to the firmware runtime file `/etc/fxs/si3226x_patch.bin`. Missing private input fails explicitly rather than silently dropping phone support.

Never commit the private header or generated patch to this repository. Mount the private directory read-only for official builds. Output artifacts contain firmware images and metadata, not headers or source trees. Firmware images with phone support necessarily contain the runtime DSP patch; confirm redistribution rights before publishing those images. A public no-phone variant should be an explicit reviewed definition omitting luci-app-fxs and the private-data hook, not an environment-dependent silent fallback.

## Adding another router

Add a device/variant descriptor with its real OpenWrt target/subtarget/profile, compatible packages, locked sources and necessary defaults. Avoid copying AW1000 hooks into unrelated routers. The builder discovers output images from profiles.json, not AW1000-specific filenames. Only reviewed approved commits should execute on the self-hosted runner; PRs do not automatically execute tests or device hooks.

## Supported AW1000 variants

- `passwall1`: luci-app-passwall 26.1.1-1 (commit `0d24d8fc24d9eb508a4df599a0a4d673c8a35cc7`), Xray-core 25.12.8 with the original SHA-256 pin. No PassWall2 Go or Tailscale override is applied.
- `passwall2`: luci-app-passwall2 26.9.16-1, Xray-core 26.9.9 and its existing Go/Tailscale overrides.

Both use locked OpenWrt v25.12.5 and feed revisions, retain their complete package baseline (with ModemManager replacing QModem) plus feed-provided FXS, and keep separate overlays and device hooks. Definition validation is not a full compile or hardware flash test.
