#!/usr/bin/env bash
set -euo pipefail
# Preserve the PassWall1 branch Xray baseline; no PassWall2 Go/Tailscale override.
XRAY_MK="$BUILD_DIR/feeds/packages/net/xray-core/Makefile"
[ -f "$XRAY_MK" ] || { echo "ERROR: xray-core missing" >&2; exit 1; }
grep -q "^PKG_VERSION:=" "$XRAY_MK"
grep -q "^PKG_HASH:=" "$XRAY_MK"
sed -i \
  -e "s/^PKG_VERSION:=.*/PKG_VERSION:=25.12.8/" \
  -e "s/^PKG_HASH:=.*/PKG_HASH:=d4519b2d9bb1871f4d7612aa7a8db1c451573b5a44ac824219bb44d63f404e61/" \
  "$XRAY_MK"
echo "xray-core pinned: 25.12.8 (PassWall1 baseline)"
