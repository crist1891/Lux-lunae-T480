#!/usr/bin/env bash
# Prints one JSON line every 2 seconds for the shell to read.
pt=0; pi=0; prx=0; ptx=0; n=0; btOn=false; btDev=""
esc() { sed 's/\\/\\\\/g; s/"/\\"/g'; }
battery() {  # $1 = BAT0 / BAT1  ->  "pct state"  (pct = -1 when absent)
  local b="/sys/class/power_supply/$1" nn ff
  [ -d "$b" ] || { echo "-1 "; return; }
  if [ -r "$b/energy_now" ] && [ -r "$b/energy_full" ]; then nn=$(cat "$b/energy_now"); ff=$(cat "$b/energy_full")
  elif [ -r "$b/charge_now" ] && [ -r "$b/charge_full" ]; then nn=$(cat "$b/charge_now"); ff=$(cat "$b/charge_full")
  else echo "-1 "; return; fi
  [ "${ff:-0}" -gt 0 ] || { echo "-1 "; return; }
  echo "$(( 100*nn/ff )) $(tr ' ' '_' < "$b/status" 2>/dev/null)"
}
while true; do
  # cpu
  read -r _ u nc s i io irq sirq st _ < /proc/stat
  t=$((u+nc+s+i+io+irq+sirq+st)); idle=$((i+io))
  dt=$((t-pt)); di=$((idle-pi)); pt=$t; pi=$idle
  cpu=0; [ "$dt" -gt 0 ] && cpu=$(( 100*(dt-di)/dt ))
  # memory (GiB)
  read -r mt ma < <(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{print t, a}' /proc/meminfo)
  memPct=$(( 100*(mt-ma)/mt ))
  memUsed=$(awk -v t="$mt" -v a="$ma" 'BEGIN{printf "%.1f",(t-a)/1048576}')
  memTotal=$(awk -v t="$mt" 'BEGIN{printf "%.1f",t/1048576}')
  # disk
  diskPct=$(df / --output=pcent | tail -1 | tr -dc '0-9'); diskPct=${diskPct:-0}
  # temperature (hottest thermal zone), -1 if none
  tempC=-1
  for z in /sys/class/thermal/thermal_zone*/temp; do
    [ -r "$z" ] || continue; v=$(( $(cat "$z") / 1000 )); [ "$v" -gt "$tempC" ] && tempC=$v
  done
  # cpu frequency (GHz), 0 if unavailable
  freqGHz=$(cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq 2>/dev/null | awk '{s+=$1;n++} END{if(n) printf "%.2f", s/n/1000000; else print 0}')
  # network throughput
  read -r rx tx < <(sed 's/:/ /' /proc/net/dev | awk 'NR>2 && $1!="lo"{r+=$2; t+=$10} END{print r+0, t+0}')
  rxKB=0; txKB=0
  if [ "$prx" -gt 0 ]; then rxKB=$(( (rx-prx)/2048 )); txKB=$(( (tx-ptx)/2048 )); fi
  prx=$rx; ptx=$tx
  iface=$(ip -o route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' | head -1); iface=${iface:-none}
  # wi-fi name + signal (works with NetworkManager, iwd or wpa_supplicant)
  ssid=""; sigPct=0
  wif=$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2; exit}')
  if [ -n "$wif" ]; then
    link=$(iw dev "$wif" link 2>/dev/null)
    ssid=$(echo "$link" | awk -F': ' '/^[[:space:]]*SSID:/{print $2; exit}')
    dbm=$(echo "$link" | awk '/signal:/{print $2; exit}')
    [ -n "$dbm" ] && sigPct=$(( 2*(dbm+100) )) && [ "$sigPct" -gt 100 ] && sigPct=100
    [ "$sigPct" -lt 0 ] && sigPct=0
  fi
  if [ -z "$ssid" ] && command -v nmcli >/dev/null 2>&1; then
    ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')
  fi
  # bluetooth (every other round)
  if [ $((n % 2)) -eq 0 ] && command -v bluetoothctl >/dev/null 2>&1; then
    btOn=false; timeout 1 bluetoothctl show 2>/dev/null | grep -q "Powered: yes" && btOn=true
    btDev=$(timeout 1 bluetoothctl devices Connected 2>/dev/null | sed 's/^Device [0-9A-Fa-f:]* //' | paste -sd'|')
  fi
  n=$((n+1))
  # batteries: BAT0 and BAT1 reported separately; "bat" is the combined figure for the top bar
  read -r b0 b0s < <(battery BAT0); read -r b1 b1s < <(battery BAT1)
  bat=-1; batState=""
  tn=0; tf=0
  for b in /sys/class/power_supply/BAT*; do
    [ -d "$b" ] || continue
    if [ -r "$b/energy_now" ] && [ -r "$b/energy_full" ]; then nn=$(cat "$b/energy_now"); ff=$(cat "$b/energy_full")
    elif [ -r "$b/charge_now" ] && [ -r "$b/charge_full" ]; then nn=$(cat "$b/charge_now"); ff=$(cat "$b/charge_full")
    else continue; fi
    tn=$((tn+nn)); tf=$((tf+ff))
    s=$(cat "$b/status" 2>/dev/null)
    case "$s" in Charging) batState="Charging" ;; Discharging) [ "$batState" != "Charging" ] && batState="Discharging" ;; *) [ -z "$batState" ] && batState="$s" ;; esac
  done
  [ "$tf" -gt 0 ] && bat=$(( 100*tn/tf ))
  # now playing
  media=$(playerctl metadata --format '{{artist}} — {{title}}' 2>/dev/null | esc)
  printf '{"cpu":%d,"memPct":%d,"memUsed":%s,"memTotal":%s,"diskPct":%d,"tempC":%d,"freqGHz":%s,"rxKB":%d,"txKB":%d,"iface":"%s","ssid":"%s","sigPct":%d,"btOn":%s,"btDev":"%s","bat":%d,"batState":"%s","bat0":%d,"bat0State":"%s","bat1":%d,"bat1State":"%s","media":"%s"}\n' \
    "$cpu" "$memPct" "$memUsed" "$memTotal" "$diskPct" "$tempC" "${freqGHz:-0}" "$rxKB" "$txKB" "$iface" \
    "$(printf '%s' "$ssid" | esc)" "$sigPct" "$btOn" "$(printf '%s' "$btDev" | esc)" \
    "$bat" "$batState" "$b0" "$b0s" "$b1" "$b1s" "$media"
  sleep 2
done
