#!/usr/bin/env bash
# Prints one JSON line every 2 seconds for the shell to read.
pt=0; pi=0; prx=0; ptx=0
esc() { sed 's/\\/\\\\/g; s/"/\\"/g'; }
while true; do
  # cpu
  read -r _ u n s i io irq sirq st _ < /proc/stat
  t=$((u+n+s+i+io+irq+sirq+st)); idle=$((i+io))
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
  # network
  read -r rx tx < <(sed 's/:/ /' /proc/net/dev | awk 'NR>2 && $1!="lo"{r+=$2; t+=$10} END{print r+0, t+0}')
  rxKB=0; txKB=0
  if [ "$prx" -gt 0 ]; then rxKB=$(( (rx-prx)/2048 )); txKB=$(( (tx-ptx)/2048 )); fi
  prx=$rx; ptx=$tx
  iface=$(ip -o route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' | head -1); iface=${iface:-none}
  # battery (combines BAT0 + BAT1 on ThinkPads with the external battery)
  bat=-1; batState=""; tn=0; tf=0; st=""
  for b in /sys/class/power_supply/BAT*; do
    [ -d "$b" ] || continue
    if [ -r "$b/energy_now" ] && [ -r "$b/energy_full" ]; then n=$(cat "$b/energy_now"); f=$(cat "$b/energy_full")
    elif [ -r "$b/charge_now" ] && [ -r "$b/charge_full" ]; then n=$(cat "$b/charge_now"); f=$(cat "$b/charge_full")
    else continue; fi
    tn=$((tn+n)); tf=$((tf+f))
    s=$(cat "$b/status" 2>/dev/null)
    case "$s" in
      Charging) st="Charging" ;;
      Discharging) [ "$st" != "Charging" ] && st="Discharging" ;;
      *) [ -z "$st" ] && st="$s" ;;
    esac
  done
  if [ "$tf" -gt 0 ]; then bat=$(( 100*tn/tf )); batState=$st; fi
  # volume
  vol=0; muted=false
  vl=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
  if [ -n "$vl" ]; then
    vol=$(echo "$vl" | awk '{printf "%d", $2*100}')
    echo "$vl" | grep -q MUTED && muted=true
  fi
  # now playing
  media=$(playerctl metadata --format '{{artist}} — {{title}}' 2>/dev/null | esc)
  printf '{"cpu":%d,"memPct":%d,"memUsed":%s,"memTotal":%s,"diskPct":%d,"tempC":%d,"freqGHz":%s,"rxKB":%d,"txKB":%d,"iface":"%s","bat":%d,"batState":"%s","vol":%d,"muted":%s,"media":"%s"}\n' \
    "$cpu" "$memPct" "$memUsed" "$memTotal" "$diskPct" "$tempC" "${freqGHz:-0}" "$rxKB" "$txKB" "$iface" "$bat" "$batState" "$vol" "$muted" "$media"
  sleep 2
done
