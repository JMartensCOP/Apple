#!/usr/bin/env bash
set -euo pipefail

if [ -n "${BIG_SUR_CONFIG_DIR:-}" ]; then
  CONFIG_DIR="$BIG_SUR_CONFIG_DIR"
elif [ -n "${XDG_CONFIG_HOME:-}" ]; then
  CONFIG_DIR="$XDG_CONFIG_HOME"
else
  CONFIG_DIR="$HOME/.config"
fi

echo "This will remove Big Sur theme-specific files from: $CONFIG_DIR"
read -r -p "Continue? [y/N] " answer

case "$answer" in
  y|Y|yes|YES)
    rm -f "$CONFIG_DIR/hypr/big-sur/Background.jpg"
    rm -f "$CONFIG_DIR/kitty/big-sur.conf"
    rm -f "$CONFIG_DIR/rofi/big-sur.rasi"
    echo "Theme-specific files removed."
    echo "Restore full configs manually from your backup directory if needed."
    echo "Backups are stored in: $CONFIG_DIR/big-sur-theme-backup-*"
    ;;
  *)
    echo "Cancelled."
    ;;
esac
