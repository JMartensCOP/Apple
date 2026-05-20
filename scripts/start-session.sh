#!/usr/bin/env bash
# Big Sur Hyprland session bootstrap: wallpaper, then lock screen.
# Waybar and dunst are started separately from hyprland.conf (behind hyprlock).
set -euo pipefail

if command -v hyprpaper >/dev/null 2>&1; then
  hyprpaper &
fi

sleep 0.5

exec hyprlock
