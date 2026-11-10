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

Use the modem GUI in LuCI:

Go to `Modem` → `5G Modem` → `4G bands` / `5G bands`.
Select the bands and apply. The modem GUI also shows the current carrier
aggregation and 5G NSA status.

## How do I lock to a specific cell tower?

ModemManager does not expose per-cell PCI/ARFCN locking. Lock the LTE or 5G NR
bands instead (see above); the modem then chooses the best cell inside those
bands. Per-cell locking was a QModem feature and is not available after the
QModem to ModemManager migration.

## Does the modem support IPv6?

Yes. The ModemManager uplink defaults to dual-stack (`ipv4v6`), and the router
keeps its IPv6 stack, LAN ULA and firewall. Whether the WAN gets an IPv6 address
depends on the carrier and APN. If the carrier rejects the IPv6 PDP, IPv4 still
works and ModemManager logs a `QMI protocol error (14): 'CallFailed'` for the
IPv6 part. Check `ifstatus mmwan` for `ipv6-address`/`ipv6-prefix`; if they stay
empty, the SIM/APN is not providing IPv6 internet. Do not set `iptype=ipv4`
unless you intentionally want to stop requesting IPv6.

## How do I change the UI theme?

Go to `System` then `System` then `Language and Style` then `Design`.
