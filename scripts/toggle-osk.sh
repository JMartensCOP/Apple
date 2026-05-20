#!/usr/bin/env bash
# Toggle Wayland on-screen keyboard (wvkbd). Geen systemd — start/kill binary direct.
# Arch: AUR — yay -S wvkbd-deskintl  (of wvkbd → wvkbd-mobintl)
# Fallback: onboard uit pacman (install.sh installeert onboard)
set -uo pipefail

OSK_BIN=""
for candidate in wvkbd-deskintl wvkbd-mobintl; do
  if command -v "$candidate" >/dev/null 2>&1; then
    OSK_BIN="$candidate"
    break
  fi
done

notify_err() {
  notify-send "Schermtoetsenbord" "$1" 2>/dev/null || true
  echo "Schermtoetsenbord: $1" >&2
}

toggle_onboard() {
  if ! command -v onboard >/dev/null 2>&1; then
    return 1
  fi
  if pgrep -x onboard >/dev/null 2>&1; then
    pkill -x onboard 2>/dev/null || true
    notify-send "Schermtoetsenbord" "Onboard uit" 2>/dev/null || true
  else
    # Wayland-sessie (Hyprland): onboard als XWayland-overlay
    GDK_BACKEND=x11 onboard --not-show-settings >/dev/null 2>&1 &
    notify-send "Schermtoetsenbord" "Onboard aan (fallback)" 2>/dev/null || true
  fi
  return 0
}

if [ -z "$OSK_BIN" ]; then
  if toggle_onboard; then
    exit 0
  fi
  notify_err "Installeer wvkbd (AUR): yay -S wvkbd-deskintl — of: sudo pacman -S onboard"
  exit 1
fi

# wvkbd: SIGRTMIN = toggle; anders proces stoppen
if pid="$(pgrep -x "$OSK_BIN" 2>/dev/null | head -1)" && [ -n "$pid" ]; then
  if kill -RTMIN "$pid" 2>/dev/null; then
    notify-send "Schermtoetsenbord" "${OSK_BIN} toggle" 2>/dev/null || true
  else
    pkill -x "$OSK_BIN" 2>/dev/null || true
    notify-send "Schermtoetsenbord" "${OSK_BIN} uit" 2>/dev/null || true
  fi
else
  "$OSK_BIN" >/dev/null 2>&1 &
  notify-send "Schermtoetsenbord" "${OSK_BIN} aan" 2>/dev/null || true
fi
