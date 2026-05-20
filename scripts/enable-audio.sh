#!/usr/bin/env bash
# Enable stock Arch PipeWire user services (Waybar pulseaudio module, pavucontrol, wpctl).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

is_windows_shell() {
  case "$(uname -s 2>/dev/null || echo unknown)" in
    MINGW* | MSYS* | CYGWIN*) return 0 ;;
  esac
  [ -n "${MSYSTEM:-}" ] || [ -n "${WINDIR:-}" ]
}

verify_unit_active() {
  local unit="$1"
  if systemctl --user is-active --quiet "$unit"; then
    echo "enable-audio: $unit actief."
    return 0
  fi
  echo "enable-audio: WAARSCHUWING — $unit niet actief." >&2
  systemctl --user status "$unit" --no-pager -l 2>&1 | tail -n 8 >&2 || true
  return 1
}

wait_for_pipewire() {
  local i
  for i in $(seq 1 20); do
    if command -v wpctl >/dev/null 2>&1 && wpctl status >/dev/null 2>&1; then
      return 0
    fi
    if command -v pactl >/dev/null 2>&1 && pactl info >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.25
  done
  echo "enable-audio: PipeWire reageert nog niet — probeer later: bash \"$SCRIPT_DIR/fix-audio.sh\"" >&2
  return 1
}

if is_windows_shell; then
  echo "enable-audio: overgeslagen (Windows/Git Bash — geen systemd user-sessie)."
  exit 0
fi

if [ "$(uname -s 2>/dev/null || echo unknown)" != "Linux" ]; then
  echo "enable-audio: overgeslagen (geen Linux)."
  exit 0
fi

if ! command -v systemctl >/dev/null 2>&1; then
  echo "enable-audio: systemctl niet gevonden; schakel services handmatig in."
  exit 0
fi

if [ -z "${XDG_RUNTIME_DIR:-}" ]; then
  echo "enable-audio: geen XDG_RUNTIME_DIR — log in op een systemd user-sessie (Hyprland)."
  exit 0
fi

if ! systemctl --user status >/dev/null 2>&1; then
  echo "enable-audio: geen actieve systemd user-sessie."
  exit 0
fi

AUDIO_UNITS=(
  pipewire.service
  pipewire-pulse.service
  wireplumber.service
)

failed=0
for unit in "${AUDIO_UNITS[@]}"; do
  if ! systemctl --user cat "$unit" >/dev/null 2>&1; then
    echo "enable-audio: $unit niet gevonden — installeer pipewire, pipewire-pulse en wireplumber."
    failed=1
    continue
  fi
  systemctl --user enable --now "$unit"
  echo "enable-audio: $unit ingeschakeld en gestart."
done

echo ""
echo "enable-audio: controleer services..."
for unit in "${AUDIO_UNITS[@]}"; do
  if systemctl --user cat "$unit" >/dev/null 2>&1; then
    verify_unit_active "$unit" || failed=1
  fi
done

if wait_for_pipewire; then
  if [ -x "$SCRIPT_DIR/fix-audio.sh" ]; then
    echo ""
    echo "enable-audio: zoek laptop-speakers als standaard uitgang..."
    bash "$SCRIPT_DIR/fix-audio.sh" --auto || true
  fi
fi

if [ "$failed" -ne 0 ]; then
  echo ""
  echo "enable-audio: sommige stappen mislukt — zie README troubleshooting (Speakers / pavucontrol)."
  exit 1
fi
