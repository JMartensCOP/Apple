#!/usr/bin/env bash
# Start Spotify (Arch AUR, Flatpak). Waybar 󰓇 / Super+Shift+S.
set -uo pipefail

LOG_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/big-sur"
LOG_FILE="$LOG_DIR/spotify.log"
SCRIPT="${BASH_SOURCE[0]:-$0}"

mkdir -p "$LOG_DIR"

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$LOG_FILE"
}

notify_msg() {
  local body="$1"
  notify-send "Spotify" "$body" 2>/dev/null || true
  log "notify: $body"
}

log "=== launch-spotify pid=$$ script=$SCRIPT ==="
log "HOME=$HOME USER=${USER:-?} XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-?}"

notify_msg "Bezig…"

find_launcher() {
  local candidate path
  for candidate in spotify spotify-launcher; do
    if path="$(command -v "$candidate" 2>/dev/null)" && [ -n "$path" ]; then
      log "gevonden: $candidate → $path"
      echo "$path"
      return 0
    fi
  done
  if [ -x /usr/bin/spotify ]; then
    log "gevonden: /usr/bin/spotify"
    echo /usr/bin/spotify
    return 0
  fi
  if command -v flatpak >/dev/null 2>&1 && flatpak info com.spotify.Client >/dev/null 2>&1; then
    log "gevonden: flatpak com.spotify.Client"
    echo "flatpak:com.spotify.Client"
    return 0
  fi
  return 1
}

spotify_running() {
  pgrep -x spotify >/dev/null 2>&1 && return 0
  pgrep -x spotify-launcher >/dev/null 2>&1 && return 0
  if command -v flatpak >/dev/null 2>&1; then
    flatpak ps 2>/dev/null | grep -q com.spotify.Client && return 0
  fi
  return 1
}

launcher="$(find_launcher || true)"
if [ -z "$launcher" ]; then
  msg="Geen Spotify — installeer: yay -S spotify  (of spotify-launcher / flatpak install flathub com.spotify.Client)"
  notify_msg "$msg"
  log "geen launcher beschikbaar"
  echo "$msg" >&2
  echo "Log: $LOG_FILE" >&2
  exit 1
fi

if spotify_running; then
  notify_msg "Spotify draait al"
  log "al actief — geen tweede start"
  exit 0
fi

if [[ "$launcher" == flatpak:* ]]; then
  log "start: flatpak run com.spotify.Client"
  flatpak run com.spotify.Client >>"$LOG_FILE" 2>&1 &
else
  log "start: $launcher"
  "$launcher" >>"$LOG_FILE" 2>&1 &
fi

sleep 0.8
if spotify_running; then
  notify_msg "Spotify gestart"
  log "start OK"
  exit 0
fi

notify_msg "Start mislukt — zie spotify.log (yay -S spotify?)"
log "start mislukt — geen spotify-proces na 0.8s"
echo "Spotify start mislukt. Log: $LOG_FILE" >&2
exit 1
