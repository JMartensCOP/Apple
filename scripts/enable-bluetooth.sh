#!/usr/bin/env bash
# Enable BlueZ bluetoothd, unblock rfkill, power on adapter (HP EliteBook x360, etc.).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

is_windows_shell() {
  case "$(uname -s 2>/dev/null || echo unknown)" in
    MINGW* | MSYS* | CYGWIN*) return 0 ;;
  esac
  [ -n "${MSYSTEM:-}" ] || [ -n "${WINDIR:-}" ]
}

usage() {
  cat <<'EOF'
Usage: enable-bluetooth.sh [options]

Enable bluetooth.service, unblock Bluetooth rfkill, power on adapter, show status.
Waybar bluetooth button opens open-bluetooth.sh (blueman-manager or bluetoothctl).

Options:
  -y, --yes   Skip prompts (reserved; no interactive steps yet)
  -h, --help  Show this help

Examples:
  bash enable-bluetooth.sh
  sudo pacman -S --needed bluez bluez-utils blueman
EOF
}

FORCE=false

while [ $# -gt 0 ]; do
  case "$1" in
    -y|--yes) FORCE=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if is_windows_shell || [ "$(uname -s 2>/dev/null || echo unknown)" != "Linux" ]; then
  echo "enable-bluetooth: overgeslagen (Windows/Git Bash — geen systemd)."
  exit 0
fi

if ! command -v systemctl >/dev/null 2>&1; then
  echo "enable-bluetooth: systemctl niet gevonden."
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "enable-bluetooth: sudo vereist voor systemctl enable bluetooth."
  exit 1
fi

if ! command -v bluetoothctl >/dev/null 2>&1; then
  echo "enable-bluetooth: bluetoothctl niet gevonden — installeer bluez en bluez-utils:"
  echo "  sudo pacman -S --needed bluez bluez-utils blueman"
  exit 1
fi

echo "enable-bluetooth: schakel bluetooth.service in..."
sudo systemctl enable --now bluetooth.service

if systemctl is-active --quiet bluetooth.service; then
  echo "enable-bluetooth: bluetooth.service actief."
else
  echo "enable-bluetooth: WAARSCHUWING — bluetooth.service niet actief." >&2
  systemctl status bluetooth.service --no-pager -l 2>&1 | tail -n 10 >&2 || true
fi

echo ""
echo "enable-bluetooth: rfkill status..."
if command -v rfkill >/dev/null 2>&1; then
  rfkill list || true
  if rfkill list bluetooth 2>/dev/null | grep -q 'Soft blocked: yes'; then
    echo "enable-bluetooth: Bluetooth software-blok — deblokkeren..."
    rfkill unblock bluetooth 2>/dev/null || sudo rfkill unblock bluetooth 2>/dev/null || true
  fi
else
  echo "  (rfkill niet gevonden — optioneel: sudo pacman -S rfkill)"
fi

echo ""
echo "enable-bluetooth: adapter aan..."
bluetoothctl power on 2>/dev/null || true
sleep 0.5

echo ""
echo "enable-bluetooth: status..."
bluetoothctl show 2>/dev/null || true

echo ""
echo "=== Bluetooth ==="
echo "  Waybar 󰂯 opent: blueman-manager (of bluetoothctl via open-bluetooth.sh)"
echo "  Status:         systemctl status bluetooth"
echo "  Scan/pair:      bluetoothctl"
echo "  Herstart:       bash \"$SCRIPT_DIR/enable-bluetooth.sh\""
if ! id -nG "${USER:-}" 2>/dev/null | tr ' ' '\n' | grep -qx bluetooth; then
  echo ""
  echo "  Optioneel (sommige tools): sudo usermod -aG bluetooth \"\$USER\" && opnieuw inloggen"
fi
