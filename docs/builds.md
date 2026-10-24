# Firmware Releases

Always download the latest firmware from:

[NoobWRT Releases](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k/releases/latest)

Read the release notes before upgrading. Each release lists its build info, image variants and any known issues with workarounds.

## Firmware Images

Current releases ship two sysupgrade images. Both include RJ11 phone port support.

| Image | PassWall | Allow Insecure |
|---|---|---|
| `arcadyan_aw1000-rj11-passwall1-sysupgrade.bin` | PassWall 1 | Supported |
| `arcadyan_aw1000-rj11-passwall2-sysupgrade.bin` | PassWall 2 | Not supported |

## Which One Should I Use?

- **PassWall 1**: you need the **Allow Insecure** option, so you can use V2Ray configs with insecure TLS (for example self-signed certificates).
- **PassWall 2**: your V2Ray configs are **secure only** and work without Allow Insecure.

!!! warning "Do not upgrade Xray-core yourself"
    The bundled Xray-core version has been tested with these PassWall builds. Upgrading it can break your existing configurations.

## Notes

- Use the `sysupgrade.bin` image to upgrade an existing OpenWrt or NoobWRT installation. See [Installation](installation.md).
- Current releases use OpenWrt 25.12 with the **APK** package manager (not opkg).
- Lite firmware releases are discontinued.
