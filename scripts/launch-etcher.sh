#!/usr/bin/env bash
# Start Balena Etcher (AUR etcher-bin, AppImage). Waybar 󰋊 / Super+Shift+H.
set -uo pipefail

LOG_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/big-sur"
LOG_FILE="$LOG_DIR/etcher.log"
SCRIPT="${BASH_SOURCE[0]:-$0}"
ETCHER_FLATPAK_ID="io.balena.etcher"

mkdir -p "$LOG_DIR"

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$LOG_FILE"
}

notify_msg() {
  local body="$1"
  notify-send "Balena Etcher" "$body" 2>/dev/null || true
  log "notify: $body"
}

log "=== launch-etcher pid=$$ script=$SCRIPT ==="
log "HOME=$HOME USER=${USER:-?} XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-?}"

notify_msg "Bezig…"

find_appimage() {
  local pattern path
  shopt -s nullglob
  for pattern in \
    "$HOME/Applications/balena-etcher"*.AppImage \
    "$HOME/Applications/Balena-Etcher"*.AppImage \
    "$HOME/Applications/etcher"*.AppImage \
    "$HOME/Applications/Etcher"*.AppImage \
    "$HOME/Downloads/balena-etcher"*.AppImage \
    "$HOME/Downloads/Balena-Etcher"*.AppImage \
    "$HOME/Downloads/etcher"*.AppImage \
    "$HOME/Downloads/Etcher"*.AppImage; do
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

find_flatpak_etcher() {
  if ! command -v flatpak >/dev/null 2>&1; then
    return 1
  fi
  if flatpak info "$ETCHER_FLATPAK_ID" >/dev/null 2>&1; then
    log "gevonden: flatpak $ETCHER_FLATPAK_ID"
    echo "flatpak:$ETCHER_FLATPAK_ID"
    return 0
  fi
  local ref
  ref="$(flatpak list --app --columns=application 2>/dev/null | grep -m1 'balena.*etcher\|io\.balena\.etcher' || true)"
  if [ -n "$ref" ]; then
    log "gevonden: flatpak $ref"
    echo "flatpak:$ref"
    return 0
  fi
  return 1
}

find_launcher() {
  local candidate path
  for candidate in balena-etcher etcher; do
    if path="$(command -v "$candidate" 2>/dev/null)" && [ -n "$path" ]; then
      log "gevonden: $candidate → $path"
      echo "$path"
      return 0
    fi
  done
  if [ -x /usr/bin/balena-etcher ]; then
    log "gevonden: /usr/bin/balena-etcher"
    echo /usr/bin/balena-etcher
    return 0
  fi
  if [ -x /usr/bin/etcher ]; then
    log "gevonden: /usr/bin/etcher"
    echo /usr/bin/etcher
    return 0
  fi
  if [ -x /opt/balena-etcher/etcher ]; then
    log "gevonden: /opt/balena-etcher/etcher"
    echo /opt/balena-etcher/etcher
    return 0
  fi
  if path="$(find_appimage || true)" && [ -n "$path" ]; then
    echo "$path"
    return 0
  fi
  if path="$(find_flatpak_etcher || true)" && [ -n "$path" ]; then
    echo "$path"
    return 0
  fi
  return 1
}

etcher_running() {
  pgrep -x balena-etcher >/dev/null 2>&1 && return 0
  pgrep -x etcher >/dev/null 2>&1 && return 0
  pgrep -f '[Bb]alena.*[Ee]tcher' >/dev/null 2>&1 && return 0
  pgrep -f '[Ee]tcher.*AppImage' >/dev/null 2>&1 && return 0
  if command -v flatpak >/dev/null 2>&1; then
    flatpak ps 2>/dev/null | grep -qi etcher && return 0
  fi
  return 1
}

launcher="$(find_launcher || true)"
if [ -z "$launcher" ]; then
  msg="Geen Balena Etcher — installeer: yay -S etcher-bin  of download AppImage van https://etcher.balena.io"
  notify_msg "$msg"
  log "geen launcher beschikbaar"
  echo "$msg" >&2
  echo "Log: $LOG_FILE" >&2
  exit 1
fi

if etcher_running; then
  notify_msg "Balena Etcher draait al"
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
if etcher_running; then
  notify_msg "Balena Etcher gestart"
  log "start OK"
  exit 0
fi

notify_msg "Start mislukt — zie etcher.log (yay -S etcher-bin?)"
log "start mislukt — geen etcher-proces na 0.8s"
echo "Balena Etcher start mislukt. Log: $LOG_FILE" >&2
exit 1
