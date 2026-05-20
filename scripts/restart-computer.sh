#!/usr/bin/env bash
set -euo pipefail

confirm_reboot() {
  if command -v rofi >/dev/null 2>&1; then
    local theme="${HOME}/.config/rofi/big-sur.rasi"
    local rofi_args=(-dmenu -p "Restart computer?")
    if [ -f "$theme" ]; then
      rofi_args+=(-theme "$theme")
    fi
    case "$(printf 'Yes\nNo' | rofi "${rofi_args[@]}")" in
      Yes) return 0 ;;
    esac
    return 1
  fi

  if command -v wofi >/dev/null 2>&1; then
    case "$(printf 'Yes\nNo' | wofi -dmenu -p "Restart computer?")" in
      Yes) return 0 ;;
    esac
    return 1
  fi

  read -r -p "Restart computer? [y/N] " answer
  case "$answer" in
    y | Y | yes | YES) return 0 ;;
  esac
  return 1
}

if ! confirm_reboot; then
  exit 0
fi

if command -v loginctl >/dev/null 2>&1; then
  loginctl reboot
elif command -v systemctl >/dev/null 2>&1; then
  systemctl reboot
else
  echo "No loginctl or systemctl found; cannot reboot." >&2
  exit 1
fi
