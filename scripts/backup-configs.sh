#!/usr/bin/env bash
set -euo pipefail

if [ -n "${BIG_SUR_CONFIG_DIR:-}" ]; then
  CONFIG_DIR="$BIG_SUR_CONFIG_DIR"
elif [ -n "${XDG_CONFIG_HOME:-}" ]; then
  CONFIG_DIR="$XDG_CONFIG_HOME"
else
  CONFIG_DIR="$HOME/.config"
fi

BACKUP_DIR="$CONFIG_DIR/big-sur-theme-backup-$(date +%Y%m%d-%H%M%S)"

echo "Creating backup at: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

backup_path() {
  local path="$1"
  if [ -e "$path" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${path#$CONFIG_DIR/}")"
    cp -r "$path" "$BACKUP_DIR/${path#$CONFIG_DIR/}"
    echo "  backed up: $path"
  fi
}

backup_path "$CONFIG_DIR/hypr/hyprland.conf"
backup_path "$CONFIG_DIR/hypr/hyprpaper.conf"
backup_path "$CONFIG_DIR/hypr/theme.conf"
backup_path "$CONFIG_DIR/hypr/keybinds.conf"
backup_path "$CONFIG_DIR/hypr/windowrules.conf"
backup_path "$CONFIG_DIR/waybar/config.jsonc"
backup_path "$CONFIG_DIR/waybar/style.css"
backup_path "$CONFIG_DIR/kitty/kitty.conf"
backup_path "$CONFIG_DIR/kitty/big-sur.conf"
backup_path "$CONFIG_DIR/rofi/big-sur.rasi"
backup_path "$CONFIG_DIR/dunst/dunstrc"
backup_path "$CONFIG_DIR/hypr/big-sur/Background.jpg"

echo "Backup complete: $BACKUP_DIR"
