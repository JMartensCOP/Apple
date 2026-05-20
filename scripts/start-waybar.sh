#!/usr/bin/env bash
# Start or restart Waybar for the Big Sur theme (Hyprland session).
set -euo pipefail

WAYBAR_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
LOG_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/big-sur"
LOG_FILE="$LOG_DIR/waybar.log"

mkdir -p "$LOG_DIR"

if ! command -v waybar >/dev/null 2>&1; then
  echo "waybar: niet gevonden in PATH." >&2
  echo "  Arch: sudo pacman -S waybar" >&2
  exit 1
fi

if [ ! -f "$WAYBAR_CONFIG_DIR/config.jsonc" ] && [ ! -f "$WAYBAR_CONFIG_DIR/config.json" ]; then
  echo "waybar: geen config in $WAYBAR_CONFIG_DIR" >&2
  echo "  Voer ./install.sh uit in je Hyprland-sessie (niet alleen Git Bash op Windows)." >&2
  exit 1
fi

pkill -x waybar 2>/dev/null || true
sleep 0.35

: >"$LOG_FILE"
nohup waybar >>"$LOG_FILE" 2>&1 &
disown 2>/dev/null || true

sleep 0.6
if pgrep -x waybar >/dev/null 2>&1; then
  echo "waybar gestart (log: $LOG_FILE)"
  exit 0
fi

echo "waybar: proces start niet of crasht direct." >&2
echo "  Log: $LOG_FILE" >&2
echo "  Test: waybar  (in een terminal, fouten op stderr)" >&2
if [ -s "$LOG_FILE" ]; then
  echo "--- laatste regels uit log ---" >&2
  tail -n 30 "$LOG_FILE" >&2
fi
exit 1
