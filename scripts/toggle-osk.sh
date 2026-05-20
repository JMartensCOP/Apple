#!/usr/bin/env bash
# Toggle Wayland on-screen keyboard (wvkbd). Arch: pacman -S wvkbd
set -euo pipefail

OSK_BIN=""
for candidate in wvkbd-deskintl wvkbd-mobintl wvkbd; do
  if command -v "$candidate" >/dev/null 2>&1; then
    OSK_BIN="$candidate"
    break
  fi
done

if [ -z "$OSK_BIN" ]; then
  if command -v onboard >/dev/null 2>&1; then
    if pgrep -x onboard >/dev/null 2>&1; then
      pkill -x onboard
    else
      onboard &
    fi
    exit 0
  fi
  notify-send "Schermtoetsenbord" "Installeer wvkbd: sudo pacman -S wvkbd" 2>/dev/null || true
  echo "Geen wvkbd of onboard gevonden. Installeer: sudo pacman -S wvkbd" >&2
  exit 1
fi

# wvkbd: SIGRTMIN = toggle; anders proces stoppen
if pid="$(pgrep -x "$OSK_BIN" 2>/dev/null | head -1)" && [ -n "$pid" ]; then
  kill -RTMIN "$pid" 2>/dev/null || pkill -x "$OSK_BIN"
else
  "$OSK_BIN" &
fi
