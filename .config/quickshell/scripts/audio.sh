#!/usr/bin/env bash
# Prints one JSON line now and again on every audio change (PipeWire via pactl subscribe).
# Also drives the ThinkPad mute / mic-mute LEDs, when the udev rule from install.sh is present.
led() { local f="/sys/class/leds/$1/brightness"; [ -w "$f" ] && echo "$2" > "$f" 2>/dev/null; return 0; }

emit() {
  local vl ml vol micvol muted=false micMuted=false
  vl=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
  ml=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)
  vol=$(echo "$vl" | awk '{printf "%d", $2*100}')
  micvol=$(echo "$ml" | awk '{printf "%d", $2*100}')
  echo "$vl" | grep -q MUTED && muted=true
  echo "$ml" | grep -q MUTED && micMuted=true
  printf '{"vol":%d,"muted":%s,"micVol":%d,"micMuted":%s}\n' "${vol:-0}" "$muted" "${micvol:-0}" "$micMuted"
  if [ "$muted" = true ]; then led platform::mute 1; else led platform::mute 0; fi
  if [ "$micMuted" = true ]; then led platform::micmute 1; else led platform::micmute 0; fi
}

emit
if command -v pactl >/dev/null 2>&1; then
  pactl subscribe 2>/dev/null | while read -r line; do
    case "$line" in
      *sink*|*source*|*server*)
        while read -t 0.04 -r _; do :; done   # swallow the burst of events from one change
        emit ;;
    esac
  done
fi
# fallback if pactl isn't available or died: poll
while true; do sleep 1; emit; done
