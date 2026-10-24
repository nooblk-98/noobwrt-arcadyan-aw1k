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

Go to `Modem` then `qModem` then `Advanced Modem Settings` then `Lock Band`.

## How do I lock to a specific cell tower?

1. Go to `Modem` then `qModem` then `Advanced Modem Settings` then `Neighbor Cell`.
2. Click `Run Scan` to discover nearby towers.
3. Select the preferred tower and enter PCI and ARFCN values.
4. Click `Submit`.

## How do I change the UI theme?

Go to `System` then `System` then `Language and Style` then `Design`.
