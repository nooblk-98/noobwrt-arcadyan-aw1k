<div align="center">

# NoobWRT for Arcadyan AW1000

**High-performance, fully customized OpenWrt firmware for the Arcadyan AW1000**

[![Release](https://img.shields.io/github/v/release/nooblk-98/noobwrt-arcadyan-aw1k?style=for-the-badge)](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/nooblk-98/noobwrt-arcadyan-aw1k/total?style=for-the-badge&logo=openwrt)](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k/releases)
[![Issues](https://img.shields.io/github/issues/nooblk-98/noobwrt-arcadyan-aw1k?style=for-the-badge)](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k/issues)
[![Target](https://img.shields.io/badge/target-Arcadyan%20AW1000-blue?style=for-the-badge)](https://aw1k-docs.itsnooblk.com/hardware/)
[![Base](https://img.shields.io/badge/base-OpenWrt-green?style=for-the-badge)](https://openwrt.org)
[![License](https://img.shields.io/badge/license-GPL--2.0-orange?style=for-the-badge)](#license)

![NoobWRT](/images/logo.png)

[Download](#-download) · [Features](#-features) · [Install](#-quick-install) · [Screenshots](#-screenshots) · [Documentation](#-documentation) · [Support](#-support)

</div>

---

## 📥 Download

**Download the current stable firmware release from here:**

[![Download Latest Release](https://img.shields.io/badge/Download-Latest%20Release-success?style=for-the-badge&logo=github)](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k/releases/latest)

> [!IMPORTANT]
> Read the release notes before upgrading. Each release lists its build info, image variants and any **known issues** with workarounds.

---

## ✨ Features

- **Up-to-date OpenWrt base** with the latest upstream packages, security patches and bug fixes
- **PassWall 1 / PassWall 2** with a tested, bundled Xray-core
- **Cellular modem management** via QModem, modem data, SMS tool and TTL tools
- **Networking extras:** SQM, mwan3, banIP, AdGuard Home, SmartDNS, HomeProxy
- **VPN & remote access:** Tailscale, ZeroTier, OpenVPN, Cloudflared, FRP client
- **Monitoring:** network status, bandwidth monitoring (nlbwmon, wrtbwmon), statistics
- **Modern UI** with the Argon theme and the APK package manager

See the full [package list](https://aw1k-docs.itsnooblk.com/packages/).

### Phone port (RJ11)

RJ11 phone port working with [openwrt-aw1000-phone](https://github.com/Perz3us/openwrt-aw1000-phone). Plug in a normal desk phone and make and take calls with the SIM in the 5G modem (VoLTE).

- Incoming and outgoing calls, dial tone, ringing tone and busy tone
- HD calling (16 kHz wideband audio), switched on in Settings
- Caller ID on phones with a display (FSK Bellcore, FSK ETSI or DTMF, before or after the first ring)
- Hold with the FLASH button, speed dial and blocked numbers
- The phone LED follows the line: ready, ringing and off hook
- Call history with search, filters, CSV export and optional auto delete
- LuCI pages for status, settings and a line test

Install steps are in the [project README](https://github.com/Perz3us/openwrt-aw1000-phone#install).

#### Voice call problems

These are modem settings, not firmware problems. They are saved in the modem, so flashing NoobWRT again does not change them.

**Every call fails at once with `NO CARRIER`.** Some modems have `call_control` set to `1,1`, which blocks all voice calls. Set it to `0,0`:

```
ubus call at-daemon sendat '{"at_port":"/dev/ttyUSB2","at_cmd":"AT+QCFG=\"call_control\"","timeout":3}'
ubus call at-daemon sendat '{"at_port":"/dev/ttyUSB2","at_cmd":"AT+QCFG=\"call_control\",0,0","timeout":3}'
```

**VoLTE never registers** (`AT+QCFG="ims"` shows `1,0`) even though the SIM does VoLTE in a phone. Some units have `sms_only` set to `01`, so the modem asks the network for data and SMS only. Set it to `00` and restart the modem:

```
ubus call at-daemon sendat '{"at_port":"/dev/ttyUSB2","at_cmd":"AT+QNVFR=\"/nv/item_files/modem/mmode/sms_only\"","timeout":3}'
ubus call at-daemon sendat '{"at_port":"/dev/ttyUSB2","at_cmd":"AT+QNVFW=\"/nv/item_files/modem/mmode/sms_only\",00","timeout":3}'
ubus call at-daemon sendat '{"at_port":"/dev/ttyUSB2","at_cmd":"AT+CFUN=1,1","timeout":3}'
```

Reboot the router after the modem restart. `AT+QCFG="ims"` should then show `1,1`.

---

## 🚀 Quick Install

Upgrading from an existing OpenWrt / NoobWRT installation, use the **sysupgrade** image (`.bin`):

1. Open `http://192.168.1.1` and go to **System → Backup / Flash Firmware**.
2. Create a backup of your current settings.
3. Upload the `sysupgrade.bin` image and confirm.
4. Wait for the router to reboot, then log in again at `http://192.168.1.1`.

For first-time installation, CLI flashing and recovery, follow the [Installation guide](https://aw1k-docs.itsnooblk.com/installation/).

> [!CAUTION]
> Flashing third-party firmware may void your warranty and can brick your device if interrupted. Ensure stable power and proceed at your own risk. If something goes wrong, see the [Recovery guide](https://aw1k-docs.itsnooblk.com/recovery/).

---

## 📸 Screenshots

<div align="center">

![Dashboard](/images/dash.png)

| Login | Passwall |
| :---: | :---: |
| ![Login](/images/01-login.png) | ![Passwall](/images/03-passwall.png) |

| Network Status | Bandix |
| :---: | :---: |
| ![Network Status](/images/04-netstat.png) | ![Bandix](/images/05-bandix.png) |

| Theme |
| :---: |
| ![Theme](/images/06-theme.png) |

</div>

### 🎬 Demo Video

[![Watch on YouTube](https://img.youtube.com/vi/pxMpUKWQ3nU/maxresdefault.jpg)](https://www.youtube.com/watch?v=pxMpUKWQ3nU)

*Click the image to watch on YouTube.*

---

## 📚 Documentation

Full documentation: **[aw1k-docs.itsnooblk.com](https://aw1k-docs.itsnooblk.com)**

| Guide | Description |
|---|---|
| [Getting Started](https://aw1k-docs.itsnooblk.com/getting-started/) | First steps after flashing |
| [Installation](https://aw1k-docs.itsnooblk.com/installation/) | Flash via web UI or CLI |
| [Phone (RJ11)](https://aw1k-docs.itsnooblk.com/phone/) | Set up the RJ11 phone port |
| [Recovery](https://aw1k-docs.itsnooblk.com/recovery/) | Unbrick and restore your router |
| [UART Guide](https://aw1k-docs.itsnooblk.com/uart-guide/) | Serial console access |
| [Modem Firmware](https://aw1k-docs.itsnooblk.com/modem-firmware/) | Modem firmware information |
| [Hardware](https://aw1k-docs.itsnooblk.com/hardware/) | AW1000 hardware specifications |
| [Packages](https://aw1k-docs.itsnooblk.com/packages/) | Included packages |
| [FAQ](https://aw1k-docs.itsnooblk.com/faq/) | Common questions and fixes |

---

## 📢 Notices

> [!NOTE]
> **Lite firmware is discontinued.** No new Lite builds are released. Existing Lite users can keep using the [last Lite release](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k/releases/tag/v2026-02-12-15-17-16). Lite builds may return if there is enough demand.

---

## 🛟 Support

Found a bug or need help? [Open an issue](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k/issues) and include:

- Firmware release tag (e.g. `v2026-09-24`) and variant (PassWall 1 / PassWall 2)
- What you expected vs. what happened
- Relevant logs (**Status → System Log** / **Kernel Log**) and screenshots

Before opening an issue, check the [FAQ](https://aw1k-docs.itsnooblk.com/faq/) and the known issues in the latest release notes.

---

## 🙏 Credits

This firmware is compiled and maintained by **Lahiru Sandaruwan ([NoobLK](https://www.linkedin.com/in/lahiru-sandaruwan-liyanage/))**.

NoobWRT is **free and open source**, built for the community. Please do not sell this firmware or any derivative of it; it should remain free for everyone.

If you find this project useful, please ⭐ [star the repository](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k)!

## License

Based on [OpenWrt](https://openwrt.org) and distributed under the [GPL-2.0](https://aw1k-docs.itsnooblk.com/license/) license.
