#!/usr/bin/env bash
# Install and enable SDDM for graphical login → Hyprland (no manual TTY login).
set -euo pipefail

SDDM_REQUIRED=(sddm)
# Qt6 theme/config tool — optional; SDDM works without it (Arch: extra/qt6ct, not qt6-ct)
SDDM_OPTIONAL=(qt6ct)
HYPRLAND_SESSION="/usr/share/wayland-sessions/hyprland.desktop"

is_windows_shell() {
  case "$(uname -s 2>/dev/null || echo unknown)" in
    MINGW* | MSYS* | CYGWIN*) return 0 ;;
  esac
  [ -n "${MSYSTEM:-}" ] || [ -n "${WINDIR:-}" ]
}

usage() {
  cat <<'EOF'
Usage: enable-graphical-login.sh [options]

Install SDDM on Arch Linux and enable graphical login before Hyprland.
Hyprlock-on-start only runs after Hyprland — this fixes the TTY login before desktop.

Options:
  -y, --yes     Skip confirmation prompts
  -h, --help    Show this help

After setup, reboot. At the SDDM screen choose session "Hyprland" and log in.
Remove "exec Hyprland" from ~/.bash_profile / ~/.zprofile if present (avoid double start).
EOF
}

FORCE=false
while [ $# -gt 0 ]; do
  case "$1" in
    -y|--yes) FORCE=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if is_windows_shell || [ "$(uname -s 2>/dev/null || echo unknown)" != "Linux" ]; then
  echo "enable-graphical-login: alleen op Linux (niet Git Bash op Windows)."
  exit 0
fi

if ! command -v pacman >/dev/null 2>&1; then
  echo "enable-graphical-login: pacman niet gevonden — handmatig SDDM installeren op je distro."
  exit 1
fi

if [ -r /etc/os-release ]; then
  # shellcheck source=/dev/null
  . /etc/os-release
  case "${ID:-}${ID_LIKE:-}" in
    *arch* | *Arch*) ;;
    *)
      echo "enable-graphical-login: dit script is bedoeld voor Arch. Op ${PRETTY_NAME:-jouw distro}:"
      echo "  installeer sddm + display-manager, enable de service, kies Hyprland als sessie."
      exit 1
      ;;
  esac
fi

if [ "$FORCE" != true ]; then
  echo "Dit installeert SDDM en schakelt grafisch inloggen in (vervangt handmatige TTY-login)."
  echo "Je moet daarna opnieuw opstarten. Bestaande auto-start van Hyprland in shell-profielen"
  echo "moet je verwijderen om dubbele sessies te voorkomen."
  echo ""
  read -r -p "Doorgaan? [y/N] " answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *) echo "Geannuleerd."; exit 0 ;;
  esac
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "enable-graphical-login: sudo vereist. Als root:"
  echo "  pacman -S --needed ${SDDM_REQUIRED[*]}"
  echo "  pacman -S --needed ${SDDM_OPTIONAL[*]}   # optioneel (Qt6-thema)"
  echo "  systemctl enable --now sddm.service"
  exit 1
fi

echo "enable-graphical-login: installeer ${SDDM_REQUIRED[*]}..."
sudo pacman -S --needed "${SDDM_REQUIRED[@]}"

for pkg in "${SDDM_OPTIONAL[@]}"; do
  echo "enable-graphical-login: optioneel — ${pkg} (SDDM werkt ook zonder)..."
  if sudo pacman -S --needed "$pkg"; then
    :
  else
    echo "enable-graphical-login: ${pkg} overgeslagen (optioneel)."
  fi
done

if ! command -v Hyprland >/dev/null 2>&1 && ! command -v hyprland >/dev/null 2>&1; then
  echo "enable-graphical-login: WAARSCHUWING — hyprland lijkt niet geïnstalleerd."
  echo "  sudo pacman -S hyprland"
fi

if [ -f "$HYPRLAND_SESSION" ]; then
  echo "enable-graphical-login: Hyprland-sessie gevonden: $HYPRLAND_SESSION"
else
  echo "enable-graphical-login: WAARSCHUWING — $HYPRLAND_SESSION ontbreekt."
  echo "  Installeer hyprland; SDDM toont dan 'Hyprland' in de sessielijst."
fi

# Optional minimal SDDM config (session picker + wayland default)
if [ ! -d /etc/sddm.conf.d ]; then
  echo "enable-graphical-login: maak /etc/sddm.conf.d/..."
  sudo mkdir -p /etc/sddm.conf.d
fi

SDDM_THEME="/etc/sddm.conf.d/big-sur-hyprland.conf"
if [ ! -f "$SDDM_THEME" ]; then
  echo "enable-graphical-login: basis SDDM-config ($SDDM_THEME)..."
  sudo tee "$SDDM_THEME" >/dev/null <<'EOF'
[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Wayland]
SessionDir=/usr/share/wayland-sessions
EOF
fi

echo "enable-graphical-login: schakel sddm.service in..."
sudo systemctl enable --now sddm.service

echo ""
echo "=== Grafisch inloggen ingeschakeld ==="
echo "  SDDM status:  systemctl status sddm"
echo "  Hyprland:     $HYPRLAND_SESSION"
echo ""
echo "Controleer shell-profielen — verwijder regels zoals 'exec Hyprland' of 'startx' uit:"
echo "  ~/.bash_profile  ~/.zprofile  ~/.xprofile"
echo ""
echo "Start opnieuw op. Kies sessie 'Hyprland' op het SDDM-scherm."
echo "Na inloggen: desktop met wallpaper en Waybar. Vergrendelen met Super+L (hyprlock)."
