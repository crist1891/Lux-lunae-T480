#!/usr/bin/env bash
# Toggle blur + shadows (off in the VM, on for real hardware). Hyprland 0.55+ Lua mode.
ST="$HOME/.cache/lux-blur"; mkdir -p "$(dirname "$ST")"
if [ "$(cat "$ST" 2>/dev/null)" = on ]; then n=false; echo off > "$ST"; else n=true; echo on > "$ST"; fi
hyprctl eval "hl.config({ decoration = { blur = { enabled = $n }, shadow = { enabled = $n } } })"
