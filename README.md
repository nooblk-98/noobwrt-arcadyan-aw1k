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


### ✅ Direct Join Link to Your Telegram Group (For Support and Purchase)

[https://t.me/noobWart](https://t.me/+EDud7op603M5OWI1)



## Flash Lite Firmware

![Sitemap Uploader Screenshot](/images/lite-dash.png)

![Sitemap Uploader Screenshot](/images/dash-lite-white.png)

Flash the free version of the firmware to your router using the terminal:
```bash
opkg update
opkg install curl
opkg install coreutils-base64
```
```bash
wget -O /tmp/flash-lite.sh https://raw.githubusercontent.com/nooblk-98/arcadyan-aw1000-mod-firmware/refs/heads/main/flash/flash-lite.sh && chmod +x /tmp/flash-lite.sh && sh /tmp/flash-lite.sh
```

**License Key**
Use the following license key when prompted:

```bash
free-4-everyone
```

---

## Flash Pro Firmware

![Sitemap Uploader Screenshot](/images/full-dash.png)

![Sitemap Uploader Screenshot](/images/dash-full-white.png)

Flash Pro version to router using terminal 

```bash
opkg update
opkg install curl
opkg install coreutils-base64
```

```bash
wget -O /tmp/flash-full.sh https://raw.githubusercontent.com/nooblk-98/arcadyan-aw1000-mod-firmware/refs/heads/main/flash/flash-full.sh && chmod +x /tmp/flash-full.sh && sh /tmp/flash-full.sh

```

## Complete Flash Guide

[Original Firmware Users + Dead Recovery](./guide/o-firmware.md) 

[Custom Firmware Users](./guide/m-firmware.md) 
    
---

## 🆚 Free vs Pro Version

| **Feature**                            | **Free Version**  | **Pro Version**        |
| -------------------------------------- | ----------------- | ---------------------- |
| License Requirement                 | `free-4-everyone` | Individual License Key |
| UI                                     | Simple         | Advanced                 |
| Passwall                                 | Passwall 1      | Passwall 1  / 2             |
| NAS Tools                            | ❌ Not Available     | ✅ Included             |
| Cloudflare Zero Trust                          | ✅ Included      | ✅ Included             |
| Basic Firmware Core                 | ✅ Included        | ✅ Included             |
| Pre Installed Themes               | Classic      | Alpha / Aragon / Classic          |
| Dialog HBB Issue               | ✅ Fixed     | ✅ Fixed        |
| Performance Optimizations           | ✅ Enhanced        | ✅ Enhanced             |
| WAN Failover Support                | ✅ Manual          | ✅ Auto & Manual        |
| Modem & LED Control                 | ✅ Full Support    | ✅ Full Support         |
| Preinstalled Packages               | ✅ Limited         | ✅ Full Suite           |
| Advanced Firewall/QoS Profiles      | ❌ Not Available   | ✅ Enabled              |
| Technical Support & Community Help | ✅ Community Only  | ✅ Priority Support     |
| Developer Tools & Debug Options     | ❌ Not Available   | ✅ Full Access          |
| Update Frequency                    | ✅                 | ✅                      |

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

## ⚠️ Known Issues / To-Do

  * [x] ~~Fix Dialog HBB SIM Not Registering~~



