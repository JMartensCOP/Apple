#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/big-sur-theme-backup-$(date +%Y%m%d-%H%M%S)"

echo "Installing Big Sur Hyprland theme..."

if [ ! -f "$PROJECT_DIR/assets/Background.jpg" ]; then
  echo "Missing assets/Background.jpg"
  exit 1
fi

mkdir -p "$BACKUP_DIR"
mkdir -p "$HOME/.config/hypr"
mkdir -p "$HOME/.config/waybar"
mkdir -p "$HOME/.config/kitty"
mkdir -p "$HOME/.config/rofi"
mkdir -p "$HOME/.config/dunst"
mkdir -p "$HOME/.config/hypr/big-sur"

backup_path() {
  local path="$1"
  if [ -e "$path" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${path#$HOME/.config/}")"
    cp -r "$path" "$BACKUP_DIR/${path#$HOME/.config/}"
  fi
}

backup_path "$HOME/.config/hypr/hyprland.conf"
backup_path "$HOME/.config/hypr/hyprpaper.conf"
backup_path "$HOME/.config/waybar/config.jsonc"
backup_path "$HOME/.config/waybar/style.css"
backup_path "$HOME/.config/kitty/kitty.conf"
backup_path "$HOME/.config/kitty/big-sur.conf"
backup_path "$HOME/.config/rofi/big-sur.rasi"
backup_path "$HOME/.config/dunst/dunstrc"

cp "$PROJECT_DIR/assets/Background.jpg" "$HOME/.config/hypr/big-sur/Background.jpg"
cp "$PROJECT_DIR/hypr/"*.conf "$HOME/.config/hypr/"
cp "$PROJECT_DIR/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
cp "$PROJECT_DIR/waybar/style.css" "$HOME/.config/waybar/style.css"
cp "$PROJECT_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
cp "$PROJECT_DIR/kitty/big-sur.conf" "$HOME/.config/kitty/big-sur.conf"

if [ -f "$PROJECT_DIR/rofi/big-sur.rasi" ]; then
  cp "$PROJECT_DIR/rofi/big-sur.rasi" "$HOME/.config/rofi/big-sur.rasi"
fi

if [ -f "$PROJECT_DIR/dunst/dunstrc" ]; then
  cp "$PROJECT_DIR/dunst/dunstrc" "$HOME/.config/dunst/dunstrc"
fi

chmod +x "$PROJECT_DIR/scripts/"*.sh 2>/dev/null || true

echo "Installation complete."
echo "Backup created at: $BACKUP_DIR"
echo "Reload Hyprland with: hyprctl reload"
echo "Restart Waybar if needed: pkill waybar && waybar &"
