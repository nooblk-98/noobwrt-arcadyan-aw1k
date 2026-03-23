# Recovery

If something goes wrong during flashing or upgrades, try the recovery options below.

## Failsafe Mode

1. Power off the device.
2. Press and hold the reset button.
3. Power on while holding reset for at least 10 seconds.
4. Access the router using SSH or TFTP to re-upload a valid firmware.

## Serial Console Access

Advanced users can connect to the serial or UART console for low-level recovery and debugging.

## USB Boot Option

Using USB boot is the safest recovery method if you prepare it in advance.

1. Download the official OpenWrt kernel image and rename it to `initramfs.bin`.
2. Write `initramfs.bin` to a USB drive using a tool like Win32 Disk Imager.
3. Power off the router, insert the USB drive, and power on.
4. Boot from USB and flash a known good firmware using the Web UI.

Note: The USB drive will be completely formatted in this process.
