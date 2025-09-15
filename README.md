<div align="center">

# NoobWRT for Arcadyan AW1000

High‑performance ImmortalWRT/OpenWrt firmware for the Arcadyan AW1000.

[![Release](https://img.shields.io/github/v/release/nooblk-98/arcadyan-aw1000-mod-firmware?sort=semver)](https://github.com/nooblk-98/arcadyan-aw1000-mod-firmware/releases)
![Target](https://img.shields.io/badge/target-Arcadyan%20AW1000-blue)
![Base](https://img.shields.io/badge/base-ImmortalWRT%20%2F%20OpenWrt-green)
![Kernel](https://img.shields.io/badge/kernel-6.6.100-success)
![Status](https://img.shields.io/badge/status-stable-brightgreen)

[Buy Now](https://wa.me/94716172860) · [Setup Video](https://youtu.be/6eYihpGg7Sw)

![NoobWRT Dashboard](/images/main.png)

</div>

## Overview

NoobWRT transforms the AW1000 into a fast, secure, customizable router. It’s tuned for stability and performance, with a curated app set and sensible defaults.

## Table of Contents

- Quick Start
- What’s New
- Features
- Screenshots
- Specifications
- Packages
- Indicators & Defaults
- FAQ
- Support & Pricing

## Quick Start

Flash safely in minutes via SSH.

```bash
wget -qO /tmp/flash https://raw.githubusercontent.com/nooblk-98/arcadyan-aw1000-mod-firmware/main/flash/flash && chmod +x /tmp/flash && /tmp/flash
```

Recovery from stock (U‑Boot):
- Connect PC to yellow LAN, set static IP `192.168.1.2/24`.
- Hold reset, power on, keep holding ~8–10 s to enter recovery.
- Open `http://192.168.1.254`, upload factory `.ubi`, wait 2–3 minutes.
- SSH to `192.168.1.1` and run the installer command above.

## What’s New

- Fixed 5G LED indicator behavior.
- Updated all packages to latest versions.
- Removed PassWall.
- Added HomeProxy (recommended replacement; migrate any PassWall configs).

## Features

- Performance: wire‑speed routing, low latency, hardware flow offloading.
- Security: firewall hardening, ready for WireGuard/OpenVPN, frequent updates.
- Apps: curated LuCI apps, Adblock, USB tools, diagnostics, and more.
- Reliability: based on ImmortalWRT for long‑term stability and updates.

## Screenshots

![Dashboard (Pro)](/images/full-dash.png)

![Dashboard (Light)](/images/dash-full-white.png)

## Specifications

- Device: Arcadyan AW1000 (qualcommax/ipq807x)
- Version: NoobWRT 24.10.1
- Kernel: 6.6.100
- CPU: 1.4 GHz Quad‑Core
- RAM: 1 GB DDR4
- Storage: 256 MB NAND

Example device stats:

```
Memory (Total/Used/Cached): 866.07 MiB / 343.31 MiB / 142.20 MiB
Storage (Disk/Temp):        562.95 MiB / 433.04 MiB
```

## Packages

Popular packages preloaded to enhance your router out‑of‑the‑box.

<details>
<summary>Show package list</summary>

adblock, aria2, aria2-openssl, ariang, attr, avahi-dbus-daemon, bash, bc, blkid, bzip2, chat, chinadns-ng,
collectd, collectd-mod-cpu, collectd-mod-interface, collectd-mod-iwinfo, collectd-mod-load, collectd-mod-memory,
collectd-mod-network, collectd-mod-rrdtool, comgt, coreutils, coreutils-base64, coreutils-nohup, coreutils-sort,
coreutils-stat, curl, dbus, ddns-scripts, ddns-scripts-services

... and many more (264+ packages total).

</details>

## Indicators & Defaults

- Power light: device is powered and ready
- 5G indicator: shows 5G mobile connection status
- Internet status: confirms active internet connection
- Signal strength: cellular signal quality level
- New SMS: unread SMS on the SIM

Defaults:
- Wi‑Fi SSIDs: "NoobWRT 2GHz" and "NoobWRT 5GHz"
- Wi‑Fi password: `123456789`
- Admin login: user `root`, no password set

Change the admin password on first login.

## FAQ

- What is NoobWRT?
  - A performance‑tuned ImmortalWRT/OpenWrt build for the AW1000 with extra features, better stability, and curated defaults.
- Is it safe to flash this firmware?
  - Flashing always carries risk. Follow the steps carefully and ensure stable power. U‑Boot recovery is available.
- Can I revert to stock firmware?
  - Yes. Use the U‑Boot recovery page to upload a stock or factory image.
- How to lock bands?
  - modem > qmodem > Advanced Modem Settings > Lock Band; select bands; Apply.
- How to lock a cell tower?
  - modem > qmodem > Advanced Modem Settings > Neighbor Cell -> Run Scan -> choose cell -> enter PCI + ARFCN -> Submit.
- How to change the UI theme?
  - system > system > Language and style > Design -> choose theme -> Apply.

## Support & Pricing

- Price: NoobWRT Firmware — 2000 LKR
- Includes: one‑time purchase, lifetime updates, community support
- Contact: https://wa.me/94716172860
- Video: https://youtu.be/6eYihpGg7Sw
- Website: https://aw1k.itsnooblk.com/
- GitHub: https://github.com/nooblk-98/arcadyan-aw1000-mod-firmware

— Firmware maintained by NoobLK • © 2025 NoobWRT
