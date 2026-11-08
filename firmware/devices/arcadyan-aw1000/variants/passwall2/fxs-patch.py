#!/usr/bin/env python3
#=================================================
# Copyright (c) 2026 Lahiru S Liyanage (NoobLK) <liyanagelsofficial@gmail.com>
# GitHub: https://github.com/nooblk-98/wrt-builder-aw1000
# Telegram: @itsme_nooblk
# License: All rights reserved
#=================================================
"""Build the fxsd SLIC patch file from si3226x_stock_tables.h.

The fxs phone port (luci-app-fxs / fxsd from the noobwrt feed) loads the
Si3226x DSP patch from /etc/fxs/si3226x_patch.bin ("FXSP" format, see
tools/mkpatch.py in Perz3us/openwrt-aw1000-phone). The same patch (serial
0x05262017) is in the stock tables extracted for the aw1000-rj11 port, so
convert it from there instead of keeping a second private file.

usage: fxs-patch.py si3226x_stock_tables.h si3226x_patch.bin
"""
import re
import struct
import sys

MAGIC = b"FXSP"
ENTRIES = 16


def array(src, name):
    m = re.search(r"\b%s\s*\[\d*\]\s*=\s*\{(.*?)\};" % name, src, re.S)
    if not m:
        raise SystemExit("missing array %s" % name)
    body = re.sub(r"/\*.*?\*/", "", m.group(1), flags=re.S)
    return [int(v.rstrip("uUlL"), 0) for v in re.findall(r"0x[0-9A-Fa-f]+[uUlL]*|\b\d+[uUlL]*\b", body)]


def main():
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    src = open(sys.argv[1], encoding="latin-1").read()
    m = re.search(r"SI3226X_REVC_PATCH_SERIAL\s+(0x[0-9A-Fa-f]+)", src)
    if not m:
        raise SystemExit("missing SI3226X_REVC_PATCH_SERIAL")
    serial = int(m.group(1), 16)
    data = array(src, "si3226x_revc_patch_data")
    entries = array(src, "si3226x_revc_patch_entries")
    ps_addr = array(src, "si3226x_revc_psram_addr")
    ps_data = array(src, "si3226x_revc_psram_data")

    # The stock tables pad entries and support RAM with one trailing zero
    if any(entries[ENTRIES:]):
        raise SystemExit("expected %d patch entries, got %d" % (ENTRIES, len(entries)))
    entries = (entries + [0] * ENTRIES)[:ENTRIES]
    while ps_addr and ps_addr[-1] == 0:
        ps_addr.pop()
    if len(ps_data) < len(ps_addr):
        raise SystemExit("support address/data length mismatch")
    ps_data = ps_data[:len(ps_addr)]

    out = bytearray(MAGIC)
    out += struct.pack("<II", serial, len(data))
    out += struct.pack("<%dI" % len(data), *data)
    out += struct.pack("<%dH" % ENTRIES, *entries)
    out += struct.pack("<I", len(ps_addr))
    out += struct.pack("<%dH" % len(ps_addr), *ps_addr)
    out += struct.pack("<%dI" % len(ps_data), *ps_data)
    open(sys.argv[2], "wb").write(out)
    print("serial 0x%08x data %d entries %d support %d" % (serial, len(data), ENTRIES, len(ps_addr)))


if __name__ == "__main__":
    main()
