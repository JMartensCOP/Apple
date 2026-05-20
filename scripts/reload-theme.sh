#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

hyprctl reload
pkill waybar || true
waybar >/tmp/waybar-big-sur.log 2>&1 &
"$SCRIPT_DIR/apply-wallpaper.sh" || true

echo "Theme reloaded."
