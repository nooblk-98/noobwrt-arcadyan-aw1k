# Installation

!!! note "Before You Flash"
    - Back up your current configuration (`System` then `Backup / Flash Firmware`).
    - Download the correct AW1000 sysupgrade image from [Releases](builds.md): `arcadyan_aw1000-rj11-passwall1-sysupgrade.bin` or `arcadyan_aw1000-rj11-passwall2-sysupgrade.bin`.
    - Ensure stable power to avoid bricking.

These steps are for routers already running OpenWrt or NoobWRT with the standard AW1000 layout. If `sysupgrade` says the device is not supported by the image, do not force it. Use the [UART Guide](uart-guide.md) instead.

## Flash via Web UI

1. Log in to the web UI: `http://192.168.1.1`.
2. Go to `System` then `Backup / Flash Firmware`.
3. Upload the sysupgrade image, for example `arcadyan_aw1000-rj11-passwall1-sysupgrade.bin`.
4. Untick `Keep settings` if you are coming from a different firmware.
5. Confirm the upgrade and wait for the device to reboot.

## Flash via CLI

Copy the image to the router, for example into `/tmp`:

```sh
scp arcadyan_aw1000-rj11-passwall1-sysupgrade.bin root@192.168.1.1:/tmp/
```

Check the image, then run sysupgrade:

```sh
sysupgrade -T /tmp/arcadyan_aw1000-rj11-passwall1-sysupgrade.bin
sysupgrade -n /tmp/arcadyan_aw1000-rj11-passwall1-sysupgrade.bin
```

!!! danger "`-n` erases all settings"
    `sysupgrade -n` erases all settings, including PassWall nodes and Wi-Fi. Drop `-n` to keep your settings.

## After Upgrade

- Reconnect to `http://192.168.1.1`.
- Set or reset the admin password.
- Restore configuration if needed.
- To use the RJ11 phone port, follow [Phone (RJ11)](phone.md).

If something goes wrong, follow the [Recovery](recovery.md) section.
