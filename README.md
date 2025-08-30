# Arcadyan AW1000 — NoobWRT Custom Firmware (OpenWrt/ImmortalWRT)

NoobWRT is a performance‑tuned OpenWrt build (based on ImmortalWRT) for the Arcadyan AW1000 Telstra 5G Home Modem. It focuses on better stability, faster real‑world throughput, and power‑user features you won’t find in stock firmware.

![Dashboard Preview](/images/main.png)

## Highlights

- Performance‑tuned kernel and system settings for low latency
- Optimized 5G modem handling, WAN failover, and connection tracking
- Built‑in packages that are not available on stock firmware
- Improved firewall, QoS/SQM options, and sensible defaults
- Pro and Lite dashboards for deep control or a clean, fast UI
- Ongoing updates and fixes driven by community feedback

> Designed for enthusiasts who want a smooth, stable, and configurable 5G router experience.

## Screenshots

![Pro Dashboard](/images/full-dash.png)
![Pro Dashboard — Light](/images/dash-full-white.png)

## Quick Install (on OpenWrt/ImmortalWRT)

Run on your router via SSH to install NoobWRT using the flash helper. This works on a running OpenWrt/ImmortalWRT system on the AW1000.

```bash
opkg update
opkg install curl coreutils-base64
wget -qO /tmp/flash https://raw.githubusercontent.com/nooblk-98/arcadyan-aw1000-mod-firmware/main/flash/flash && \
  chmod +x /tmp/flash && \
  /tmp/flash
```

Optional: verify the download before running it.

```bash
sha256sum /tmp/flash
```

## Install From Stock (U‑Boot Recovery)

If your router is on the original firmware, you can first boot into U‑Boot recovery, flash a clean OpenWrt/ImmortalWRT factory image, then apply NoobWRT.

- Step‑by‑step guide: `guide/o-firmware.md`
- After first boot, SSH to the router and run the Quick Install above.

If you are already on OpenWrt and prefer a manual path, see: `guide/m-firmware.md`.

## FAQ

- Band lock: Go to `modem > qmodem > Advanced Modem Settings > Lock Band`, select desired bands, then apply.
- Cell lock: `modem > qmodem > Advanced Modem Settings > Neighbor Cell` → Run Scan → pick a cell → enter PCI + ARFCN → Submit.
- Theme: `system > system > Language and style > Design` → pick your theme → Apply.

## Support & Community

- Website, release notes, and support: https://aw1k.itsnooblk.com/

## Disclaimer

- Flashing custom firmware involves risk. Proceed at your own discretion.
- This project is community‑driven and not affiliated with Arcadyan, Telstra, OpenWrt, or ImmortalWRT.

