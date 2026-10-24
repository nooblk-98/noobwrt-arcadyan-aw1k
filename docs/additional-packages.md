# Additional Packages

Current NoobWRT builds use OpenWrt 25.12 with the **APK** package manager. Old `.ipk` packages and `opkg` commands do not work on these builds.

Only install packages built for OpenWrt 25.12 and the `aarch64_cortex-a53` architecture. Kernel modules (`kmod-*`) must match the exact kernel version of your firmware.

## Install Steps

1. Download the `.apk` file you need.
2. Upload the file to the router, for example into `/tmp`.
3. Install with SSH:

```sh
apk add --allow-untrusted /tmp/package-name.apk
```

## Install via Web UI

1. Go to `System` then `Software`.
2. Click `Upload Package`.
3. Select the `.apk` file.
4. Click `Install`.

## Verify

Check `System` then `Software` to confirm the package appears in the installed list, or run:

```sh
apk list --installed | grep package-name
```
