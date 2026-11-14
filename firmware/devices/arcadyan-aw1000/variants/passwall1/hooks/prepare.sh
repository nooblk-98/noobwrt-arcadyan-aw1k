#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# Phone software is feed-owned. Only runtime SLIC data is device-owned.
[ -f "${RJ11_PRIVATE_DIR:-/private}/si3226x_stock_tables.h" ] || {
  echo "ERROR: FXS requires private si3226x_stock_tables.h; feed does not include DSP patch" >&2
  exit 1
}
bash "$HERE/hooks/pins.sh"
# Immutable commit for the existing PassWall 26.1.1-1 release.
PASSWALL_DIR=""
for candidate in \
  "$BUILD_DIR/feeds/noobwrt/feeds/passwall/luci-app-passwall" \
  "$BUILD_DIR/feeds/passwall/luci-app-passwall"; do
  if [ -f "$candidate/Makefile" ]; then
    PASSWALL_DIR="$candidate"
    break
  fi
done
[ -n "$PASSWALL_DIR" ] || { echo "ERROR: feed PassWall1 package missing" >&2; exit 1; }
PW_TMP=$(mktemp -d)
trap 'rm -rf "$PW_TMP"' EXIT
git -C "$PW_TMP" init -q
git -C "$PW_TMP" remote add origin https://github.com/Openwrt-Passwall/openwrt-passwall.git
git -C "$PW_TMP" fetch --depth=1 origin 0d24d8fc24d9eb508a4df599a0a4d673c8a35cc7
git -C "$PW_TMP" checkout -q FETCH_HEAD
[ "$(git -C "$PW_TMP" rev-parse HEAD)" = 0d24d8fc24d9eb508a4df599a0a4d673c8a35cc7 ]
[ -f "$PW_TMP/luci-app-passwall/Makefile" ]
# Local fixes on top of the pinned release (e.g. the mwan3 coexistence backport).
# A patch that no longer applies fails the build instead of shipping unpatched.
for p in "$HERE"/patches/*.patch; do
  [ -f "$p" ] || continue
  git -C "$PW_TMP" apply --whitespace=nowarn "$p"
  echo "PassWall1 patch applied: $(basename "$p")"
done
rm -rf "$PASSWALL_DIR"
cp -a "$PW_TMP/luci-app-passwall" "$PASSWALL_DIR"
