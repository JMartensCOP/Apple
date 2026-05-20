#!/usr/bin/env bash
# Start Cursor IDE (AUR cursor-bin, AppImage, Flatpak). Waybar 󰏘 / Super+Shift+U.
set -uo pipefail

LOG_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/big-sur"
LOG_FILE="$LOG_DIR/cursor.log"
SCRIPT="${BASH_SOURCE[0]:-$0}"
CURSOR_FLATPAK_ID="com.todesktop.230313mzl4w4u92"

mkdir -p "$LOG_DIR"

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$LOG_FILE"
}

notify_msg() {
  local body="$1"
  notify-send "Cursor" "$body" 2>/dev/null || true
  log "notify: $body"
}

log "=== launch-cursor pid=$$ script=$SCRIPT ==="
log "HOME=$HOME USER=${USER:-?} XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-?}"

notify_msg "Bezig…"

find_appimage() {
  local pattern path
  shopt -s nullglob
  for pattern in \
    "$HOME/Applications/cursor"*.AppImage \
    "$HOME/Applications/Cursor"*.AppImage \
    "$HOME/Downloads/cursor"*.AppImage \
    "$HOME/Downloads/Cursor"*.AppImage; do
    for path in $pattern; do
      if [ -f "$path" ]; then
        if [ ! -x "$path" ]; then
          chmod +x "$path" 2>/dev/null || true
        fi
        if [ -x "$path" ]; then
          log "gevonden AppImage: $path"
          shopt -u nullglob
          echo "$path"
          return 0
        fi
      fi
    done
  done
  shopt -u nullglob
  return 1
}

find_flatpak_cursor() {
  if ! command -v flatpak >/dev/null 2>&1; then
    return 1
  fi
  if flatpak info "$CURSOR_FLATPAK_ID" >/dev/null 2>&1; then
    log "gevonden: flatpak $CURSOR_FLATPAK_ID"
    echo "flatpak:$CURSOR_FLATPAK_ID"
    return 0
  fi
  local ref
  ref="$(flatpak list --app --columns=application 2>/dev/null | grep -m1 '^com\.todesktop\.' || true)"
  if [ -n "$ref" ]; then
    log "gevonden: flatpak $ref"
    echo "flatpak:$ref"
    return 0
  fi
  return 1
}

find_launcher() {
  local candidate path
  for candidate in cursor Cursor; do
    if path="$(command -v "$candidate" 2>/dev/null)" && [ -n "$path" ]; then
      log "gevonden: $candidate → $path"
      echo "$path"
      return 0
    fi
  done
  if [ -x /usr/bin/cursor ]; then
    log "gevonden: /usr/bin/cursor"
    echo /usr/bin/cursor
    return 0
  fi
  if [ -x "$HOME/.local/bin/cursor" ]; then
    log "gevonden: $HOME/.local/bin/cursor"
    echo "$HOME/.local/bin/cursor"
    return 0
  fi
  if path="$(find_appimage || true)" && [ -n "$path" ]; then
    echo "$path"
    return 0
  fi
  if path="$(find_flatpak_cursor || true)" && [ -n "$path" ]; then
    echo "$path"
    return 0
  fi
  return 1
}

cursor_running() {
  pgrep -x cursor >/dev/null 2>&1 && return 0
  pgrep -x Cursor >/dev/null 2>&1 && return 0
  pgrep -f '[Cc]ursor.*AppImage' >/dev/null 2>&1 && return 0
  if command -v flatpak >/dev/null 2>&1; then
    flatpak ps 2>/dev/null | grep -q com.todesktop. && return 0
  fi
  return 1
}

launcher="$(find_launcher || true)"
if [ -z "$launcher" ]; then
  msg="Geen Cursor — installeer: yay -S cursor-bin  of download AppImage van https://cursor.com"
  notify_msg "$msg"
  log "geen launcher beschikbaar"
  echo "$msg" >&2
  echo "Log: $LOG_FILE" >&2
  exit 1
fi

if cursor_running; then
  notify_msg "Cursor draait al"
  log "al actief — geen tweede start"
  exit 0
fi

if [[ "$launcher" == flatpak:* ]]; then
  app_id="${launcher#flatpak:}"
  log "start: flatpak run $app_id"
  flatpak run "$app_id" >>"$LOG_FILE" 2>&1 &
elif [[ "$launcher" == *.AppImage ]]; then
  log "start AppImage: $launcher"
  "$launcher" --no-sandbox >>"$LOG_FILE" 2>&1 &
else
  log "start: $launcher"
  "$launcher" >>"$LOG_FILE" 2>&1 &
fi

sleep 0.8
if cursor_running; then
  notify_msg "Cursor gestart"
  log "start OK"
  exit 0
fi

notify_msg "Start mislukt — zie cursor.log (yay -S cursor-bin?)"
log "start mislukt — geen cursor-proces na 0.8s"
echo "Cursor start mislukt. Log: $LOG_FILE" >&2
exit 1
