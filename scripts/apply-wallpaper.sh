#!/usr/bin/env bash
set -euo pipefail

WALLPAPER="$HOME/.config/hypr/big-sur/Background.jpg"

if [ ! -f "$WALLPAPER" ]; then
  echo "Wallpaper not found: $WALLPAPER"
  exit 1
fi

hyprctl hyprpaper unload all || true
hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper ",$WALLPAPER"

echo "Wallpaper applied."
