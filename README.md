<div align="center">

# 🚀 NoobWRT for Arcadyan AW1000

### High-performance ImmortalWRT/OpenWrt firmware for the Arcadyan AW1000

[![Release](https://img.shields.io/github/v/release/nooblk-98/arcadyan-aw1000-mod-firmware?sort=semver&style=for-the-badge)](https://github.com/nooblk-98/arcadyan-aw1000-mod-firmware/releases)
[![Target](https://img.shields.io/badge/target-Arcadyan%20AW1000-blue?style=for-the-badge)](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k)
[![Base](https://img.shields.io/badge/base-ImmortalWRT%20%2F%20OpenWrt-green?style=for-the-badge)](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k)
[![Kernel](https://img.shields.io/badge/kernel-6.6.100-success?style=for-the-badge)](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k)
[![Status](https://img.shields.io/badge/status-stable-brightgreen?style=for-the-badge)](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k)

<p align="center">
  <a href="https://wa.me/94716172860">💬 Buy Now</a> •
  <a href="https://youtu.be/6eYihpGg7Sw">📺 Setup Video</a> •
  <a href="#-features">✨ Features</a> •
  <a href="#-faq">❓ FAQ</a>
</p>

![NoobWRT Dashboard](/images/main.png)

</div>

---

## 📖 Overview

**NoobWRT** transforms the Arcadyan AW1000 into a fast, secure, and highly customizable router. Built on the robust ImmortalWRT/OpenWrt foundation, it's meticulously tuned for:

- ⚡ **Performance** - Wire-speed routing with minimal latency
- 🔒 **Security** - Hardened firewall and regular security updates
- 🎯 **Stability** - Battle-tested configuration for 24/7 reliability
- 🛠️ **Flexibility** - Curated app ecosystem with sensible defaults

---

## 📑 Table of Contents

- [✨ Features](#-features)
- [📸 Screenshots](#-screenshots)
- [⚙️ Specifications](#️-specifications)
- [📦 Packages](#-packages)
- [💡 Indicators & Defaults](#-indicators--defaults)
- [❓ FAQ](#-faq)
- [📄 License](#-license)

---


## ✨ Features

### 🚄 High Performance
- **Wire-speed routing** with hardware flow offloading
- **Low latency** optimized packet processing
- **Multi-core CPU utilization** for maximum throughput

### 🛡️ Enhanced Security
- **Firewall hardening** with advanced ruleset configuration
- **VPN ready** - WireGuard & OpenVPN pre-configured
- **Frequent security updates** from ImmortalWRT upstream

### 📱 Rich Application Suite
- **Curated LuCI apps** for comprehensive router management
- **Adblock** - System-wide ad blocking with multiple blocklist sources
- **USB utilities** - Storage mounting & USB tethering support
- **Diagnostic tools** - Network analysis and troubleshooting

### 🔧 Long-term Reliability
- Built on **ImmortalWRT** for extended support lifecycle
- **Stable releases** with thorough testing and validation
- **Active maintenance** with regular bug fixes and improvements

---

## 📸 Screenshots

<div align="center">

### Dark Theme Dashboard
![Dashboard (Pro)](/images/full-dash.png)

### Light Theme Dashboard
![Dashboard (Light)](/images/dash-full-white.png)

</div>

---

## ⚙️ Specifications

| Component | Details |
|-----------|---------|
| **Device** | Arcadyan AW1000 (qualcommax/ipq807x) |
| **Firmware Version** | NoobWRT 24.10.1 |
| **Kernel** | Linux 6.6.100 |
| **CPU** | 1.4 GHz Quad-Core ARM Cortex |
| **RAM** | 1 GB DDR4 |
| **Storage** | 256 MB NAND Flash |
| **Wireless** | Dual-band 802.11ac Wi-Fi |
| **Ports** | Multiple Gigabit Ethernet + USB |

---

## 📦 Packages

**264+ pre-installed packages** to enhance your router out-of-the-box! 🎁

<details>
<summary><b>📋 Click to view complete package list</b></summary>
<br>

adblock, aria2, aria2-openssl, ariang, attr, avahi-dbus-daemon, bash, bc, blkid, bzip2, chat, chinadns-ng,
collectd, collectd-mod-cpu, collectd-mod-interface, collectd-mod-iwinfo, collectd-mod-load, collectd-mod-memory,
collectd-mod-network, collectd-mod-rrdtool, comgt, coreutils, coreutils-base64, coreutils-nohup, coreutils-sort,
coreutils-stat, curl, dbus, ddns-scripts, ddns-scripts-services

... and many more for a complete router experience!

</details>

---

## 💡 Indicators & Defaults

### 🔔 LED Indicators

| Indicator | Meaning |
|-----------|---------|
| 🟢 **Power Light** | Device is powered on and ready |
| 📡 **5G Indicator** | Active 5G mobile connection status |
| 🌐 **Internet Status** | Confirms active internet connection |
| 📶 **Signal Strength** | Cellular signal quality level |
| 📨 **New SMS** | Unread SMS messages on the SIM card |

### 🔐 Default Settings

| Setting | Default Value |
|---------|---------------|
| **Wi-Fi SSID (2.4GHz)** | `NoobWRT 2GHz` |
| **Wi-Fi SSID (5GHz)** | `NoobWRT 5GHz` |
| **Wi-Fi Password** | `123456789` |
| **Admin Username** | `root` |
| **Admin Password** | *(not set - configure on first login)* |
| **LAN IP Address** | `192.168.1.1` |

> ⚠️ **Important**: Change the default admin password and Wi-Fi credentials immediately after first login for security!

---

## ❓ FAQ

<details>
<summary><b>What is NoobWRT?</b></summary>

NoobWRT is a performance-tuned ImmortalWRT/OpenWrt firmware build specifically optimized for the Arcadyan AW1000. It features enhanced stability, curated applications, and sensible default configurations for the best out-of-the-box experience.

</details>

<details>
<summary><b>Is it safe to flash this firmware?</b></summary>

Flashing firmware always carries some risk. However, if you follow the installation steps carefully and ensure stable power during the process, it should be safe. The device has U-Boot recovery available as a fallback option in case something goes wrong.

</details>

<details>
<summary><b>Can I revert to stock firmware?</b></summary>

Yes! You can revert to the stock firmware at any time. Simply access the U-Boot recovery page and upload the stock or factory firmware image.

</details>

<details>
<summary><b>How do I lock specific LTE/5G bands?</b></summary>

Navigate to: **Modem** → **qModem** → **Advanced Modem Settings** → **Lock Band**

Select your desired bands and click **Apply**.

</details>

<details>
<summary><b>How do I lock to a specific cell tower?</b></summary>

1. Go to **Modem** → **qModem** → **Advanced Modem Settings** → **Neighbor Cell**
2. Click **Run Scan** to discover nearby towers
3. Choose your preferred cell tower
4. Enter the **PCI** and **ARFCN** values
5. Click **Submit**

</details>

<details>
<summary><b>How do I change the UI theme?</b></summary>

Navigate to: **System** → **System** → **Language and Style** → **Design**

Select your preferred theme from the dropdown and click **Apply**.

</details>

<details>
<summary><b>Where can I get support?</b></summary>

For support and inquiries, contact via [WhatsApp](https://wa.me/94716172860) or check the [Setup Video](https://youtu.be/6eYihpGg7Sw) for detailed instructions.

</details>

---

## 📄 License

This firmware is based on [ImmortalWRT](https://github.com/immortalwrt/immortalwrt) and [OpenWrt](https://openwrt.org/), which are licensed under the GPL-2.0 license.

---

<div align="center">

**NoobWRT** - Firmware maintained by **[NoobLK](https://github.com/nooblk-98)**

© 2025 NoobWRT • Made with ❤️ for the Community

[![GitHub](https://img.shields.io/badge/GitHub-nooblk--98-181717?style=flat&logo=github)](https://github.com/nooblk-98)
[![WhatsApp](https://img.shields.io/badge/WhatsApp-Contact-25D366?style=flat&logo=whatsapp)](https://wa.me/94716172860)
[![YouTube](https://img.shields.io/badge/YouTube-Watch-FF0000?style=flat&logo=youtube)](https://youtu.be/6eYihpGg7Sw)

</div>
