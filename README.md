# Arcadyan AW1000 - NoobWRT Custom Firmware (OpenWrt/ImmortalWRT)

NoobWRT is a performance-tuned OpenWrt build (based on ImmortalWRT) for the Arcadyan AW1000 Telstra 5G Home Modem. It focuses on better stability, faster real-world throughput, and power-user features you won't find in stock firmware.

![Dashboard Preview](/images/main.png)

## Highlights

- Performance-tuned kernel and system settings for low latency
- Optimized 5G modem handling, WAN failover, and connection tracking
- Built-in packages that are not available on stock firmware
- Improved firewall, QoS/SQM options, and sensible defaults
- Pro and Lite dashboards for deep control or a clean, fast UI
- Ongoing updates and fixes driven by community feedback

> Designed for enthusiasts who want a smooth, stable, and configurable 5G router experience.

## Screenshots

![Pro Dashboard](/images/full-dash.png)

![Pro Dashboard - Light](/images/dash-full-white.png)


## Installation

Choose the path that matches your current router state.

### Option A: From Stock Firmware (U-Boot Recovery)

1) Prepare your PC network
- Connect your PC to a yellow LAN port on the router.
- Set a static IPv4 on your PC:

```
IP address: 192.168.1.2
Subnet mask: 255.255.255.0
Gateway: 192.168.1.1 (optional)
```

![Network settings](/images/network.png)

2) Enter U-Boot recovery
- Unplug power.
- Press and hold the reset button.
- While holding reset, plug power back in and keep holding ~8-10 seconds until recovery mode is active.

3) Open the U-Boot web interface
- In your browser, go to: `http://192.168.1.254`

![U-Boot recovery](/images/uboot.png)

4) Flash a clean OpenWrt/ImmortalWRT factory image (.ubi)
- Download the factory image (example):

```
https://downloads.immortalwrt.org/releases/24.10.2/targets/qualcommax/ipq807x/immortalwrt-24.10.2-qualcommax-ipq807x-arcadyan_aw1000-squashfs-factory.ubi
```

- On the recovery page, choose the downloaded .ubi file and start the update.
- Wait 2-3 minutes; the router will reboot automatically into OpenWrt.

5) Apply NoobWRT
- SSH to the router (default OpenWrt IP `192.168.1.1`):

```bash
ssh root@192.168.1.1
```

- Install NoobWRT (Pro flash helper):

```bash
wget -qO /tmp/flash https://raw.githubusercontent.com/nooblk-98/arcadyan-aw1000-mod-firmware/main/flash/flash && \
  chmod +x /tmp/flash && \
  /tmp/flash
```

- Or install via Lite script (alternative):

```bash
wget -O /tmp/flash-lite.sh https://raw.githubusercontent.com/nooblk-98/arcadyan-aw1000-mod-firmware/refs/heads/main/flash/flash-lite.sh && \
  chmod +x /tmp/flash-lite.sh && \
  sh /tmp/flash-lite.sh
```

### Option B: From Existing OpenWrt/ImmortalWRT

1) (Recommended) Clear old SSH host key if you've re-flashed recently:

```bash
ssh-keygen -R 192.168.1.1
```

2) SSH to the router:

```bash
ssh root@192.168.1.1
```

3) Install NoobWRT
- Pro flash helper:

```bash
wget -qO /tmp/flash https://raw.githubusercontent.com/nooblk-98/arcadyan-aw1000-mod-firmware/main/flash/flash && \
  chmod +x /tmp/flash && \
  /tmp/flash
```

- Or Lite script (alternative):

```bash
wget -O /tmp/flash-lite.sh https://raw.githubusercontent.com/nooblk-98/arcadyan-aw1000-mod-firmware/refs/heads/main/flash/flash-lite.sh && \
  chmod +x /tmp/flash-lite.sh && \
  sh /tmp/flash-lite.sh
```

Tip: You may optionally verify downloads with `sha256sum` before executing.

### How-to Video

Watch the full flashing process:
https://youtu.be/6eYihpGg7Sw

## FAQ

- Band lock: Go to `modem > qmodem > Advanced Modem Settings > Lock Band`, select desired bands, then apply.
- Cell lock: `modem > qmodem > Advanced Modem Settings > Neighbor Cell` -> Run Scan -> pick a cell -> enter PCI + ARFCN -> Submit.
- Theme: `system > system > Language and style > Design` -> pick your theme -> Apply.

## Support & Community

- Website, release notes, and support: https://aw1k.itsnooblk.com/

## Disclaimer

- Flashing custom firmware involves risk. Proceed at your own discretion.
- This project is community-driven and not affiliated with Arcadyan, Telstra, OpenWrt, or ImmortalWRT.

