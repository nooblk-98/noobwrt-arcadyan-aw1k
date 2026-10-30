# Phone (RJ11)

The AW1000 RJ11 phone port works on NoobWRT with [openwrt-aw1000-phone](https://github.com/Perz3us/openwrt-aw1000-phone). Plug in a normal desk phone and make and take calls with the SIM in the 5G modem (VoLTE).

## Features

- Incoming and outgoing calls, dial tone, ringing tone and busy tone
- HD calling (16 kHz wideband audio), switched on in Settings
- Caller ID on phones with a display (FSK Bellcore, FSK ETSI or DTMF, before or after the first ring)
- Hold with the FLASH button, speed dial and blocked numbers
- Ring patterns: standard, short, double (UK and Australia) or custom
- The phone LED follows the line: ready, ringing and off hook
- Call history with search, filters, CSV export and optional auto delete
- LuCI pages for status, settings and a line test
- SIP calling through QModem voice (experimental, off by default). It needs QModem voice packages that are not in NoobWRT images; see [SIP calling](https://github.com/Perz3us/openwrt-aw1000-phone#sip-calling-experimental)

## Requirements

- AW1000 with the Quectel RG500Q-EA modem
- A NoobWRT `rj11` firmware image from [Releases](builds.md)
- A SIM with voice calls (VoLTE)
- The SLIC DSP patch file (see below)

## Packages

The `rj11` images include the three phone packages: `kmod-aw1000-fxs`, `fxsd` and `luci-app-fxs`. Check that they are installed:

```sh
apk list --installed | grep fxs
```

If they are missing, install them from the [openwrt-aw1000-phone releases](https://github.com/Perz3us/openwrt-aw1000-phone/releases) by following its [install steps](https://github.com/Perz3us/openwrt-aw1000-phone#install). Always install or update all three packages together.

## SLIC Patch File

The phone chip (Skyworks Si3226x) needs a DSP patch file every time it starts. This file belongs to Skyworks and is not open source, so it cannot be included in NoobWRT images.

See the [SLIC patch file](https://github.com/Perz3us/openwrt-aw1000-phone#slic-patch-file) section of openwrt-aw1000-phone for how to create it, then copy it to the router:

```sh
scp si3226x_patch.bin root@192.168.1.1:/etc/fxs/si3226x_patch.bin
```

## Turn On the Phone Port

Turn the port on in LuCI under `Services` then `Phone (RJ11)`, or run:

```sh
/etc/init.d/fxsd enable
/etc/init.d/fxsd start
```

## Modem Slave Mode

The modem audio interface must be in **slave mode**. From release `v2026-10-30` this is automatic: the phone service checks it every time it starts and sets it if needed. The first time, it restarts the modem, so the internet drops for about a minute, once. The modem remembers the setting. It also finds the modem AT port by itself, so nothing needs to be set up.

If the phone does not ring, or LuCI shows **"Modem audio not set to slave mode"**, set it by hand:

```sh
ubus call at-daemon sendat '{"at_port":"/dev/ttyUSB2","at_cmd":"AT+QDAI=x,1,0,4,0,0,1,1","timeout":3}'
ubus call at-daemon sendat '{"at_port":"/dev/ttyUSB2","at_cmd":"AT+CFUN=1,1","timeout":3}'
```

The second command restarts the modem. The modem remembers the setting after that.

To go back to the factory setting, run `AT+QDAI=x,0,0,4,0,0,1,1` the same way, then restart the modem again with `AT+CFUN=1,1`.

!!! tip "Older releases"
    On `v2026-10-24` and older images the phone service may not set slave mode by itself. Run the commands above once, or upgrade to the latest release.

## Settings

All settings are in LuCI under `Services` then `Phone (RJ11)`, with tabs for Status, Call history, Settings, Speed dial and Blocked numbers. The same settings are stored in `/etc/config/fxs`.

## Troubleshooting

- **Logs:** `logread -e fxsd`
- **Call log:** `/etc/fxs/calls.log`
- **Calls fail straight away:** the modem may have voice calls blocked by `call_control`. Check the [problems section](https://github.com/Perz3us/openwrt-aw1000-phone#problems) of openwrt-aw1000-phone.
- **VoLTE never registers:** some units have `sms_only` set in the modem. See the same problems section.
- **fxsd does not start after a reboot during startup:** run `/etc/init.d/fxsd clear_guard` or press the button in LuCI.
