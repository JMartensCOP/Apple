#!/usr/bin/env bash
# Enable stock Arch PipeWire user services (Waybar pulseaudio module, pavucontrol, wpctl).
set -euo pipefail

is_windows_shell() {
  case "$(uname -s 2>/dev/null || echo unknown)" in
    MINGW* | MSYS* | CYGWIN*) return 0 ;;
  esac
  [ -n "${MSYSTEM:-}" ] || [ -n "${WINDIR:-}" ]
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

for unit in "${AUDIO_UNITS[@]}"; do
  if ! systemctl --user cat "$unit" >/dev/null 2>&1; then
    echo "enable-audio: $unit niet gevonden — installeer pipewire, pipewire-pulse en wireplumber."
    continue
  fi
  systemctl --user enable --now "$unit"
  echo "enable-audio: $unit ingeschakeld en gestart."
done
