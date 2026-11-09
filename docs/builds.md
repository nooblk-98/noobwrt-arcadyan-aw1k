# Firmware Releases

## Maintainer builds (current)

New maintainer builds are delivered privately in Google Drive. This build path
creates no GitHub Actions artifacts and no automatic GitHub releases.

Start one from **Actions → Build Firmware** on `main`: choose the device and
variant, and enter a new `build_tag`. To test the dispatch and delivery transport
without compiling, run it once with `validate_only=true` and a separate unused
tag. Files land unzipped at `ROOT/<variant>/<build_tag>/`:

- `images/` — individual firmware images
- `metadata/` — build details, profiles, package and source pins
- `logs/` — build log
- `SHA256SUMS`, `result.json`, `COMPLETE.json` — checksums and receipts

Access stays private; links do not grant access. See
[build dispatch and verification](build-dispatch.md) for the layout and
verification steps.

Image names come from the selected profile, for example
`openwrt-qualcommax-ipq807x-arcadyan_aw1000-squashfs-sysupgrade.bin`.

## Historical stable releases

Published stable releases remain available:

[NoobWRT Releases](https://github.com/nooblk-98/noobwrt-arcadyan-aw1k/releases/latest)

Read the release notes before upgrading. Each release lists its build info, image
variants and any known issues with workarounds.

### Firmware Images

Historical releases ship two sysupgrade images. Both include RJ11 phone port
support.

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
