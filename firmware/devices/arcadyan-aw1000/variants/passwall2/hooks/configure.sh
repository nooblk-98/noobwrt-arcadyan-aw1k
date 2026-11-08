#!/usr/bin/env bash
set -euo pipefail
KCONF="$BUILD_DIR/target/linux/qualcommax/config-6.12"
[ -f "$KCONF" ] || { echo "ERROR: AW1000 kernel config changed" >&2; exit 1; }
sed -i '/CONFIG_SPI_SPIDEV/d' "$KCONF"
echo 'CONFIG_SPI_SPIDEV=y' >> "$KCONF"
TARGET_MK="$BUILD_DIR/target/linux/qualcommax/Makefile"
if ! grep -qE '^FEATURES:=.*\baudio\b' "$TARGET_MK"; then
  sed -i -E 's/^(FEATURES:=.*)$/\1 audio/' "$TARGET_MK"
fi
