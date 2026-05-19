#!/usr/bin/env bash
set -euo pipefail

hyprctl reload
pkill waybar || true
waybar >/tmp/waybar-big-sur.log 2>&1 &

echo "Theme reloaded."
