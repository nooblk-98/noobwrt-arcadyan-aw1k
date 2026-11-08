#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# RJ11 software is provided by the feed. Only private DSP data is prepared here.
[ -f "${RJ11_PRIVATE_DIR:-/private}/si3226x_stock_tables.h" ] || {
  echo "ERROR: FXS requires private si3226x_stock_tables.h; feed does not include DSP patch" >&2
  exit 1
}
export GOLANG_FEED_COMMIT=126203ce37adc023d5f567e4ced71a97a3d4167b
export XRAY_CORE_VERSION=26.9.9
export XRAY_CORE_HASH=efb871a981690688191433a76beef7afdab6750d53cc1775cf8e9e995730ef22
export TAILSCALE_VERSION=1.104.1
export TAILSCALE_HASH=bf868b2b1a46b9485d55bcda12c2d7573279ce4474bc6d607f42f1495db36ed8
bash "$HERE/hooks/pins.sh"
# Immutable commit behind the existing PassWall2 26.9.16-1 pin.
PW2_DIR="$BUILD_DIR/feeds/noobwrt/feeds/passwall2/luci-app-passwall2"
[ -f "$PW2_DIR/Makefile" ] || { echo "ERROR: feed PassWall2 package missing" >&2; exit 1; }
PW2_TMP=$(mktemp -d)
trap 'rm -rf "$PW2_TMP"' EXIT
git -C "$PW2_TMP" init -q
git -C "$PW2_TMP" remote add origin https://github.com/Openwrt-Passwall/openwrt-passwall2.git
git -C "$PW2_TMP" fetch --depth=1 origin 9ee2b2b7d31b4a9193e6615b83e1ca93a395676e
git -C "$PW2_TMP" checkout -q FETCH_HEAD
[ "$(git -C "$PW2_TMP" rev-parse HEAD)" = 9ee2b2b7d31b4a9193e6615b83e1ca93a395676e ]
rm -rf "$PW2_DIR"
cp -a "$PW2_TMP/luci-app-passwall2" "$PW2_DIR"
