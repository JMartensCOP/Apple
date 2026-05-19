#!/usr/bin/env bash
set -euo pipefail

echo "This will remove the Big Sur Hyprland theme files from ~/.config."
read -r -p "Continue? [y/N] " answer

case "$answer" in
  y|Y|yes|YES)
    rm -f "$HOME/.config/hypr/big-sur/Background.jpg"
    rm -f "$HOME/.config/kitty/big-sur.conf"
    rm -f "$HOME/.config/rofi/big-sur.rasi"
    echo "Theme-specific files removed."
    echo "Restore full configs manually from your backup directory if needed."
    echo "Backups are stored in: $HOME/.config/big-sur-theme-backup-*"
    ;;
  *)
    echo "Cancelled."
    ;;
esac
