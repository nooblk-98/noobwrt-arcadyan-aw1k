# Packages

This build ships with a curated set of packages for performance, security, and usability. The list below matches the current default images.

Each image includes only one PassWall version: the PassWall 1 image includes `luci-app-passwall`, and the PassWall 2 image includes `luci-app-passwall2`. See [Releases](builds.md).

## Included Packages

| Package | Included |
|---------|----------|
| `luci` | yes |
| `htop` | yes |
| `autocore` | yes |
| `bash` | yes |
| `block-mount` | yes |
| `ds-lite` | yes |
| `ethtool-full` | yes |
| `coreutils` | yes |
| `coreutils-base64` | yes |
| `coreutils-nohup` | yes |
| `curl` | yes |
| `openssh-sftp-server` | yes |
| `resolveip` | yes |
| `tcping` | yes |
| `unzip` | yes |
| `dnsmasq-full` | yes |
| `firewall4` | yes |
| `nftables` | yes |
| `kmod-nft-core` | yes |
| `iptables-nft` | yes |
| `modemmanager` | yes |
| `luci-proto-modemmanager` | yes |
| `luci-app-5gmodem` | yes |
| `qmi-utils` | yes |
| `kmod-usb-acm` | yes |
| `kmod-usb-serial-qualcomm` | yes |
| `comgt` | yes |
| `luci-app-passwall` | PassWall 1 image |
| `luci-app-passwall2` | PassWall 2 image |
| `haproxy` | yes |
| `xray-core` | yes |
| `chinadns-ng` | yes |
| `dns2socks` | yes |
| `dns2tcp` | yes |
| `microsocks` | yes |
| `kmod-wireguard` | yes |
| `wireguard-tools` | yes |
| `luci-proto-wireguard` | yes |
| `luci-proto-amneziawg` | yes |
| `luci-app-openvpn` | yes |
| `luci-app-tailscale` | yes |
| `luci-app-zerotier` | yes |
| `luci-app-homeproxy` | yes |
| `luci-app-ramfree` | yes |
| `luci-app-sqm` | yes |
| `luci-app-cpufreq` | yes |
| `luci-app-ttyd` | yes |
| `luci-app-mwan3` | yes |
| `luci-app-netstat` | yes |
| `luci-app-nft-ttl` | yes |
| `usbutils` | yes |
| `kmod-usb-serial` | yes |
| `kmod-usb-serial-option` | yes |
| `kmod-usb-serial-wwan` | yes |
| `kmod-usb-net` | yes |
| `kmod-usb-net-asix-ax88179` | yes |
| `kmod-usb-net-cdc-ether` | yes |
| `kmod-usb-net-cdc-ncm` | yes |
| `kmod-usb-net-huawei-cdc-ncm` | yes |
| `kmod-usb-net-ipheth` | yes |
| `kmod-usb-net-qmi-wwan` | yes |
| `kmod-usb-net-rndis` | yes |
| `kmod-usb-ohci` | yes |
| `kmod-usb-storage` | yes |
| `usb-modeswitch` | yes |
| `luci-theme-argon` | yes |
| `luci-app-argon-config` | yes |
| `luci-app-smartdns` | yes |
| `luci-app-cloudflared` | yes |
| `luci-app-nlbwmon` | yes |
| `luci-app-internet-detector` | yes |
| `luci-app-autoreboot` | yes |
| `luci-app-filemanager` | yes |
| `luci-app-statistics` | yes |
| `luci-app-banip` | yes |
| `luci-app-samba4` | yes |
| `luci-app-package-manager` | yes |
| `luci-app-diskman` | yes |
| `luci-app-eqos` | yes |
| `luci-app-frpc` | yes |
| `luci-app-hd-idle` | yes |
| `luci-app-qbittorrent` | yes |
| `luci-app-wifischedule` | yes |
| `luci-app-wol` | yes |
| `luci-app-wrtbwmon` | yes |
| `luci-app-adguardhome` | yes |

## Phone (RJ11) Packages

These packages from [noobwrt-aw1000-voice](https://github.com/nooblk-98/noobwrt-aw1000-voice) run the RJ11 phone port and SIP phones. See [Phone (RJ11)](phone.md).

| Package | Purpose |
|---------|---------|
| `kmod-aw1000-fxs` | Kernel driver for the SLIC chip and the PCM audio bus |
| `fxsd` | Phone line service: ringing, dial tone, digits and modem calls |
| `modem-sip` | SIP server so phones and apps on the LAN share the SIM with the RJ11 phone |
| `aw1000-voice-web` | Management interface on port 7766: missed calls, history, recordings, settings, line health, missed-call alerts |
| `luci-app-aw1000-voice` | `Services` → `Phone` in LuCI with an **Open management interface** button |
