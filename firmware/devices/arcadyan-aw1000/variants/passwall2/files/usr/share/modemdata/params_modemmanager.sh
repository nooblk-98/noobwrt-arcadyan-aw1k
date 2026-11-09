#!/bin/sh

#
# (c) 2025-2026 Cezary Jackiewicz <cezary@eko.one.pl>
#

DEVICE=$1
if [ -z "$DEVICE" ]; then
	echo '{"error":"Device not found"}'
	exit 0
fi

FORCE_PLMN=$2
[ "x$FORCE_PLMN" = "x1" ] || FORCE_PLMN=""

. /usr/share/libubox/jshn.sh

mmcli -m "$DEVICE" --signal-setup=3 >/dev/null 2>&1

json_load "$(mmcli -m "$DEVICE" -J --get-cell-info 2>/dev/null | jsonfilter -q -e '@.modem.*')" 2>/dev/null
if json_is_a "cell-info" array; then
	json_select "cell-info"
	idx=1
	while json_is_a ${idx} string; do
		json_get_var line $idx
		if echo "$line" | grep -q "serving: yes"; then
			IFS=','
			for F in $line; do
				KEY=""
				VAL=""
				eval $(echo "$F" | awk -F: '{gsub(" ", "");printf "KEY=%s, VAL=%s\n", $1, $2}')
				case "$KEY" in
					"celltype")
						MODE=$VAL
						_MODE=$(echo "$VAL" | tr 'a-z' 'A-Z')
						case "$_MODE" in
							"LTE")
								MODE_NUM=7
								;;
							"UMTS")
								MODE_NUM=2
								;;
						esac
						;;
					"operatorid")
						COPS_NUM=$VAL
						_plmn_mcc=${COPS_NUM:0:3}
						_plmn_mnc=${COPS_NUM:3:3}
						_plmn_mnc=$(printf "%02d" $_plmn_mnc)
						;;
					"tac")
						_TAC=$VAL
						_TAC_DEC=$(printf "%d" "0x$_TAC")
						;;
					"ci")
						_CELLID=$VAL
						_CELLID_DEC=$(printf "%d" "0x$_CELLID")
						;;
					"physicalci")
						_pci=$(printf "%d" "0x$VAL")
						;;
					"earfcn")
						_earfcn=$VAL
						;;
					"rsrp")
						_rsrp=$VAL
						;;
					"rsrq")
						_rsrq=$VAL
						;;
				esac
			done
			break
		fi
		idx=$((idx + 1))
	done
fi

_SIGNAL=0

SIGNAL_JSON=$(mmcli -m "$DEVICE" -J --signal-get 2>/dev/null)
if [ -z "$MODE" ]; then
	for TECH in lte umts; do
		trsrp=$(jsonfilter -s "$SIGNAL_JSON" -e "@.modem.signal.$TECH.rsrp" 2>/dev/null)
		trssi=$(jsonfilter -s "$SIGNAL_JSON" -e "@.modem.signal.$TECH.rssi" 2>/dev/null)
		if { [ "$trsrp" != "--" ] && [ -n "$trsrp" ]; } || { [ "$trssi" != "--" ] && [ -n "$trssi" ]; } then
			case "$TECH" in
				"lte")
					_MODE="LTE"
					MODE=$TECH
					MODE_NUM=7
					;;
				"umts")
					_MODE="UMTS"
					MODE=$TECH
					MODE_NUM=2
					;;
			esac
			break
		fi
	done
fi

T=$(jsonfilter -s "$SIGNAL_JSON" -q -e '@.modem.signal.'$MODE)
if [ -n "$T" ]; then
	_rsrp=""
	_rseq=""
	_rssi=""
	_snr=""
	_rscp=""
	_ecio=""
	eval $(jsonfilter -s "$T" -q -e "_rsrp=@.rsrp" -e "_rsrq=@.rsrq" -e "_rssi=@.rssi" -e "_snr=@.snr" -e "_rscp=@.rscp" -e "_ecio=@.ecio")
	if [ -n "$_rssi" ] && [ "$_rssi" != "--" ]; then
		_rssi=$(echo "$_rssi" | awk '{printf "%d\n", $1}')
		[ "$_rssi" -ge -51 ] && _rssi=-51
		_SIGNAL=$(((_rssi+113)*100/62))
	fi
fi

T=$(mmcli -m "$DEVICE" -J 2>/dev/null)
if [ -n "$FORCE_PLMN" ]; then
	_plmn_description=$(awk -F[\;] '/^'$COPS_NUM';/ {print $3}' /usr/share/modemdata/libs/mccmnc.dat)
	[ -z "$_plmn_description" ] && _plmn_description="$COPS_NUM"
else
	_plmn_description=$(jsonfilter -s "$T" -q -e "@.modem['3gpp']['operator-name']")
fi
REG=$(jsonfilter -s "$T" -q -e "@.modem['3gpp']['registration-state']")
case "$REG" in
	"home")
		_registration=1
		;;
	*)
		_registration=0
		;;
esac

# LTE CA and 5G NSA details via ModemManager's shared QMI access (qmicli -p)
QEXTRA=""
SQ="'"
qadd() { QEXTRA="${QEXTRA}{\"idx\":$1,\"key\":\"$2\",\"value\":\"$3\"},"; }
QDEV=/dev/$(mmcli -m "$DEVICE" -J 2>/dev/null | jsonfilter -q -e '@.modem.generic["primary-port"]')
if [ -c "$QDEV" ] && command -v qmicli >/dev/null 2>&1; then
	CA=$(qmicli -p -d "$QDEV" --nas-get-lte-cphy-ca-info 2>/dev/null)
	PB=$(echo "$CA" | awk -F"$SQ" '/Primary Cell Info/{p=1} p&&/LTE Band/{sub("eutran-","B",$2);print $2;exit}')
	PW=$(echo "$CA" | awk -F"$SQ" '/Primary Cell Info/{p=1} p&&/DL Bandwidth/{print $2;exit}')
	[ -n "$PB" ] && qadd 30 "Primary band" "$PB"
	[ -n "$PW" ] && qadd 32 "Bandwidth" "$PW MHz"
	N=0
	SCELLS=$(echo "$CA" | awk -F"$SQ" '/Secondary Cell/{b="";w="";c="";ch=""} /Physical Cell ID/{c=$2} /RX Channel/{ch=$2} /LTE Band/{b=$2} /DL Bandwidth/{w=$2} /State/{if($2=="activated"){sub("eutran-","B",b);print b"|"w"|"c"|"ch}}')
	# Quectel AT fallback for qmicli versions without cphy CA support.
	if [ -z "$PB" ]; then
		_QCA=$(mmcli -m "$DEVICE" --command='AT+QCAINFO' 2>/dev/null)
		if [ -n "$_QCA" ]; then
			_OLDIFS=$IFS
			IFS='
'
			for _L in $(echo "$_QCA" | sed -n 's/^.*+QCAINFO: //p'); do
				IFS=','
				set -- $_L
				IFS=$_OLDIFS
				_TYPE=$(echo "$1" | tr -d '"\r')
				_EARFCN=$(echo "$2" | tr -d '"\r')
				_BW=$(echo "$3" | tr -d '"\r')
				_BAND=$(echo "$4" | tr -d '"\r')
				_PCI=$(echo "$6" | tr -d '"\r')
				case "$_BW" in
					6) _MHZ=1.4 ;;
					15) _MHZ=3 ;;
					25) _MHZ=5 ;;
					50) _MHZ=10 ;;
					75) _MHZ=15 ;;
					100) _MHZ=20 ;;
					*) _MHZ=$_BW ;;
				esac
				case "$_BAND" in
					"LTE BAND "*)
						_B="B${_BAND#LTE BAND }"
						case "$_TYPE" in
							PCC)
								PB=$_B
								PW=$_MHZ
								;;
							SCC)
								SCELLS="${SCELLS}${SCELLS:+
}${_B}|${_MHZ}|${_PCI}|${_EARFCN}"
								;;
						esac
						;;
				esac
			done
			IFS=$_OLDIFS
		fi
	fi
	_OIFS=$IFS
	IFS='
'
	for L in $SCELLS; do
		N=$((N + 1)); I=$((40 + N * 10))
		qadd $I "(S$N) band" "${L%%|*}"; L=${L#*|}
		qadd $((I + 2)) "(S$N) Bandwidth" "${L%%|*} MHz"; L=${L#*|}
		qadd $((I + 3)) "(S$N) PCI" "${L%%|*}"; L=${L#*|}
		qadd $((I + 4)) "(S$N) EARFCN" "$L"
	done
	IFS=$_OIFS
	NR=$(qmicli -p -d "$QDEV" --nas-get-cell-location-info 2>/dev/null | awk -F"$SQ" '/5GNR ARFCN/{print $2;exit}')
	if [ -n "$NR" ] && [ "$NR" -gt 0 ] 2>/dev/null; then
		if [ "$NR" -lt 600000 ]; then F=$((NR * 5 / 1000)); else F=$((3000 + (NR - 600000) * 15 / 1000)); fi
		NB="NR ($F MHz)"
		[ "$F" -ge 3300 ] && [ "$F" -le 3800 ] && NB="n78"
		_MODE="5G NSA"
		[ -n "$PB" ] && _MODE="5G NSA ($PB + $NB)"
		N=$((N + 1)); I=$((40 + N * 10))
		qadd $I "(S$N) band" "$NB"
		qadd $((I + 4)) "(S$N) EARFCN" "$NR"
		SIG=$(qmicli -p -d "$QDEV" --nas-get-signal-info 2>/dev/null | awk '/^5G:/{p=1;next} /^[A-Z]/{p=0} p')
		V=$(echo "$SIG" | awk -F"$SQ" '/RSRP/{print $2;exit}'); [ -n "$V" ] && qadd $((I + 6)) "(S$N) RSRP" "$V"
		V=$(echo "$SIG" | awk -F"$SQ" '/RSRQ/{print $2;exit}'); [ -n "$V" ] && qadd $((I + 7)) "(S$N) RSRQ" "$V"
		V=$(echo "$SIG" | awk -F"$SQ" '/SNR/{print $2;exit}'); [ -n "$V" ] && qadd $((I + 8)) "(S$N) SNR" "$V"
	fi
fi

echo "{"
echo "\"signal\":\"$_SIGNAL\","
echo "\"operator_name\":\"$_plmn_description\","
echo "\"operator_mcc\":\"$_plmn_mcc\","
echo "\"operator_mnc\":\"$_plmn_mnc\","
[ -n "$COPS_NUM" ] && COUNTRY=$(awk -F[\;] '/^'$COPS_NUM';/ {print $2}' /usr/share/modemdata/libs/mccmnc.dat)
echo "\"country\":\"$COUNTRY\","
echo "\"mode\":\"$_MODE\","
echo "\"registration\":\"$_registration\","
echo "\"lac_dec\":\"\",\"lac_hex\":\"\",\"cid_dec\":\"${_CELLID_DEC}\",\"cid_hex\":\"${_CELLID}\",\"addon\":["
ADDON=""
[ -n "$_rssi" ] && [ "$_rssi" != "--" ] && ADDON="${ADDON}{\"idx\":35,\"key\":\"RSSI\",\"value\":\"$(printf "%.1f" $_rssi) dBm\"},"
if [ "$MODE_NUM" = "7" ]; then
	[ -n "$_rsrp" ] && [ "$_rsrp" != "--" ] && ADDON="${ADDON}{\"idx\":36,\"key\":\"RSRP\",\"value\":\"$(printf "%.1f" $_rsrp) dBm\"},"
	[ -n "$_rsrq" ] && [ "$_rsrq" != "--" ] && ADDON="${ADDON}{\"idx\":37,\"key\":\"RSRQ\",\"value\":\"$(printf "%.1f" $_rsrq) dB\"},"
	[ -n "$_snr" ] && [ "$_snr" != "--" ] && ADDON="${ADDON}{\"idx\":38,\"key\":\"SNR\",\"value\":\"$(printf "%.1f" $_snr) dB\"},"
	[ -n "$_TAC" ] && ADDON="${ADDON}{\"idx\":23,\"key\":\"TAC\",\"value\":\"${_TAC_DEC} (${_TAC})\"},"
fi
if [ "$MODE_NUM" = "2" ]; then
	[ -n "$_ecio" ] && ADDON="${ADDON}{\"idx\":36,\"key\":\"ECIO\",\"value\":\"$_ecio dB\"},"
fi
[ -n "$_pci" ] && ADDON="${ADDON}{\"idx\":33,\"key\":\"PCI\",\"value\":\"$_pci\"},"
[ -n "$_earfcn" ] && ADDON="${ADDON}{\"idx\":34,\"key\":\"EARFCN\",\"value\":\"$_earfcn\"},"
ADDON=${ADDON}${QEXTRA}
[ -n "$ADDON" ] && echo "${ADDON%,*}"
echo "]}"

exit 0
