#!/usr/bin/env bash
# Open Bluetooth UI: blueman-manager, or bluetoothctl in a terminal.
set -euo pipefail

if command -v blueman-manager >/dev/null 2>&1; then
  exec blueman-manager "$@"
fi

if command -v bluetoothctl >/dev/null 2>&1; then
  for term in kitty foot alacritty; do
    if command -v "$term" >/dev/null 2>&1; then
      exec "$term" -e bluetoothctl
    fi
  done
  exec bluetoothctl
fi

msg="Geen Bluetooth-UI gevonden. Installeer: sudo pacman -S blueman bluez bluez-utils"
notify-send "Bluetooth" "$msg" 2>/dev/null || true
echo "$msg" >&2
exit 1
