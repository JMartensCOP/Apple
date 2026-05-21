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

open_display() {
  if command -v wdisplays >/dev/null 2>&1; then
    log "open wdisplays"
    exec wdisplays "$@"
  fi

  local hint="Geen wdisplays. Optioneel: yay -S wdisplays. Monitoren: hyprctl monitors"
  notify "$hint"
  log "$hint"
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl monitors >>"$LOG_FILE" 2>&1 || true
  fi
}

run_choice() {
  local choice="$1"
  log "keuze: $choice"

  case "$choice" in
    Geluid)
      if command -v pavucontrol >/dev/null 2>&1; then
        exec pavucontrol "$@"
      fi
      notify "pavucontrol niet gevonden (pacman -S pavucontrol)"
      exit 1
      ;;
    WiFi)
      if command -v nm-connection-editor >/dev/null 2>&1; then
        exec nm-connection-editor "$@"
      fi
      notify "nm-connection-editor niet gevonden"
      exit 1
      ;;
    Bluetooth)
      exec bash "$SCRIPT_DIR/open-bluetooth.sh" "$@"
      ;;
    Beeldscherm)
      open_display
      ;;
    Toetsenbord)
      exec bash "$SCRIPT_DIR/toggle-osk.sh" "$@"
      ;;
    Vergrendelen)
      if command -v hyprlock >/dev/null 2>&1; then
        exec hyprlock "$@"
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

  local choice
  choice="$(
    printf '%s\n' \
      Geluid \
      WiFi \
      Bluetooth \
      Beeldscherm \
      Toetsenbord \
      Vergrendelen \
      "Herstart sessie" | rofi "${rofi_args[@]}"
  )" || return 1

  if [ -z "$choice" ]; then
    log "menu geannuleerd"
    return 0
  fi

  run_choice "$choice"
}

open_fallback_settings() {
  if command -v gnome-control-center >/dev/null 2>&1; then
    log "fallback: gnome-control-center"
    notify "Systeeminstellingen (GNOME)"
    exec gnome-control-center "$@"
  fi

  if command -v systemsettings5 >/dev/null 2>&1; then
    log "fallback: systemsettings5"
    notify "Systeeminstellingen (KDE)"
    exec systemsettings5 "$@"
  fi

  notify "Geen instellingen-UI. Installeer rofi, gnome-control-center of systemsettings5."
  exit 1
}

main() {
  log "settings-menu gestart (pid $$)"

  if show_rofi_menu; then
    exit 0
  fi

  log "rofi niet beschikbaar of mislukt — fallback"
  open_fallback_settings
}

main "$@"
