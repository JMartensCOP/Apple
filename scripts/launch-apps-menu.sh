#!/usr/bin/env bash
# Big Sur — Apps-launcher (rofi submenu). Geopend vanuit settings-menu.sh → Apps.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${HOME}/.cache/big-sur/apps-menu.log"
ROFI_THEME="${HOME}/.config/rofi/big-sur.rasi"

log() {
  mkdir -p "$(dirname "$LOG_FILE")"
  printf '%s %s\n' "$(date -Iseconds 2>/dev/null || date)" "$*" >>"$LOG_FILE"
}

notify() {
  notify-send "Apps" "$1" 2>/dev/null || true
  log "$1"
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

open_in_kitty() {
  local shell_cmd="$1"
  if ! cmd=$(resolve_cmd kitty); then
    notify "kitty niet gevonden (sudo pacman -S kitty)"
    exit 1
  fi
  log "kitty: $shell_cmd"
  exec "$cmd" bash -lc "$shell_cmd"
}

run_app() {
  local choice="$1"
  shift || true
  log "app: $choice"

  case "$choice" in
    Firefox)
      if cmd=$(resolve_cmd firefox); then
        exec "$cmd" "$@"
      fi
      notify "firefox niet gevonden"
      exit 1
      ;;
    Kitty)
      if cmd=$(resolve_cmd kitty); then
        exec "$cmd" "$@"
      fi
      notify "kitty niet gevonden"
      exit 1
      ;;
    Dolphin)
      if cmd=$(resolve_cmd dolphin); then
        exec "$cmd" "$@"
      fi
      notify "dolphin niet gevonden"
      exit 1
      ;;
    VLC)
      if cmd=$(resolve_cmd vlc); then
        exec "$cmd" "$@"
      fi
      notify "vlc niet gevonden (sudo pacman -S vlc)"
      exit 1
      ;;
    LibreOffice)
      if cmd=$(resolve_cmd libreoffice); then
        exec "$cmd" "$@"
      fi
      notify "LibreOffice niet gevonden (sudo pacman -S libreoffice-fresh)"
      exit 1
      ;;
    KeePassXC)
      if cmd=$(resolve_cmd keepassxc); then
        exec "$cmd" "$@"
      fi
      notify "keepassxc niet gevonden"
      exit 1
      ;;
    Thunderbird)
      if cmd=$(resolve_cmd thunderbird); then
        exec "$cmd" "$@"
      fi
      notify "thunderbird niet gevonden"
      exit 1
      ;;
    GParted)
      if cmd=$(resolve_cmd gparted); then
        exec "$cmd" "$@"
      fi
      notify "gparted niet gevonden"
      exit 1
      ;;
    "GNOME Disks")
      if cmd=$(resolve_cmd gnome-disks); then
        exec "$cmd" "$@"
      fi
      notify "gnome-disks niet gevonden (sudo pacman -S gnome-disk-utility)"
      exit 1
      ;;
    Wireshark)
      if cmd=$(resolve_cmd wireshark wireshark-qt); then
        exec "$cmd" "$@"
      fi
      notify "wireshark niet gevonden (sudo pacman -S wireshark-qt)"
      exit 1
      ;;
    nmap)
      if ! resolve_cmd nmap >/dev/null; then
        notify "nmap niet gevonden (sudo pacman -S nmap)"
        exit 1
      fi
      open_in_kitty "nmap --help | head -n 30; echo; echo 'Voorbeeld: nmap -sn 192.168.1.0/24'; exec \$SHELL"
      ;;
    Remmina)
      if cmd=$(resolve_cmd remmina); then
        exec "$cmd" "$@"
      fi
      notify "remmina niet gevonden"
      exit 1
      ;;
    Steam)
      exec bash "$SCRIPT_DIR/launch-steam.sh" "$@"
      ;;
    Lutris)
      exec bash "$SCRIPT_DIR/launch-lutris.sh" "$@"
      ;;
    "Prism Launcher")
      exec bash "$SCRIPT_DIR/launch-prism.sh" "$@"
      ;;
    "VS Code")
      exec bash "$SCRIPT_DIR/launch-code.sh" "$@"
      ;;
    Docker)
      if ! resolve_cmd docker >/dev/null; then
        notify "docker niet gevonden (sudo pacman -S docker docker-compose)"
        exit 1
      fi
      if docker info >/dev/null 2>&1; then
        open_in_kitty "docker --version; echo; docker ps; echo; exec \$SHELL"
      else
        notify "Docker CLI geïnstalleerd. Activeer: sudo systemctl enable --now docker  (voeg user toe aan groep docker)"
        open_in_kitty "docker --version 2>/dev/null || true; echo; echo 'Start daemon: sudo systemctl enable --now docker'; exec \$SHELL"
      fi
      ;;
    btop)
      if resolve_cmd btop >/dev/null; then
        open_in_kitty "exec btop"
      fi
      notify "btop niet gevonden (sudo pacman -S btop)"
      exit 1
      ;;
    "App Store")
      exec bash "$SCRIPT_DIR/launch-app-store.sh" "$@"
      ;;
    "Flatpak-lijst")
      if ! resolve_cmd flatpak >/dev/null; then
        notify "flatpak niet gevonden (sudo pacman -S flatpak)"
        exit 1
      fi
      open_in_kitty "flatpak --version; echo; flatpak list; echo; exec \$SHELL"
      ;;
    *)
      notify "Onbekende app: $choice"
      exit 1
      ;;
  esac
}

show_category_menu() {
  local category="$1"
  local -a items=()

  case "$category" in
    "Dagelijks")
      items=(Firefox Kitty Dolphin "VS Code")
      ;;
    "Media & kantoor")
      items=(VLC LibreOffice KeePassXC Thunderbird)
      ;;
    Systeem)
      items=(GParted "GNOME Disks" btop)
      ;;
    Winkel)
      items=("App Store" "Flatpak-lijst")
      ;;
    Netwerk)
      items=(Wireshark nmap Remmina)
      ;;
    Gaming)
      items=(Steam Lutris "Prism Launcher")
      ;;
    *)
      notify "Onbekende categorie: $category"
      exit 1
      ;;
  esac

  local rofi_args=(-dmenu -p "Apps — $category" -i)
  if [ -f "$ROFI_THEME" ]; then
    rofi_args+=(-theme "$ROFI_THEME")
  fi

  local choice=""
  local rofi_exit=0
  set +e
  choice="$(printf '%s\n' "${items[@]}" | rofi "${rofi_args[@]}")"
  rofi_exit=$?
  set -e

  if [ "$rofi_exit" -ne 0 ] || [ -z "$choice" ]; then
    log "apps submenu geannuleerd ($category)"
    exec bash "$SCRIPT_DIR/launch-apps-menu.sh"
  fi

  run_app "$choice"
}

show_rofi_menu() {
  command -v rofi >/dev/null 2>&1 || return 1

  local rofi_args=(-dmenu -p "Apps" -i)
  if [ -f "$ROFI_THEME" ]; then
    rofi_args+=(-theme "$ROFI_THEME")
  fi

  local choice=""
  local rofi_exit=0
  set +e
  choice="$(
    printf '%s\n' \
      Dagelijks \
      "Media & kantoor" \
      Winkel \
      Systeem \
      Netwerk \
      Gaming | rofi "${rofi_args[@]}"
  )"
  rofi_exit=$?
  set -e

  if [ "$rofi_exit" -ne 0 ] || [ -z "$choice" ]; then
    log "apps-menu geannuleerd"
    return 0
  fi

  show_category_menu "$choice"
}

main() {
  log "launch-apps-menu gestart (pid $$)"

  if command -v rofi >/dev/null 2>&1; then
    show_rofi_menu
    exit 0
  fi

  notify "rofi vereist voor het Apps-menu"
  exit 1
}

main "$@"
