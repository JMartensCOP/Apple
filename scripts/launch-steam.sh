#!/usr/bin/env bash
# Start Steam (Arch: steam). Waybar / Apps-menu.
set -uo pipefail

LOG_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/big-sur"
LOG_FILE="$LOG_DIR/steam.log"
mkdir -p "$LOG_DIR"

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$LOG_FILE"
}

notify_msg() {
  notify-send "Steam" "$1" 2>/dev/null || true
  log "notify: $1"
}

find_launcher() {
  local candidate path
  for candidate in steam; do
    if path="$(command -v "$candidate" 2>/dev/null)" && [ -n "$path" ]; then
      echo "$path"
      return 0
    fi
  done
  for path in /usr/bin/steam /usr/games/steam; do
    if [ -x "$path" ]; then
      echo "$path"
      return 0
    fi
  done
  return 1
}

launcher="$(find_launcher || true)"
if [ -z "$launcher" ]; then
  msg="Steam niet gevonden — installeer: sudo pacman -S --needed steam"
  notify_msg "$msg"
  echo "$msg" >&2
  exit 1
fi

if pgrep -x steam >/dev/null 2>&1; then
  notify_msg "Steam draait al"
  exit 0
fi

log "start: $launcher"
"$launcher" >>"$LOG_FILE" 2>&1 &
