#!/usr/bin/env bash
# Toggle Wayland on-screen keyboard (wvkbd). Geen systemd — start/kill binary direct.
# Arch AUR: yay -S wvkbd-deskintl  (binary wvkbd-deskintl) of wvkbd → wvkbd-mobintl
# Fallback: onboard uit pacman (install.sh)
set -uo pipefail

LOG_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/big-sur"
LOG_FILE="$LOG_DIR/osk.log"
SCRIPT="${BASH_SOURCE[0]:-$0}"

mkdir -p "$LOG_DIR"

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$LOG_FILE"
}

notify_msg() {
  local body="$1"
  notify-send "Schermtoetsenbord" "$body" 2>/dev/null || true
  log "notify: $body"
}

log "=== toggle-osk pid=$$ script=$SCRIPT ==="
log "HOME=$HOME USER=${USER:-?} XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-?} WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-?} DISPLAY=${DISPLAY:-?}"

# Altijd feedback bij klik (ook als toggle faalt)
notify_msg "Bezig…"

OSK_BIN=""
for candidate in wvkbd-deskintl wvkbd-mobintl; do
  if command -v "$candidate" >/dev/null 2>&1; then
    OSK_BIN="$candidate"
    log "wvkbd: $candidate → $(command -v "$candidate")"
    break
  fi
done

onboard_running() {
  pgrep -x onboard >/dev/null 2>&1
}

onboard_show_dbus() {
  if command -v dbus-send >/dev/null 2>&1; then
    dbus-send --type=method_call --dest=org.onboard.Onboard \
      /org/onboard/Onboard/Keyboard org.onboard.Onboard.Keyboard.Show 2>>"$LOG_FILE" || true
  fi
  if command -v onboard-show >/dev/null 2>&1; then
    onboard-show 2>>"$LOG_FILE" || true
  fi
}

start_onboard() {
  local backend="$1"
  log "onboard start: GDK_BACKEND=$backend --layout=Compact"
  GDK_BACKEND="$backend" onboard --layout=Compact --not-show-settings >>"$LOG_FILE" 2>&1 &
  local pid=$!
  sleep 0.4
  if ! kill -0 "$pid" 2>/dev/null && ! onboard_running; then
    log "onboard ($backend) start mislukt"
    return 1
  fi
  onboard_show_dbus
  return 0
}

toggle_onboard() {
  if ! command -v onboard >/dev/null 2>&1; then
    log "onboard: niet geïnstalleerd"
    return 1
  fi

  if onboard_running; then
    pkill -x onboard 2>>"$LOG_FILE" || true
    sleep 0.2
    notify_msg "Onboard uit"
    log "onboard: gestopt"
    return 0
  fi

  if [ -n "${WAYLAND_DISPLAY:-}" ] && start_onboard wayland; then
    notify_msg "Onboard aan (Wayland)"
    log "onboard: actief (wayland)"
    return 0
  fi

  if start_onboard x11; then
    notify_msg "Onboard aan (XWayland)"
    log "onboard: actief (x11)"
    return 0
  fi

  notify_msg "Onboard start mislukt — zie osk.log"
  log "onboard: alle backends mislukt"
  return 1
}

toggle_wvkbd() {
  local bin="$1"
  if pid="$(pgrep -x "$bin" 2>/dev/null | head -1)" && [ -n "$pid" ]; then
    if kill -RTMIN "$pid" 2>>"$LOG_FILE"; then
      notify_msg "${bin} toggle"
      log "${bin}: SIGRTMIN → pid $pid"
    else
      pkill -x "$bin" 2>>"$LOG_FILE" || true
      notify_msg "${bin} uit"
      log "${bin}: kill (geen SIGRTMIN)"
    fi
    return 0
  fi

  log "${bin}: start"
  "$bin" >>"$LOG_FILE" 2>&1 &
  sleep 0.2
  if pgrep -x "$bin" >/dev/null 2>&1; then
    notify_msg "${bin} aan"
    log "${bin}: proces gestart"
  else
    notify_msg "${bin} start mislukt — zie osk.log"
    log "${bin}: start mislukt"
    return 1
  fi
  return 0
}

if [ -n "$OSK_BIN" ]; then
  toggle_wvkbd "$OSK_BIN"
  exit $?
fi

if toggle_onboard; then
  exit 0
fi

notify_msg "Geen OSK — installeer wvkbd (AUR) of onboard"
log "geen wvkbd/onboard beschikbaar"
echo "Schermtoetsenbord: installeer yay -S wvkbd-deskintl of sudo pacman -S onboard" >&2
echo "Log: $LOG_FILE" >&2
exit 1
