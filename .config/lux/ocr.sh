#!/usr/bin/env bash
# Select a region, OCR it, copy the text.   (end_4's Super+Shift+X)
pidof slurp >/dev/null && exit 0
img=$(mktemp /tmp/ocr_XXXXXX.png)
region=$(slurp) || exit 0
grim -g "$region" "$img"
langs=$(tesseract --list-langs | awk 'NR>1{print $1}' | paste -sd+)
tesseract "$img" stdout -l "${langs:-eng}" 2>/dev/null | wl-copy
rm -f "$img"
notify-send "OCR" "Text copied to clipboard" -a Hyprland
