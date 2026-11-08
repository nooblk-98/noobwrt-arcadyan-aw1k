#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$BUILD_DIR/files/etc/fxs"
python3 "$HERE/fxs-patch.py" "${RJ11_PRIVATE_DIR:-/private}/si3226x_stock_tables.h" "$BUILD_DIR/files/etc/fxs/si3226x_patch.bin"
OVERVIEW_SCRIPT="$BUILD_DIR/files/etc/uci-defaults/99-init-settings"
if [ -f "$OVERVIEW_SCRIPT" ]; then
  BUILD_DATE="v${BUILD_TIMESTAMP%_*}"
  sed -i "s/NoobWRT [0-9.]\+/NoobWRT $OPENWRT_VERSION/" "$OVERVIEW_SCRIPT"
  sed -i "s/v[0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}/$BUILD_DATE/" "$OVERVIEW_SCRIPT"
fi
