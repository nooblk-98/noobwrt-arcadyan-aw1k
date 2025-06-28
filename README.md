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





## Complete Flash Guide

[Original Firmware Users](./guide/0-firmware.md) 

[Custom Firmware Users](./guide/m-firmware.md) 



## Flash Lite Firmware

Flash free version to router using terminal 

```bash
curl -fsSL https://raw.githubusercontent.com/nooblk-98/arcadyan-aw1000-mod-firmware/refs/heads/main/flash/flash-lite.sh | sh

```
    