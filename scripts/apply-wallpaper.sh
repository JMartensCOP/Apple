#!/usr/bin/env bash
set -euo pipefail

if [ -n "${BIG_SUR_CONFIG_DIR:-}" ]; then
  CONFIG_DIR="$BIG_SUR_CONFIG_DIR"
elif [ -n "${XDG_CONFIG_HOME:-}" ]; then
  CONFIG_DIR="$XDG_CONFIG_HOME"
else
  CONFIG_DIR="$HOME/.config"
fi

WALLPAPER="$CONFIG_DIR/hypr/big-sur/Background.jpg"

if [ ! -f "$WALLPAPER" ]; then
  echo "Wallpaper not found: $WALLPAPER"
  echo "Run install.sh from the theme repo to copy assets/Background.jpg."
  exit 1
fi

hyprctl hyprpaper wallpaper ",$WALLPAPER,cover"

echo "Wallpaper applied: $WALLPAPER"
