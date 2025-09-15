# NoobWRT for Arcadyan AW1000 (OpenWrt/ImmortalWRT)

Supercharge your AW1000 with NoobWRT.

Unlock enterprise-grade performance, rock-solid security, and flexible customization.

[Buy Now](https://wa.me/94716172860) · [See it in Action](https://youtu.be/6eYihpGg7Sw)

![NoobWRT Dashboard](/images/main.png)

Everything you need, nothing you don’t.

A firmware built for power users who demand stability, performance, and control.

## Release Notes

- Fixed 5G LED indicator behavior.
- Updated all packages to latest available versions.
- Removed PassWall.
- Added HomeProxy.

If you previously used PassWall, please migrate your configuration. HomeProxy is now the recommended proxy solution.

## Features

- Blazing-fast performance: wire-speed routing and low latency with hardware flow offloading
- Advanced security: firewall hardening, WireGuard/OpenVPN ready, and regular security updates
- Extensive package support: one-click installs for LuCI apps, Adblock, USB tools, and more
- Unmatched stability: built on ImmortalWRT for long-term reliability and updates

## Optimization

Optimized for space and flexibility

- Maximized free space: optimized image leaves more overlay space for packages and configs
- Dynamic overlay support: adapts automatically to your storage size, no manual tweaks

Example device stats (for reference):

```
Memory (Total/Used/Cached): 866.07 MiB / 343.31 MiB / 142.20 MiB
Storage (Disk/Temp):        562.95 MiB / 433.04 MiB
```

## Installation

Simple and safe — get running in minutes.

1. Connect to the router
- Use an SSH client (PuTTY/Terminal) to reach your router.

2. Copy the command
- Copy the command below.

3. Paste and run
- Paste in SSH and press Enter; follow the prompts.

```bash
wget -qO /tmp/flash https://raw.githubusercontent.com/nooblk-98/arcadyan-aw1000-mod-firmware/main/flash/flash && chmod +x /tmp/flash && /tmp/flash
```

Installer menu preview:

```
========================================
NoobWRT - Firmware Flasher
Contact: https://wa.me/94716172860
========================================

Choose which firmware you want to flash:
1) Noobwrt Pro Firmware
2) Noobwrt Free Firmware
3) Noobwrt devBuild Firmware

Enter option (1/2/3): 1
Are you sure you want to flash (sysupgrade-pro.bin)? [y/N]: y
Enter your license key:
```

Advanced install (U-Boot recovery from stock):

1) Connect PC to a yellow LAN port and set static IPv4:

```
IP: 192.168.1.2
Mask: 255.255.255.0
GW:   192.168.1.1 (optional)
```

2) Enter U-Boot recovery: hold reset, power on, keep holding ~8–10 s

3) Open http://192.168.1.254, upload a factory .ubi, wait 2–3 minutes

4) SSH to 192.168.1.1 and run the installer command above

## Indicators

- Power light: device is powered and ready
- 5G indicator: shows 5G mobile connection status
- Internet status: confirms active internet connection
- Signal strength: cellular signal quality level
- New SMS: unread SMS on the SIM

## Defaults

- Default Wi‑Fi SSIDs: "NoobWRT 2GHz" and "NoobWRT 5GHz"
- Default Wi‑Fi password: 123456789
- Admin login: user `root`, no password set

For security, set a strong admin password on first login.

## Pricing

NoobWRT Firmware — 2000 LKR

- One-time purchase
- Lifetime updates
- Community forum support
- Full feature set

[Buy Firmware via WhatsApp](https://wa.me/94716172860)

Need a router? Our seller can provide a compatible AW1000 prepped for NoobWRT.

[Contact Seller](https://wa.me/94716172860)

## Technical Specifications

- Compatibility: Arcadyan AW1000 (qualcommax/ipq807x)
- Version: NoobWRT 24.10.1
- Kernel: 6.6.100
- CPU: 1.4 GHz Quad‑Core
- RAM: 1 GB DDR4
- Storage: 256 MB NAND

## Visual Tour

Click any image to view in your GitHub viewer.

![Pro Dashboard](/images/full-dash.png)

![Pro Dashboard (Light)](/images/dash-full-white.png)

## Packed with Features (Packages)

Popular packages preloaded to enhance your router out of the box.

<details>
<summary>Show package list</summary>

adblock, aria2, aria2-openssl, ariang, attr, avahi-dbus-daemon, bash, bc, blkid, bzip2, chat, chinadns-ng,
collectd, collectd-mod-cpu, collectd-mod-interface, collectd-mod-iwinfo, collectd-mod-load, collectd-mod-memory,
collectd-mod-network, collectd-mod-rrdtool, comgt, coreutils, coreutils-base64, coreutils-nohup, coreutils-sort,
coreutils-stat, curl, dbus, ddns-scripts, ddns-scripts-services

... and many more (264+ packages total).

</details>

## FAQ

- What is NoobWRT?
  - A performance‑tuned OpenWrt (ImmortalWRT) build for the AW1000 with extra features, better stability, and curated defaults.
- Is it safe to flash this firmware?
  - Flashing always carries risk. Follow the steps carefully and ensure stable power. A U‑Boot recovery path is available.
- What kind of support do I get?
  - Community‑based support and updates. Commercial help available via WhatsApp.
- Can I revert to stock firmware?
  - Yes. Use the U‑Boot recovery page to upload a stock or factory image.
- How to lock bands?
  - modem > qmodem > Advanced Modem Settings > Lock Band, select bands, Apply.
- How to lock a cell tower?
  - modem > qmodem > Advanced Modem Settings > Neighbor Cell -> Run Scan -> choose cell -> enter PCI + ARFCN -> Submit.
- How to change the UI theme?
  - system > system > Language and style > Design -> choose theme -> Apply.

## Get Started

- Buy the firmware: https://wa.me/94716172860
- Watch setup: https://youtu.be/6eYihpGg7Sw
- Website & releases: https://aw1k.itsnooblk.com/
- View on GitHub: https://github.com/nooblk-98/arcadyan-aw1000-mod-firmware

— Firmware maintained by NoobLK

© 2025 NoobWRT. All rights reserved.

