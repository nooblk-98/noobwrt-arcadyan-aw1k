#!/bin/sh
#=================================================
# Copyright (c) 2026 Lahiru S Liyanage (NoobLK) <liyanagelsofficial@gmail.com>
# GitHub: https://github.com/nooblk-98/luci-app-aw1k-led
# Telegram: @itsme_nooblk
# License: GPL-3.0-or-later
#=================================================

# AW1000 LED Status Monitor
# Reads thresholds, colors and settings from UCI: uci get ledstatus.settings.*

# ─── Color → sysfs helper ────────────────────────────────────────────────────
# set_color <prefix> <colorid> [blink]
#   prefix  : 5g | signal
#   colorid : red|green|blue|yellow|cyan|magenta|white|off
#   blink   : if "1", use heartbeat trigger on lit channels
set_color() {
    local PREFIX="$1"
    local COLOR="$2"
    local BLINK="$3"

    case "$COLOR" in
        red)     R=1; G=0; B=0 ;;
        green)   R=0; G=1; B=0 ;;
        blue)    R=0; G=0; B=1 ;;
        yellow)  R=1; G=1; B=0 ;;
        cyan)    R=0; G=1; B=1 ;;
        magenta) R=1; G=0; B=1 ;;
        white)   R=1; G=1; B=1 ;;
        *)       R=0; G=0; B=0 ;;   # off / unknown
    esac

    for CH in red green blue; do
        eval "VAL=\$$( echo $CH | tr 'rgb' 'RGB' | tr '[:lower:]' '[:upper:]' | cut -c1)"
        # re-evaluate correctly
        case "$CH" in
            red)   VAL=$R ;;
            green) VAL=$G ;;
            blue)  VAL=$B ;;
        esac
        LED="/sys/class/leds/${CH}:${PREFIX}"
        if [ "$BLINK" = "1" ] && [ "$VAL" = "1" ]; then
            echo heartbeat > "$LED/trigger"
        else
            echo none       > "$LED/trigger"
            echo "$VAL"     > "$LED/brightness"
        fi
    done
}

# ─── Load UCI settings ────────────────────────────────────────────────────────
PORT_CACHE="/tmp/led-at-port"
PORT_CFG=$(uci get ledstatus.settings.modem_port 2>/dev/null)
[ -z "$PORT_CFG" ] && PORT_CFG="auto"

# The modem has more than one AT port (ttyUSB2/ttyUSB3 on the RG500Q) and
# one can stop answering for a while, which left the 5G/signal LEDs dark
# with a fixed port. Try the last port that answered first, then the
# configured port and QModem's AT ports. Every ttyUSB is only tried when
# QModem lists none: the others (DIAG, NMEA) never answer and each one
# costs a 5 s sms_tool timeout, which held the LEDs on stale colors.
# The cache is keyed on the setting so changing it takes effect on the
# next check.
at_candidates() {
    local cached_cfg cached_port qmodem_ports
    read -r cached_cfg cached_port 2>/dev/null < "$PORT_CACHE"
    [ "$cached_cfg" = "$PORT_CFG" ] && echo "$cached_port"
    [ "$PORT_CFG" != "auto" ] && echo "$PORT_CFG"
    qmodem_ports=$(uci -q show qmodem | sed -n "s/.*\.\(at_port\|valid_at_ports\)=//p" | tr -d "'")
    if [ -n "$qmodem_ports" ]; then
        echo "$qmodem_ports"
    else
        ls /dev/ttyUSB* 2>/dev/null
    fi
}

# at_cmd <command> <reply prefix>: print the reply from the first port that
# answers with <reply prefix>; print nothing if none does.
at_cmd() {
    local port out seen=" "
    for port in $(at_candidates); do
        [ -c "$port" ] || continue
        case "$seen" in *" $port "*) continue ;; esac
        seen="$seen$port "
        out=$(sms_tool -d "$port" at "$1" 2>/dev/null | tr -d '\r')
        if echo "$out" | grep -qi "^$2"; then
            echo "$PORT_CFG $port" > "$PORT_CACHE"
            echo "$out"
            return 0
        fi
    done
    return 1
}

SINR_EXCELLENT=$(uci get ledstatus.settings.sinr_excellent 2>/dev/null); [ -z "$SINR_EXCELLENT" ] && SINR_EXCELLENT=25
SINR_GOOD=$(uci get ledstatus.settings.sinr_good       2>/dev/null); [ -z "$SINR_GOOD"      ] && SINR_GOOD=15
SINR_AVERAGE=$(uci get ledstatus.settings.sinr_average    2>/dev/null); [ -z "$SINR_AVERAGE"   ] && SINR_AVERAGE=5

CSQ_EXCELLENT=$(uci get ledstatus.settings.csq_excellent 2>/dev/null); [ -z "$CSQ_EXCELLENT"  ] && CSQ_EXCELLENT=20
CSQ_GOOD=$(uci get ledstatus.settings.csq_good      2>/dev/null); [ -z "$CSQ_GOOD"       ] && CSQ_GOOD=14
CSQ_AVERAGE=$(uci get ledstatus.settings.csq_average   2>/dev/null); [ -z "$CSQ_AVERAGE"    ] && CSQ_AVERAGE=10

# 5G colors
C5G_EXCELLENT=$(uci get ledstatus.settings.color_5g_excellent 2>/dev/null); [ -z "$C5G_EXCELLENT" ] && C5G_EXCELLENT=green
C5G_GOOD=$(uci get ledstatus.settings.color_5g_good      2>/dev/null); [ -z "$C5G_GOOD"      ] && C5G_GOOD=blue
C5G_AVERAGE=$(uci get ledstatus.settings.color_5g_average   2>/dev/null); [ -z "$C5G_AVERAGE"   ] && C5G_AVERAGE=yellow
C5G_POOR=$(uci get ledstatus.settings.color_5g_poor      2>/dev/null); [ -z "$C5G_POOR"      ] && C5G_POOR=blue
C5G_NONE=$(uci get ledstatus.settings.color_5g_none      2>/dev/null); [ -z "$C5G_NONE"      ] && C5G_NONE=red

# Signal colors
CSIG_EXCELLENT=$(uci get ledstatus.settings.color_sig_excellent 2>/dev/null); [ -z "$CSIG_EXCELLENT" ] && CSIG_EXCELLENT=green
CSIG_GOOD=$(uci get ledstatus.settings.color_sig_good      2>/dev/null); [ -z "$CSIG_GOOD"      ] && CSIG_GOOD=blue
CSIG_AVERAGE=$(uci get ledstatus.settings.color_sig_average   2>/dev/null); [ -z "$CSIG_AVERAGE"   ] && CSIG_AVERAGE=yellow
CSIG_WEAK=$(uci get ledstatus.settings.color_sig_weak      2>/dev/null); [ -z "$CSIG_WEAK"      ] && CSIG_WEAK=red
CSIG_OFFLINE=$(uci get ledstatus.settings.color_sig_offline   2>/dev/null); [ -z "$CSIG_OFFLINE"   ] && CSIG_OFFLINE=magenta

# ─── 5G SINR ─────────────────────────────────────────────────────────────────
QENG_DATA=$(at_cmd 'at+qeng="servingcell"' '+qeng:')
QENG_LINE=$(echo "$QENG_DATA" | grep -E 'QENG: "NR5G' | head -n1)
SINR=$(echo "$QENG_LINE" | awk -F',' '{print $6}' | grep -oE '[-0-9.]+')

set_color 5g off

if [ -z "$SINR" ]; then
    set_color 5g "$C5G_NONE"
    echo "5G: NO SIGNAL"
else
    SINR_INT=$(printf "%.0f" "$SINR" 2>/dev/null)
    if   [ "$SINR_INT" -ge "$SINR_EXCELLENT" ]; then
        set_color 5g "$C5G_EXCELLENT"
        echo "5G: Excellent (SINR=$SINR_INT color=$C5G_EXCELLENT)"
    elif [ "$SINR_INT" -ge "$SINR_GOOD" ]; then
        set_color 5g "$C5G_GOOD"
        echo "5G: Good (SINR=$SINR_INT color=$C5G_GOOD)"
    elif [ "$SINR_INT" -ge "$SINR_AVERAGE" ]; then
        set_color 5g "$C5G_AVERAGE"
        echo "5G: Average (SINR=$SINR_INT color=$C5G_AVERAGE)"
    else
        set_color 5g "$C5G_POOR"
        echo "5G: Poor/blink (SINR=$SINR_INT color=$C5G_POOR)"
    fi
fi

# ─── Internet connection ──────────────────────────────────────────────────────
# Any default route counts, whatever the modem's network device is called
# (wwan0, wwan0_1, rmnet_mhi0, qmimux0, ...): QModem names it per modem and
# per release, and a fixed name left the internet LED blinking for good.
found=0
{ ip -4 route show default; ip -6 route show default; } 2>/dev/null | grep -q '^default' && found=1

if [ "$found" -eq 1 ]; then
    echo none > /sys/class/leds/green:internet/trigger
    echo 1    > /sys/class/leds/green:internet/brightness
    echo "Internet: Connected"
else
    echo heartbeat > /sys/class/leds/green:internet/trigger
    echo "Internet: Not connected"
fi

# ─── WiFi ─────────────────────────────────────────────────────────────────────
# Follow what netifd reports for the radios, not just the config: a radio
# that is enabled but failed to come up (e.g. a broken /etc/board.json)
# used to show solid on. On = a radio is up, blink = enabled but none is
# up, off = all radios disabled.
WIFI_STATUS=$(ubus call network.wireless status 2>/dev/null)
WIFI_UP=$(echo "$WIFI_STATUS" | jsonfilter -e '@.*.up' 2>/dev/null | grep -c true)
WIFI_ENABLED=$(echo "$WIFI_STATUS" | jsonfilter -e '@.*.disabled' 2>/dev/null | grep -c false)
if [ "$WIFI_UP" -gt 0 ]; then
    echo none > /sys/class/leds/green:wifi/trigger
    echo 1    > /sys/class/leds/green:wifi/brightness
    echo "WiFi: Up"
elif [ "$WIFI_ENABLED" -gt 0 ]; then
    echo heartbeat > /sys/class/leds/green:wifi/trigger
    echo "WiFi: Enabled but not up"
else
    echo none > /sys/class/leds/green:wifi/trigger
    echo 0    > /sys/class/leds/green:wifi/brightness
    echo "WiFi: Disabled"
fi

# ─── Phone ───────────────────────────────────────────────────────────────────
# The phone service (aw1000-rj11) sets the phone LED on every line change;
# re-sync it here in case something else touched it. fxsd (openwrt-aw1000-phone)
# drives the LED itself and re-asserts it, so leave it alone while fxsd runs.
# Off without a phone service.
if [ -x /usr/sbin/rj11_led ]; then
    /usr/sbin/rj11_led
    echo "Phone: LED follows the phone line"
elif pidof fxsd >/dev/null 2>&1; then
    echo "Phone: LED driven by fxsd"
else
    echo none > /sys/class/leds/green:phone/trigger
    echo 0    > /sys/class/leds/green:phone/brightness
    echo "Phone: not installed, LED off"
fi

# ─── CSQ Signal ───────────────────────────────────────────────────────────────
CSQ=$(at_cmd 'at+csq' '+csq:' \
    | grep -oE '\+csq: [0-9]+,[0-9]+' \
    | awk -F'[:,]' '{print $2}' \
    | tr -d '\r\n ')
# 99 = not known or not detectable
[ "$CSQ" = "99" ] && CSQ=""

set_color signal off

if [ "$found" -eq 1 ]; then
    if [ -n "$CSQ" ]; then
        if   [ "$CSQ" -ge "$CSQ_EXCELLENT" ]; then
            set_color signal "$CSIG_EXCELLENT"
            echo "Signal: Excellent (CSQ=$CSQ color=$CSIG_EXCELLENT)"
        elif [ "$CSQ" -ge "$CSQ_GOOD" ]; then
            set_color signal "$CSIG_GOOD"
            echo "Signal: Good (CSQ=$CSQ color=$CSIG_GOOD)"
        elif [ "$CSQ" -ge "$CSQ_AVERAGE" ]; then
            set_color signal "$CSIG_AVERAGE"
            echo "Signal: Average (CSQ=$CSQ color=$CSIG_AVERAGE)"
        else
            set_color signal "$CSIG_WEAK"
            echo "Signal: Weak/blink (CSQ=$CSQ color=$CSIG_WEAK)"
        fi
    else
        echo "Signal: CSQ not detected"
    fi
else
    set_color signal "$CSIG_OFFLINE"
    echo "Signal: Internet disconnected (color=$CSIG_OFFLINE)"
fi
