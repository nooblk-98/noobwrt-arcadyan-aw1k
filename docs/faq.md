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

The router keeps its IPv6 stack, LAN ULA and firewall, but the ModemManager
uplink (`modem`) requests IPv4 only by default: local carriers reject the
dual-stack PDP, and an IPv4-only bearer connects fastest. To try IPv6, set the
IP type to `ipv4v6`:

```sh
uci set network.modem.iptype='ipv4v6'
uci commit network
ifup modem
```

Then check `ifstatus modem` for `ipv6-address`/`ipv6-prefix`. If they stay empty,
or ModemManager logs `QMI protocol error (14): 'CallFailed'`, the SIM/APN is not
providing IPv6; set `iptype` back to `ipv4`.

## How do I change the UI theme?

Go to `System` then `System` then `Language and Style` then `Design`.
