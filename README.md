<div align="center">

# NoobWRT for Arcadyan AW1000

High-performance ImmortalWRT/OpenWrt firmware for the Arcadyan AW1000

[![Release](https://img.shields.io/github/v/release/nooblk-98/arcadyan-aw1000-mod-firmware?sort=semver&style=for-the-badge)](https://github.com/nooblk-98/arcadyan-aw1000-mod-firmware/releases)
[![Build Status](https://img.shields.io/badge/Build-Jenkins-blue?style=for-the-badge&logo=jenkins)](https://jenkins.itsnooblk.com/blue/organizations/jenkins/noobwrt-aw1k/activity)
[![Issues](https://img.shields.io/github/issues/nooblk-98/noobwrt-arcadyan-aw1k?style=for-the-badge)](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k/issues)
[![Target](https://img.shields.io/badge/target-Arcadyan%20AW1000-blue?style=for-the-badge)](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k)
[![Base](https://img.shields.io/badge/base-ImmortalWRT-green?style=for-the-badge)](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k)
[![Status](https://img.shields.io/badge/status-stable-brightgreen?style=for-the-badge)](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k)

<p align="center">
  <a href="https://jk.itsnooblk.com/job/aw1k-builder/">Build Status</a> ?
  <a href="#features">Features</a> ?
  <a href="https://github.com/nooblk-98/noobwrt-arcadyan-aw1k/issues/new">Report Issue</a> ?
  <a href="#faq">FAQ</a>
</p>

![NoobWRT Dashboard](/images/logo.png)

</div>

---

## Overview

NoobWRT transforms the Arcadyan AW1000 into a fast, secure, and highly customizable router. Built on the ImmortalWRT/OpenWrt foundation, it is tuned for:

- Performance: wire-speed routing with minimal latency
- Security: hardened firewall and regular security updates
- Stability: tested configuration for 24/7 reliability
- Flexibility: curated app ecosystem with sensible defaults

### Automated Monthly Builds

NoobWRT provides automated monthly builds powered by Jenkins CI/CD, ensuring access to:

- Latest package updates from upstream ImmortalWRT/OpenWrt
- Security patches applied automatically
- Bug fixes integrated as soon as they are available
- Transparent build process: [view build status and history](https://jk.itsnooblk.com/job/aw1k-builder/)

![Jenkins](/images/jenkins-build.png)

Every release is automatically built, tested, and published to ensure reliability and consistency.

---

## Important: Choose the Correct Firmware Version

Each release includes two firmware variants. Using the wrong version can brick your device.

<div align="center">

| Firmware File | Overlay Size | Device Compatibility | Use Case |
|---------------|--------------|----------------------|----------|
| `lite-squashfs-sysupgrade.bin` | ~12 MB | Devices with limited storage | Essential packages only |
| `full-squashfs-sysupgrade.bin` | ~100+ MB | Devices with ample storage (256MB+ NAND) | Full package set included |

</div>

### Critical Warning

> Do not flash the wrong firmware variant.
>
> - If you have a device with limited overlay space (< 50MB), use `lite-squashfs-sysupgrade.bin`
> - If you have a device with 100MB+ overlay space, use `full-squashfs-sysupgrade.bin`
> - Flashing the full version on a limited storage device will brick it
> - Check your current overlay size: System -> Software -> Available space

### How to Check Your Device

Before flashing, SSH into your router or check via LuCI:

```bash
df -h | grep overlay
```

Choose the firmware variant based on your available overlay space.

---

## Table of Contents

- [Overview](#overview)
- [Automated Monthly Builds](#automated-monthly-builds)
- [Important: Choose the Correct Firmware Version](#important-choose-the-correct-firmware-version)
- [Screenshots](#screenshots)
- [Specifications](#specifications)
- [Packages](#packages)
- [Indicators and Defaults](#indicators-and-defaults)
- [FAQ](#faq)
- [Contributing](#contributing)
- [License](#license)

---

## Screenshots

<div align="center">

### UI

![Dashboard](/images/dash.png)

![toolset](/images/toolset.png)

![theme](/images/theme.png)

</div>

---

## Specifications

**Device:** Arcadyan AW1000 (qualcommax/ipq807x)  
**Firmware Version:** Latest ImmortalWRT  
**Kernel:** Latest ImmortalWRT  
**CPU:** 1.4 GHz Quad-Core ARM Cortex  
**RAM:** 1 GB DDR4  
**Storage:** 256 MB NAND Flash  
**Wireless:** Dual-band 802.11ac Wi-Fi  
**Ports:** Multiple Gigabit Ethernet and USB

---

## Indicators and Defaults

### LED Indicators

**Power Light:** Device is powered on and ready  
**5G Indicator:** Active 5G mobile connection status  
**Internet Status:** Confirms active internet connection  
**Signal Strength:** Cellular signal quality level  
**New SMS:** Unread SMS messages on the SIM card

### Default Settings

**Wi-Fi SSID (2.4GHz):** `NoobWRT 2GHz`  
**Wi-Fi SSID (5GHz):** `NoobWRT 5GHz`  
**Wi-Fi Password:** `123456789`  
**Admin Username:** `root`  
**Admin Password:** (not set - configure on first login)  
**LAN IP Address:** `192.168.1.1`

> Important: Change the default admin password and Wi-Fi credentials immediately after first login for security.

---

## Packages

<div align="center">
<table>
<tr>
<td width="50%">

| Package | Full | Lite |
|---------|:----:|:----:|
| **Base System** | | |
| `luci` | ✓ | ✓ |
| `htop` | ✓ | ✓ |
| `autocore` | ✓ | ✓ |
| `bash` | ✓ | ✓ |
| `block-mount` | ✓ | ✓ |
| `ds-lite` | ✓ | ✓ |
| `ethtool-full` | ✓ | ✓ |
| `coreutils` | ✓ | ✓ |
| `coreutils-base64` | ✓ | ✓ |
| `coreutils-nohup` | ✓ | ✓ |
| `curl` | ✓ | ✓ |
| `openssh-sftp-server` | ✓ | |
| `resolveip` | ✓ | ✓ |
| `tcping` | ✓ | ✓ |
| `unzip` | ✓ | ✓ |
| **Network & Firewall** | | |
| `dnsmasq-full` | ✓ | ✓ |
| `firewall4` | ✓ | ✓ |
| `nftables` | ✓ | ✓ |
| `kmod-nft-core` | ✓ | ✓ |
| `iptables-nft` | ✓ | ✓ |
| **Modem Support** | | |
| `luci-app-qmodem` | ✓ | ✓ |
| `luci-app-sms-tool-js` | ✓ | ✓ |
| `luci-app-qmodem-ttl` | ✓ | ✓ |
| `quectel-CM-5G-M` | ✓ | ✓ |
| `tom_modem` | ✓ | ✓ |
| `luci-app-modemdata` | ✓ | ✓ |
| `comgt` | ✓ | ✓ |

</td>
<td width="50%">

| Package | Full | Lite |
|---------|:----:|:----:|
| **VPN & Proxy** | | |
| `luci-app-passwall` | ✓ | |
| `luci-app-passwall2` | ✓ | |
| `haproxy` | ✓ | |
| `xray-core` | ✓ | |
| `chinadns-ng` | ✓ | |
| `dns2socks` | ✓ | |
| `dns2tcp` | ✓ | |
| `microsocks` | ✓ | |
| `kmod-wireguard` | ✓ | ✓ |
| `wireguard-tools` | ✓ | ✓ |
| `luci-proto-wireguard` | ✓ | ✓ |
| `luci-proto-amneziawg` | ✓ | |
| `luci-app-openvpn` | ✓ | ✓ |
| `luci-app-tailscale` | ✓ | ✓ |
| `luci-app-zerotier` | ✓ | |
| `luci-app-homeproxy` | ✓ | ✓ |
| **System Management** | | |
| `luci-app-ramfree` | ✓ | ✓ |
| `luci-app-sqm` | ✓ | ✓ |
| `luci-app-cpufreq` | ✓ | ✓ |
| `luci-app-ttyd` | ✓ | ✓ |
| `luci-app-mwan3` | ✓ | |
| `luci-app-netstat` | ✓ | ✓ |
| `luci-app-nft-ttl` | ✓ | ✓ |
| **USB Support** | | |
| `usbutils` | ✓ | ✓ |
| `kmod-usb-serial` | ✓ | ✓ |
| `kmod-usb-serial-option` | ✓ | ✓ |
| `kmod-usb-serial-wwan` | ✓ | ✓ |
| `kmod-usb-net` | ✓ | ✓ |
| `kmod-usb-net-asix-ax88179` | ✓ | ✓ |
| `kmod-usb-net-cdc-ether` | ✓ | ✓ |
| `kmod-usb-net-cdc-ncm` | ✓ | ✓ |
| `kmod-usb-net-huawei-cdc-ncm` | ✓ | ✓ |
| `kmod-usb-net-ipheth` | ✓ | ✓ |
| `kmod-usb-net-qmi-wwan` | ✓ | ✓ |
| `kmod-usb-net-rndis` | ✓ | ✓ |
| `kmod-usb-ohci` | ✓ | ✓ |
| `kmod-usb-storage` | ✓ | ✓ |
| `usb-modeswitch` | ✓ | ✓ |
| **Themes** | | |
| `luci-theme-argon` | ✓ | ✓ |
| `luci-app-argon-config` | ✓ | ✓ |
| **Applications** | | |
| `luci-app-smartdns` | ✓ | ✓ |
| `luci-app-cloudflared` | ✓ | |
| `luci-app-nlbwmon` | ✓ | ✓ |
| `luci-app-internet-detector` | ✓ | ✓ |
| `luci-app-autoreboot` | ✓ | |
| `luci-app-filemanager` | ✓ | ✓ |
| `luci-app-statistics` | ✓ | |
| `luci-app-banip` | ✓ | |
| `luci-app-samba4` | ✓ | ✓ |
| `luci-app-package-manager` | ✓ | |
| `luci-app-diskman` | ✓ | ✓ |
| `luci-app-eqos` | ✓ | ✓ |
| `luci-app-frpc` | ✓ | ✓ |
| `luci-app-hd-idle` | ✓ | ✓ |
| `luci-app-qbittorrent` | ✓ | |
| `luci-app-wifischedule` | ✓ | ✓ |
| `luci-app-wol` | ✓ | |
| `luci-app-wrtbwmon` | ✓ | |
| `luci-app-adguardhome` | ✓ | |

</td>
</tr>
</table>
</div>

---

## Modem Firmware Upgrade Guide (RG500Q-EA)

### ⚠️ Important Notes

- **China Version Warning:** If your firmware version ends with `ACY` (e.g., `RG500QEAAAR11A07M4G_ACY`), it's a China-customized version and may not work properly. Upgrade to the latest version.
- **Risk Warning:** Performing a firmware upgrade carries some risk. You may not be able to downgrade afterward. Ensure stable power during the process.

### Quick Upgrade Steps
1. **Download Latest Firmware**
   - Download version: **R13 01.200**
   - Download link: [Google Drive](https://drive.google.com/file/d/1SnuogB48SNOrdLDLh3NhIpyy_drIWhFS/view?usp=sharing)

2. **Extract and Upload**
   - Extract the firmware file
   - Upload it to your router

3. **Flash the Firmware**
   - Use QFirehose tool to install the firmware:
   ```bash
   QFirehose /path/to/firmware/
   ```

4. **Verify the Upgrade**
   - Check the new firmware version using AT commands:
   ```bash
   ATI
   ```

---

## Recovery Instructions

If something goes wrong during the upgrade (power cut, interrupted upload, firmware mismatch, or unexpected reboot), don't panic. Try these recovery methods:

### 1. **Failsafe Mode** (Recommended for beginners)
- **What it does:** Lets you access the router without loading the full system
- **How to use:**
  1. Power off your router
  2. Press and hold the reset button
  3. Power on while holding reset (keep holding for 10+ seconds)
  4. Access the router via SSH or TFTP to re-upload a valid firmware

### 2. **Serial Console Access** (Advanced)
- **What it does:** Direct low-level access to the router for debugging and recovery
- **How to use:**
  1. Connect to the router's serial/UART console
  2. Use debug commands for recovery

### 3. **USB Boot Option** (Best Prevention)
- **What it does:** Allows you to boot from USB instead of internal storage, preventing permanent bricking
- **When to use:** Set this up BEFORE you have problems

#### USB Boot Setup Guide

1. **Get the USB Boot Files**
   - Download the official OpenWrt kernel image
   - Rename it to `initramfs.bin`

2. **Prepare Your USB Drive**
   - Get a USB drive (1GB or larger)
   - Download and use [Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/)
   - Write `initramfs.bin` to the USB drive
   - ⚠️ Warning: The USB drive will be completely formatted

3. **Boot from USB**
   - Power off your router
   - Insert the USB drive
   - Power on the router
   - The router should boot from USB

4. **Flash Safe Firmware**
   - Download the official OpenWrt sysupgrade image
   - Access the Web UI
   - Flash it through the Web UI

---

## Installing Additional Packages

You can expand NoobWRT functionality by installing additional packages from the custom feeds

### Steps to Install Additional Packages

1. **Download Package from Custom Feed**
   - Visit https://feeds.itsnooblk.com/
   - Download the desired `.ipk` package file to your computer

2. **Upload to Router**
   - Access http://192.168.1.1 in your browser
   - Go to **System → File Manager**
   - Navigate to `/tmp` directory
   - Click **Upload** and select your downloaded `.ipk` file

3. **Install via SSH or LuCI**
   - **Option A (SSH - Recommended):**
     ```bash
     ssh root@192.168.1.1
     opkg install /tmp/package-name.ipk
     ```
   - **Option B (Web UI):**
     - Go to **System → Software**
     - Click **Upload Package**
     - Select your uploaded `.ipk` file
     - Click **Install**

4. **Verify Installation**
   - Check **System → Software** to confirm the package appears in the installed list

---

## FAQ

<details>
<summary><b>What is NoobWRT?</b></summary>

NoobWRT is a performance-tuned ImmortalWRT/OpenWrt firmware build optimized for the Arcadyan AW1000. It features enhanced stability, curated applications, and sensible default configurations.

</details>

<details>
<summary><b>Which firmware file should I download?</b></summary>

Choosing the wrong firmware can brick your device.

- `lite-squashfs-sysupgrade.bin` for devices with ~12MB overlay (limited storage)
- `full-squashfs-sysupgrade.bin` for devices with 100MB+ overlay (standard AW1000 with 256MB NAND)

How to check: Run `df -h | grep overlay` via SSH or check System -> Software in LuCI.

If unsure, use the lite version. It is safer and can be upgraded to full later if you have space.

</details>

<details>
<summary><b>Is it safe to flash this firmware?</b></summary>

Flashing firmware always carries some risk. If you follow the installation steps carefully, choose the correct firmware variant, and ensure stable power during the process, it should be safe. The device has U-Boot recovery available as a fallback option.

</details>

<details>
<summary><b>Can I revert to stock firmware?</b></summary>

Yes. Access the U-Boot recovery page and upload the stock or factory firmware image.

</details>

<details>
<summary><b>How do I lock specific LTE/5G bands?</b></summary>

Navigate to: Modem -> qModem -> Advanced Modem Settings -> Lock Band

Select your desired bands and click Apply.

</details>

<details>
<summary><b>How do I lock to a specific cell tower?</b></summary>

1. Go to Modem -> qModem -> Advanced Modem Settings -> Neighbor Cell
2. Click Run Scan to discover nearby towers
3. Choose your preferred cell tower
4. Enter the PCI and ARFCN values
5. Click Submit

</details>

<details>
<summary><b>How do I change the UI theme?</b></summary>

Navigate to: System -> System -> Language and Style -> Design

Select your preferred theme from the dropdown and click Apply.

</details>

<details>
<summary><b>Where can I get support?</b></summary>

For support and inquiries, contact via [WhatsApp](https://wa.me/94716172860) or check the [Setup Video](https://youtu.be/6eYihpGg7Sw) for detailed instructions.

</details>

---

## Contributing

We welcome contributions from the community. Feedback and ideas help make NoobWRT better for everyone.

### Report Bugs

1. Check if the issue already exists in the [Issue Tracker](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k/issues)
2. If not, [create a new issue](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k/issues/new)
3. Include:
   - Firmware version you are using
   - Device variant (lite or full)
   - Steps to reproduce the bug
   - Expected vs actual behavior
   - Logs or screenshots if applicable

### Suggest Improvements

1. [Open an issue](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k/issues/new) with the "enhancement" label
2. Describe:
   - What feature you would like to see
   - Why it would be useful to the community
   - How it might work (if you have ideas)

### Issue Guidelines

When creating an issue, please:
- Use a clear and descriptive title
- Provide as much detail as possible
- Be respectful and constructive
- Check for duplicates before posting

Your contributions help shape the future of NoobWRT.

---

## License

This firmware is based on [ImmortalWRT](https://github.com/immortalwrt/immortalwrt) and [OpenWrt](https://openwrt.org/), which are licensed under the GPL-2.0 license.

---

<div align="center">

NoobWRT - Firmware maintained by [NoobLK](https://github.com/nooblk-98)

Copyright 2025 NoobWRT

[![GitHub](https://img.shields.io/badge/GitHub-nooblk--98-181717?style=flat&logo=github)](https://github.com/nooblk-98)
[![WhatsApp](https://img.shields.io/badge/WhatsApp-Contact-25D366?style=flat&logo=whatsapp)](https://wa.me/94716172860)
[![YouTube](https://img.shields.io/badge/YouTube-Watch-FF0000?style=flat&logo=youtube)](https://youtu.be/6eYihpGg7Sw)

</div>
