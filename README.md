# Arcadyan AW1000 - Noobwrt Firmware

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


### ✅ Direct Join Link to Your Telegram Group (For Support and Purchase)

[https://t.me/noobWart](https://t.me/+EDud7op603M5OWI1)


## Flash Pro Firmware

![Sitemap Uploader Screenshot](/images/full-dash.png)

![Sitemap Uploader Screenshot](/images/dash-full-white.png)

![Sitemap Uploader Screenshot](/images/dash-full-alpha.png)

Flash Pro version to router using terminal 

```bash
opkg update
opkg install curl
opkg install coreutils-base64
```

```bash
wget -qO /tmp/flash https://raw.githubusercontent.com/nooblk-98/arcadyan-aw1000-mod-firmware/main/flash/flash && chmod +x /tmp/flash && /tmp/flash

```

## Complete Flash Guide

[Original Firmware Users + Dead Recovery](./guide/o-firmware.md) 

[Custom Firmware Users](./guide/m-firmware.md) 
    
---

## FAQ

### How to Lock Bands on the Router?

Go to `modem > qmodem > Advanced Modem Settings > Lock Band`, then select the desired bands and apply the settings.

---

### How to Lock a Cell Tower on the Router?

1. Go to `modem > qmodem > Advanced Modem Settings > Neighbor Cell`.
2. Click **Run Scan** to find nearby towers.
3. Choose a cell from the results.
4. Enter the **PCI** and **ARFCN** values.
5. Click **Submit** to lock onto the selected cell.

---

### How to Change the UI Theme?

Navigate to `system > system > Language and style > Design`, select your preferred theme, and apply the changes.

---

