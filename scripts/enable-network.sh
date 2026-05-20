#!/usr/bin/env bash
# Enable NetworkManager and WiFi (Intel iwlwifi on HP EliteBook x360, etc.).
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
Usage: enable-network.sh [options]

Enable NetworkManager, turn WiFi radio on, show diagnostics.
Waybar wifi button opens nm-connection-editor — requires NetworkManager running.

Options:
  --connect SSID     Connect to open or saved network (prompts for password if needed)
  --connect SSID PW  Connect with password (avoid in shared history)
  -y, --yes          Skip iwd conflict confirmation
  -h, --help         Show this help

Examples:
  bash enable-network.sh
  bash enable-network.sh --connect "MyHomeWiFi"
  sudo pacman -S --needed networkmanager iw wireless-regdb linux-firmware
EOF
}

CONNECT_SSID=""
CONNECT_PASSWORD=""
FORCE=false

while [ $# -gt 0 ]; do
  case "$1" in
    --connect)
      CONNECT_SSID="${2:?--connect requires SSID}"
      shift 2
      if [ $# -gt 0 ] && [[ "$1" != -* ]]; then
        CONNECT_PASSWORD="$1"
        shift
      fi
      ;;
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
  echo "enable-network: overgeslagen (Windows/Git Bash — geen systemd)."
  exit 0
fi

if ! command -v systemctl >/dev/null 2>&1; then
  echo "enable-network: systemctl niet gevonden."
  exit 1
fi

check_iwd_conflict() {
  if ! systemctl list-unit-files iwd.service >/dev/null 2>&1; then
    return 0
  fi
  if systemctl is-enabled iwd.service >/dev/null 2>&1; then
    echo "enable-network: iwd.service is ingeschakeld — conflicteert met NetworkManager."
    if [ "$FORCE" = true ]; then
      answer=y
    else
      read -r -p "iwd uitschakelen en NetworkManager gebruiken? [y/N] " answer
    fi
    case "$answer" in
      y|Y|yes|YES)
        sudo systemctl disable --now iwd.service 2>/dev/null || true
        echo "enable-network: iwd uitgeschakeld."
        ;;
      *)
        echo "enable-network: iwd blijft actief — WiFi kan onbetrouwbaar zijn met NM."
        ;;
    esac
  fi
}

if ! command -v nmcli >/dev/null 2>&1; then
  echo "enable-network: nmcli niet gevonden — installeer networkmanager:"
  echo "  sudo pacman -S --needed networkmanager network-manager-applet iw wireless-regdb linux-firmware"
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "enable-network: sudo vereist voor systemctl enable NetworkManager."
  exit 1
fi

check_iwd_conflict

echo "enable-network: schakel NetworkManager in..."
sudo systemctl enable --now NetworkManager.service

if systemctl is-active --quiet NetworkManager.service; then
  echo "enable-network: NetworkManager.service actief."
else
  echo "enable-network: WAARSCHUWING — NetworkManager niet actief." >&2
  systemctl status NetworkManager.service --no-pager -l 2>&1 | tail -n 10 >&2 || true
fi

echo ""
echo "enable-network: rfkill status..."
if command -v rfkill >/dev/null 2>&1; then
  rfkill list || true
  if rfkill list wifi 2>/dev/null | grep -q 'Soft blocked: yes'; then
    echo "enable-network: WiFi software-blok — probeer: rfkill unblock wifi"
    rfkill unblock wifi 2>/dev/null || sudo rfkill unblock wifi 2>/dev/null || true
  fi
else
  echo "  (rfkill niet geïnstalleerd — optioneel: sudo pacman -S rfkill)"
fi

echo ""
echo "enable-network: WiFi-radio aan..."
nmcli radio wifi on 2>/dev/null || true

echo ""
echo "enable-network: apparaten..."
nmcli device status || true

echo ""
echo "enable-network: beschikbare netwerken..."
if ! nmcli dev wifi list 2>&1; then
  echo ""
  echo "enable-network: geen WiFi-lijst — controleer:"
  echo "  - linux-firmware (Intel iwlwifi): sudo pacman -S linux-firmware"
  echo "  - kernel module: lsmod | grep iwlwifi"
  echo "  - firmware: dmesg | grep -i iwl"
fi

if [ -n "$CONNECT_SSID" ]; then
  echo ""
  echo "enable-network: verbinden met '$CONNECT_SSID'..."
  if [ -n "$CONNECT_PASSWORD" ]; then
    nmcli dev wifi connect "$CONNECT_SSID" password "$CONNECT_PASSWORD"
  elif nmcli -t -f NAME connection show | grep -Fxq "$CONNECT_SSID"; then
    nmcli connection up "$CONNECT_SSID"
  else
    read -r -s -p "Wachtwoord voor '$CONNECT_SSID': " CONNECT_PASSWORD
    echo ""
    nmcli dev wifi connect "$CONNECT_SSID" password "$CONNECT_PASSWORD"
  fi
  echo "enable-network: verbonden — nmcli -t -f ACTIVE,SSID dev wifi"
  nmcli -t -f ACTIVE,SSID dev wifi || true
fi

echo ""
echo "=== Netwerk ==="
echo "  Waybar wifi-knop opent: nm-connection-editor (werkt alleen als NetworkManager draait)"
echo "  Status:                 systemctl status NetworkManager"
echo "  Herstart na install:      bash \"$SCRIPT_DIR/enable-network.sh\""
