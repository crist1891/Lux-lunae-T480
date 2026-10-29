#!/usr/bin/env bash
hyprctl activeworkspace -j 2>/dev/null || echo '{}'
echo '@@@'
hyprctl activewindow -j 2>/dev/null || echo '{}'
