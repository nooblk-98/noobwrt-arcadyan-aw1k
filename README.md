# Arcadyan AW1000 - Noobwart Firmware

A custom firmware built on top of **ImmortalWRT** (a fork of **OpenWrt**), tailored specifically for the Arcadyan AW1000 Telstra 5G Home Modem. This optimized build enhances **network stability**, **system performance**, and introduces **custom features** that are not available through stock or vanilla firmware.

![Sitemap Uploader Screenshot](/images/main.png)

## Key Highlights

* Performance-tuned kernel and system settings
* Optimized for balanced throughput and responsiveness
* Prebuilt support for packages not installable via default firmware
* Enhanced compatibility for 5G modem and WAN failover setups
* Improved firewall and QoS options
* Regular Updates and bug fixes based on users feedback

> Ideal for advanced users seeking a better experience than what stock firmware offers.

## Flash Lite Firmware

Flash free version to router using terminal 

```bash
wget -O /tmp/flash-lite.sh https://raw.githubusercontent.com/nooblk-98/arcadyan-aw1000-mod-firmware/refs/heads/main/flash/flash-lite.sh && chmod +x /tmp/flash-lite.sh && sh /tmp/flash-lite.sh

```

key
```bash
free-4-everyone
```

## Flash Pro Firmware

Flash Pro version to router using terminal 

```bash
wget -O /tmp/flash-full.sh https://raw.githubusercontent.com/nooblk-98/arcadyan-aw1000-mod-firmware/refs/heads/main/flash/flash-full.sh && chmod +x /tmp/flash-lite.sh && sh /tmp/flash-full.sh

```

## Complete Flash Guide

[Original Firmware Users](./guide/o-firmware.md) 

[Custom Firmware Users](./guide/m-firmware.md) 
    
---

## **5G Mode Indicator (5G LEDs)**

| LED Color | Status       | Meaning                                 |
| --------- | ------------ | --------------------------------------- |
| 🟢 Green  | Solid On     | Connected to 5G Network (NR Mode)       |
| 🔵 Blue   | Solid On     | Connected to LTE/4G                     |
| 🔴 Red    | Solid On     | No valid mode detected / 3G/2G fallback |
| ⚫ Off     | All LEDs off | No modem detected / not initialized     |

---


## **Signal Strength Indicator (Signal LEDs)**

| LED Color | Status   | Meaning                  |
| --------- | -------- | ------------------------ |
| 🔴 Red    | Solid On | Poor Signal (0–10%)      |
| 🔵 Blue   | Solid On | Medium Signal (11–50%)   |
| 🟢 Green  | Solid On | Strong Signal (51–100%)  |
| 🔴 Red    | Blinking | No signal or modem error |

---






