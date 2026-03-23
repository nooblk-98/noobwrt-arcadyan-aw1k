# Additional Packages

You can install extra packages from the custom NoobWRT feed.

## Install Steps

1. Download the desired `.ipk` from `https://feeds.itsnooblk.com/`.
2. Upload the file to the router, for example into `/tmp`.
3. Install with SSH:

```sh
opkg install /tmp/package-name.ipk
```

## Install via Web UI

1. Go to `System` then `Software`.
2. Click `Upload Package`.
3. Select the uploaded `.ipk` file.
4. Click `Install`.

## Verify

Check `System` then `Software` to confirm the package appears in the installed list.
