#!/usr/bin/env bash
set -euo pipefail
if [ -n "$GOLANG_FEED_COMMIT" ]; then
    GOLANG_DIR="$BUILD_DIR/feeds/packages/lang/golang"
    GOLANG_TMP="$(mktemp -d)"
    echo "=== Overriding Go toolchain from openwrt/packages@${GOLANG_FEED_COMMIT:0:10} ==="
    git -C "$GOLANG_TMP" init -q
    git -C "$GOLANG_TMP" remote add origin https://github.com/openwrt/packages.git
    git -C "$GOLANG_TMP" sparse-checkout set lang/golang
    git -C "$GOLANG_TMP" fetch -q --depth=1 --filter=blob:none origin "$GOLANG_FEED_COMMIT"
    git -C "$GOLANG_TMP" checkout -q FETCH_HEAD
    rm -rf "$GOLANG_DIR"
    cp -a "$GOLANG_TMP/lang/golang" "$GOLANG_DIR"
    rm -rf "$GOLANG_TMP"
    # Re-index the packages feed so new/removed golang1.x packages are picked up
    cd "$BUILD_DIR"
    ./scripts/feeds update -i packages
    find "$BUILD_DIR/package/feeds/packages" -maxdepth 1 -xtype l -delete
    ./scripts/feeds install -a -p packages >/dev/null
    echo "Go default version: $(grep -m1 '^GO_DEFAULT_VERSION:=' "$GOLANG_DIR/golang-values.mk" | cut -d'=' -f2)"
fi

# -----------------------------------------------------------------------------
# Pin xray-core version (see XRAY_CORE_VERSION in compile.conf)
# Runs unconditionally (even with --skip-fetch) so a re-run always enforces
# the pin, even if a prior feeds update reset the Makefile to the feed's version.
# -----------------------------------------------------------------------------
if [ -n "$XRAY_CORE_VERSION" ]; then
    XRAY_MK="$BUILD_DIR/feeds/packages/net/xray-core/Makefile"
    if [ -f "$XRAY_MK" ]; then
        CURRENT_XRAY_VER=$(grep -m1 '^PKG_VERSION:=' "$XRAY_MK" | cut -d'=' -f2)
        if [ "$CURRENT_XRAY_VER" != "$XRAY_CORE_VERSION" ]; then
            sed -i "s/^PKG_VERSION:=.*/PKG_VERSION:=$XRAY_CORE_VERSION/" "$XRAY_MK"
            sed -i "s/^PKG_RELEASE:=.*/PKG_RELEASE:=1/" "$XRAY_MK"
            sed -i "s/^PKG_HASH:=.*/PKG_HASH:=$XRAY_CORE_HASH/" "$XRAY_MK"
            echo "xray-core pinned: $CURRENT_XRAY_VER -> $XRAY_CORE_VERSION"
        else
            echo "xray-core already pinned at $XRAY_CORE_VERSION"
        fi
    else
        echo "ERROR: xray-core missing" >&2; exit 1
    fi
fi

# -----------------------------------------------------------------------------
# Pin tailscale version (see TAILSCALE_VERSION in compile.conf)
# The feed's tailscale doesn't build with the Go 1.27 override above. Runs
# unconditionally (even with --skip-fetch) so a re-run always enforces the pin.
# -----------------------------------------------------------------------------
if [ -n "$TAILSCALE_VERSION" ]; then
    TS_MK="$BUILD_DIR/feeds/packages/net/tailscale/Makefile"
    if [ -f "$TS_MK" ]; then
        CURRENT_TS_VER=$(grep -m1 '^PKG_VERSION:=' "$TS_MK" | cut -d'=' -f2)
        if [ "$CURRENT_TS_VER" != "$TAILSCALE_VERSION" ]; then
            sed -i "s/^PKG_VERSION:=.*/PKG_VERSION:=$TAILSCALE_VERSION/" "$TS_MK"
            sed -i "s/^PKG_RELEASE:=.*/PKG_RELEASE:=1/" "$TS_MK"
            sed -i "s/^PKG_HASH:=.*/PKG_HASH:=$TAILSCALE_HASH/" "$TS_MK"
            echo "tailscale pinned: $CURRENT_TS_VER -> $TAILSCALE_VERSION"
        else
            echo "tailscale already pinned at $TAILSCALE_VERSION"
        fi
    else
        echo "ERROR: tailscale missing" >&2; exit 1
    fi
fi
