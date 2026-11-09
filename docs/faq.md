# FAQ

## What is NoobWRT?

NoobWRT is a performance-tuned OpenWrt firmware build optimized for the Arcadyan AW1000. It provides enhanced stability, curated applications, and sensible default configurations.

## Which firmware file should I download?

Use the [latest release](builds.md) and download one of the sysupgrade images:

- `arcadyan_aw1000-rj11-passwall1-sysupgrade.bin` if you need PassWall's **Allow Insecure** option.
- `arcadyan_aw1000-rj11-passwall2-sysupgrade.bin` if your V2Ray configs are secure only.

## How do I use the RJ11 phone port?

See [Phone (RJ11)](phone.md).

## Is it safe to flash this firmware?

Flashing firmware carries risk. If you follow the installation steps carefully and ensure stable power, it should be safe. Recovery options are available if needed.

## Can I revert to stock firmware?

Yes. Use the U-Boot recovery page to upload a stock or factory image.

## How do I lock specific LTE or 5G bands?

Go to `Modem` then `Band Lock` in LuCI, select the LTE and 5G NR bands, enable
`Apply at boot` if the lock should survive reboots, then click `Apply`.

The same settings are available from SSH:

```sh
uci set mm_bandlock.main.enabled='1'
uci set mm_bandlock.main.lte='1 3 40'
uci set mm_bandlock.main.nr='78'
uci commit mm_bandlock
mm-bandlock apply
```

`mm-bandlock status` shows the current and supported bands, and
`mm-bandlock unlock` removes the lock.

## How do I lock to a specific cell tower?

ModemManager does not expose per-cell PCI/ARFCN locking. Lock the LTE or 5G NR
bands instead (see above); the modem then chooses the best cell inside those
bands. Per-cell locking was a QModem feature and is not available after the
QModem to ModemManager migration.

## How do I change the UI theme?

Go to `System` then `System` then `Language and Style` then `Design`.
