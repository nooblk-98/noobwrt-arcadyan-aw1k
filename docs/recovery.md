# Recovery

If something goes wrong during flashing or upgrades, try the recovery options below.

## Failsafe Mode

Failsafe mode starts the firmware that is already installed with default network settings. It helps when a bad setting locks you out, but not when the firmware itself does not boot.

1. Power off the device.
2. Press and hold the reset button.
3. Power on while holding reset for at least 10 seconds.
4. Set your computer to a static IP such as `192.168.1.2`, then connect with SSH to `192.168.1.1` and fix the configuration or re-flash a valid sysupgrade image.

## UART Recovery

If the router does not boot at all, or it runs a firmware or partition layout that the NoobWRT image does not support, use the serial console. This is the most reliable way to recover the AW1000.

Follow the [UART Guide](uart-guide.md). Its flashing procedure writes the standard AW1000 partition table (`MIBIB`) and a factory image over TFTP. After that, upgrade to the latest release with the normal [sysupgrade image](installation.md).

!!! warning "Do not force an unsupported image"
    If `sysupgrade -T` reports that the device is not supported by the image, do not run `sysupgrade -F`. Use UART recovery instead.

## USB Boot Option

Using USB boot is a recovery method if you prepare it in advance.

1. Get an OpenWrt `initramfs` kernel image for the Arcadyan AW1000 (`qualcommax/ipq807x`) and rename it to `initramfs.bin`.
2. Write `initramfs.bin` to a USB drive using a tool like Win32 Disk Imager.
3. Power off the router, insert the USB drive, and power on.
4. Boot from USB and flash a known good firmware using the Web UI.

Note: The USB drive will be completely formatted in this process.
