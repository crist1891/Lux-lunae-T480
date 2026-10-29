#!/usr/bin/env bash
# Toggle screen recording.   record.sh [--fullscreen] [--sound]
if pgrep -x wf-recorder >/dev/null; then
  pkill -INT -x wf-recorder
  notify-send "Recording stopped" "Saved in ~/Videos" -a Hyprland
  exit 0
fi
mkdir -p "$HOME/Videos"
out="$HOME/Videos/recording_$(date +%Y-%m-%d_%H.%M.%S).mp4"
args=(-f "$out"); full=0; sound=0
for a in "$@"; do
  [ "$a" = "--fullscreen" ] && full=1
  [ "$a" = "--sound" ] && sound=1
done
if [ $full -eq 0 ]; then region=$(slurp) || exit 0; args+=(-g "$region"); fi
[ $sound -eq 1 ] && args+=(--audio)
notify-send "Recording started" "Press the same keys again to stop" -a Hyprland
exec wf-recorder "${args[@]}"
