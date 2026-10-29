#!/usr/bin/env bash
# Wallpaper switcher.   wallcycle.sh init|next
# Drop any .jpg/.png into ~/.config/lux/walls and it joins the rotation.
DIR="$HOME/.config/lux/walls"; ST="$HOME/.cache/lux-wall"; mkdir -p "$(dirname "$ST")"
mapfile -t W < <(find "$DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) | sort)
[ ${#W[@]} -eq 0 ] && exit 1
idx=$(cat "$ST" 2>/dev/null || echo 0)
[ "${1:-next}" = next ] && idx=$(( (idx + 1) % ${#W[@]} ))
[ "${1:-}" = random ] && idx=$(( RANDOM % ${#W[@]} ))
[ "$idx" -ge "${#W[@]}" ] && idx=0
echo "$idx" > "$ST"
old=$(pgrep -x swaybg)
swaybg -i "${W[$idx]}" -m fill &
sleep 0.4; [ -n "$old" ] && kill $old
