#!/usr/bin/env bash
# Big Sur — algemeen instellingenmenu (rofi + fallbacks).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${HOME}/.cache/big-sur/settings.log"
ROFI_THEME="${HOME}/.config/rofi/big-sur.rasi"

log() {
  mkdir -p "$(dirname "$LOG_FILE")"
  printf '%s %s\n' "$(date -Iseconds 2>/dev/null || date)" "$*" >>"$LOG_FILE"
}

notify() {
  local msg="$1"
  notify-send "Instellingen" "$msg" 2>/dev/null || true
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

run_choice() {
  local choice="$1"
  shift || true
  log "keuze: $choice"

  case "$choice" in
    Geluid)
      if cmd=$(resolve_cmd pavucontrol); then
        log "open $cmd"
        exec "$cmd" "$@"
      fi
      notify "pavucontrol niet gevonden (sudo pacman -S pavucontrol)"
      exit 1
      ;;
    WiFi)
      if cmd=$(resolve_cmd nm-connection-editor); then
        log "open $cmd"
        exec "$cmd" "$@"
      fi
      notify "nm-connection-editor niet gevonden (sudo pacman -S network-manager-applet)"
      exit 1
      ;;
    Bluetooth)
      exec bash "$SCRIPT_DIR/open-bluetooth.sh" "$@"
      ;;
    Beeldscherm)
      exec bash "$SCRIPT_DIR/open-display-settings.sh" "$@"
      ;;
    Toetsenbord)
      exec bash "$SCRIPT_DIR/toggle-osk.sh" "$@"
      ;;
    Vergrendelen)
      if cmd=$(resolve_cmd hyprlock); then
        log "open $cmd"
        exec "$cmd" "$@"
      fi
      notify "hyprlock niet gevonden"
      exit 1
      ;;
    "Herstart sessie")
      exec bash "$SCRIPT_DIR/restart-session.sh" "$@"
      ;;
    *)
      notify "Onbekende keuze: $choice"
      exit 1
      ;;
  esac
}

show_rofi_menu() {
  command -v rofi >/dev/null 2>&1 || return 1

  local rofi_args=(-dmenu -p "Instellingen" -i)
  if [ -f "$ROFI_THEME" ]; then
    rofi_args+=(-theme "$ROFI_THEME")
  fi

  local choice=""
  local rofi_exit=0
  set +e
  choice="$(
    printf '%s\n' \
      Geluid \
      WiFi \
      Bluetooth \
      Beeldscherm \
      Toetsenbord \
      Vergrendelen \
      "Herstart sessie" | rofi "${rofi_args[@]}"
  )"
  rofi_exit=$?
  set -e

  if [ "$rofi_exit" -ne 0 ] || [ -z "$choice" ]; then
    log "menu geannuleerd of leeg (rofi exit=$rofi_exit)"
    return 0
  fi

  run_choice "$choice"
}

open_fallback_settings() {
  if cmd=$(resolve_cmd gnome-control-center); then
    log "fallback: $cmd"
    notify "Systeeminstellingen (GNOME)"
    exec "$cmd" "$@"
  fi

  if cmd=$(resolve_cmd systemsettings5); then
    log "fallback: $cmd"
    notify "Systeeminstellingen (KDE)"
    exec "$cmd" "$@"
  fi

  notify "Geen instellingen-UI. Installeer rofi, gnome-control-center of systemsettings5."
  exit 1
}

main() {
  log "settings-menu gestart (pid $$)"

  if command -v rofi >/dev/null 2>&1; then
    show_rofi_menu
    exit 0
  fi

  log "rofi niet beschikbaar — fallback"
  open_fallback_settings
}

main "$@"
