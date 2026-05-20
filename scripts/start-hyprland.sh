#!/usr/bin/env bash
# Start Hyprland on tty1 after login (no display manager).
set -euo pipefail

if [ -n "${WAYLAND_DISPLAY:-}" ]; then
  exit 0
fi

if [ "$(tty 2>/dev/null || echo unknown)" != "/dev/tty1" ]; then
  exit 0
fi

if command -v Hyprland >/dev/null 2>&1; then
  exec Hyprland
fi

if command -v hyprland >/dev/null 2>&1; then
  exec hyprland
fi

echo "start-hyprland: Hyprland niet gevonden. Installeer: sudo pacman -S hyprland" >&2
exit 1
