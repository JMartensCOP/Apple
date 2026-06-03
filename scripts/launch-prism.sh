#!/usr/bin/env bash
# Start Prism Launcher (Arch: prismlauncher, binary prismlauncher). Apps-menu.
set -uo pipefail

LOG_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/big-sur"
LOG_FILE="$LOG_DIR/prism.log"
mkdir -p "$LOG_DIR"

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$LOG_FILE"
}

notify_msg() {
  notify-send "Prism Launcher" "$1" 2>/dev/null || true
  log "notify: $1"
}

find_launcher() {
  local candidate path
  for candidate in prismlauncher prism-launcher PrismLauncher; do
    if path="$(command -v "$candidate" 2>/dev/null)" && [ -n "$path" ]; then
      echo "$path"
      return 0
    fi
  done
  for path in /usr/bin/prismlauncher /usr/bin/prism-launcher; do
    if [ -x "$path" ]; then
      echo "$path"
      return 0
    fi
  done
  return 1
}

launcher="$(find_launcher || true)"
if [ -z "$launcher" ]; then
  msg="Prism Launcher niet gevonden — installeer: sudo pacman -S --needed prismlauncher"
  notify_msg "$msg"
  echo "$msg" >&2
  exit 1
fi

log "start: $launcher"
exec "$launcher" >>"$LOG_FILE" 2>&1
