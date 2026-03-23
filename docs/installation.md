# Installation

!!! note "Before You Flash"

- Back up your current configuration.
- Download the correct AW1000 sysupgrade image from [Releases](https://github.com/nooblk-98/openwrt-sdk-runner/releases/)
- Ensure stable power to avoid bricking.


## Flash via Web UI

1. Log in to the web UI: `http://192.168.1.1`.
2. Go to `System` then `Backup / Flash Firmware`.
3. Upload `full-squashfs-sysupgrade.bin`.
4. Confirm the upgrade and wait for the device to reboot.

## Flash via CLI

1. Upload the image to the router, for example into `/tmp`.
2. Run sysupgrade:

```sh
sysupgrade /tmp/full-squashfs-sysupgrade.bin
```

## After Upgrade

- Reconnect to `http://192.168.1.1`.
- Set or reset the admin password.
- Restore configuration if needed.

If something goes wrong, follow the `Recovery` section.
