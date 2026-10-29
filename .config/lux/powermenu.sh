#!/usr/bin/env bash
c=$(printf '%s\n' "☽  Lock" "⏾  Suspend" "⟲  Restart" "⏻  Shut down" "✕  Leave Hyprland" \
  | wofi --dmenu --prompt "Umbra" --lines 5)
case "$c" in
  *Lock*)    hyprlock ;;
  *Suspend*) systemctl suspend ;;
  *Restart*) systemctl reboot ;;
  *Shut*)    systemctl poweroff ;;
  *Leave*)   hyprctl dispatch 'hl.dsp.exit()' ;;
esac
