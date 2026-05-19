#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="$HOME/.config/big-sur-theme-backup-$(date +%Y%m%d-%H%M%S)"

echo "Creating backup at: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

backup_path() {
  local path="$1"
  if [ -e "$path" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${path#$HOME/.config/}")"
    cp -r "$path" "$BACKUP_DIR/${path#$HOME/.config/}"
    echo "  backed up: $path"
  fi
}

backup_path "$HOME/.config/hypr/hyprland.conf"
backup_path "$HOME/.config/hypr/hyprpaper.conf"
backup_path "$HOME/.config/hypr/theme.conf"
backup_path "$HOME/.config/hypr/keybinds.conf"
backup_path "$HOME/.config/hypr/windowrules.conf"
backup_path "$HOME/.config/waybar/config.jsonc"
backup_path "$HOME/.config/waybar/style.css"
backup_path "$HOME/.config/kitty/kitty.conf"
backup_path "$HOME/.config/kitty/big-sur.conf"
backup_path "$HOME/.config/rofi/big-sur.rasi"
backup_path "$HOME/.config/dunst/dunstrc"
backup_path "$HOME/.config/hypr/big-sur/Background.jpg"

echo "Backup complete: $BACKUP_DIR"
