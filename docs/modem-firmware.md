# Modem Firmware

This section covers the RG500Q-EA modem firmware upgrade guidance.

## Important Notes

- China version warning: If your firmware ends with `ACY` such as `RG500QEAAAR11A07M4G_ACY`, it is a China-customized build and may not work properly.
- Upgrading modem firmware carries risk and may block downgrades.
- Ensure stable power during the upgrade.

## Quick Upgrade Steps

1. Download the latest modem firmware, for example version `R13 01.200`.
2. Extract the firmware package.
3. Upload to the router.
4. Flash using QFirehose:

```sh
QFirehose /path/to/firmware/
```

5. Verify the new modem version using AT commands:

```sh
ATI
```

If you are not familiar with modem flashing, ask for help before proceeding.
