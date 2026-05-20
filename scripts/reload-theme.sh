#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if command -v hyprctl >/dev/null 2>&1; then
  hyprctl reload || true
else
  echo "hyprctl niet gevonden; sla Hyprland-reload over." >&2
fi

if [ -x "$SCRIPT_DIR/start-waybar.sh" ]; then
  "$SCRIPT_DIR/start-waybar.sh"
elif [ -x "${XDG_CONFIG_HOME:-$HOME/.config}/big-sur/scripts/start-waybar.sh" ]; then
  "${XDG_CONFIG_HOME:-$HOME/.config}/big-sur/scripts/start-waybar.sh"
else
  pkill -x waybar 2>/dev/null || true
  sleep 0.25
  waybar &
fi

"$SCRIPT_DIR/apply-wallpaper.sh" || true

echo "Theme herladen (Hyprland + Waybar + wallpaper)."
