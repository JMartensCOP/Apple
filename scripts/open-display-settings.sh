#!/usr/bin/env bash
# Open display / monitor settings for Hyprland (GUI with terminal fallback).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${HOME}/.cache/big-sur/settings.log"
KITTY_CLASS="big-sur-displays"
KITTY_TITLE="Big Sur — Beeldscherm"

log() {
  mkdir -p "$(dirname "$LOG_FILE")"
  printf '%s %s\n' "$(date -Iseconds 2>/dev/null || date)" "$*" >>"$LOG_FILE"
}

notify() {
  local msg="$1"
  notify-send "Beeldscherm" "$msg" 2>/dev/null || true
  log "$msg"
}

resolve_cmd() {
  local candidate
  for candidate in "$@"; do
    if command -v "$candidate" >/dev/null 2>&1; then
      command -v "$candidate"
      return 0
    fi
  done
  return 1
}

open_gui() {
  local cmd="$1"
  log "open $cmd"
  notify "Openen: $(basename "$cmd")"
  exec "$cmd" "${@:2}"
}

open_monitor_terminal() {
  local tmp monitors term
  tmp="$(mktemp "${TMPDIR:-/tmp}/big-sur-monitors.XXXXXX")"
  monitors="$(hyprctl monitors 2>&1 || true)"
  if [ -z "$monitors" ]; then
    monitors="hyprctl monitors: geen uitvoer (Hyprland actief?)"
  fi
  printf '%s\n' "$monitors" >"$tmp"

  notify "Geen beeldscherm-app. Monitoren in terminal (Enter sluit)."

  for term in kitty foot alacritty; do
    if command -v "$term" >/dev/null 2>&1; then
      log "fallback terminal: $term ($tmp)"
      case "$term" in
        kitty)
          exec kitty \
            --class "$KITTY_CLASS" \
            --title "$KITTY_TITLE" \
            bash -lc "cat '$tmp'; echo; echo 'Tip: sudo pacman -S wdisplays'; echo; echo 'Druk Enter om te sluiten…'; read -r; rm -f '$tmp'"
          ;;
        foot)
          exec foot -a "$KITTY_CLASS" -T "$KITTY_TITLE" \
            bash -lc "cat '$tmp'; echo; echo 'Tip: sudo pacman -S wdisplays'; echo; echo 'Druk Enter om te sluiten…'; read -r; rm -f '$tmp'"
          ;;
        alacritty)
          exec alacritty --class "$KITTY_CLASS" --title "$KITTY_TITLE" \
            -e bash -lc "cat '$tmp'; echo; echo 'Tip: sudo pacman -S wdisplays'; echo; echo 'Druk Enter om te sluiten…'; read -r; rm -f '$tmp'"
          ;;
      esac
    fi
  done

  rm -f "$tmp"
  notify "Geen terminal gevonden. Zie ~/.cache/big-sur/settings.log"
  log "monitorinfo:$monitors"
  exit 1
}

main() {
  log "open-display-settings gestart (pid $$)"

  if cmd=$(resolve_cmd wdisplays); then
    open_gui "$cmd" "$@"
  fi

  if cmd=$(resolve_cmd nwg-displays); then
    open_gui "$cmd" "$@"
  fi

  if cmd=$(resolve_cmd hyprland-settings hyprsettings hyprgui); then
    open_gui "$cmd" "$@"
  fi

  open_monitor_terminal
}

main "$@"
