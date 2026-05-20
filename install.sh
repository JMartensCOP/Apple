#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR=""
BACKUP_DIR=""
FORCE=false
WITH_SDDM=false

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --config-dir PATH   Install configs here (default: $XDG_CONFIG_HOME or $HOME/.config)
  --with-sddm         Install SDDM and enable graphical login (no TTY login before Hyprland)
  -y, --yes           Skip confirmation when target may not be your Hyprland session
  -h, --help          Show this help

Environment:
  BIG_SUR_CONFIG_DIR  Same as --config-dir

On Linux Hyprland, run from a terminal in your session (not Git Bash on Windows):
  ./install.sh

Graphical login (SDDM) without manual TTY login:
  ./install.sh --with-sddm
  # or after install:
  ./scripts/enable-graphical-login.sh

If you already installed from Windows/Git Bash, copy configs into Linux home:
  ./scripts/sync-to-linux-home.sh /mnt/c/Users/YOUR_USER/.config
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --config-dir)
      CONFIG_DIR="${2:?--config-dir requires a path}"
      shift 2
      ;;
    -y|--yes)
      FORCE=true
      shift
      ;;
    --with-sddm)
      WITH_SDDM=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

resolve_config_dir() {
  if [ -n "$CONFIG_DIR" ]; then
    :
  elif [ -n "${BIG_SUR_CONFIG_DIR:-}" ]; then
    CONFIG_DIR="$BIG_SUR_CONFIG_DIR"
  elif [ -n "${XDG_CONFIG_HOME:-}" ]; then
    CONFIG_DIR="$XDG_CONFIG_HOME"
  else
    CONFIG_DIR="$HOME/.config"
  fi
  mkdir -p "$CONFIG_DIR"
  CONFIG_DIR="$(cd "$CONFIG_DIR" && pwd)"
}

is_windows_shell() {
  case "$(uname -s 2>/dev/null || echo unknown)" in
    MINGW* | MSYS* | CYGWIN*) return 0 ;;
  esac
  [ -n "${MSYSTEM:-}" ] || [ -n "${WINDIR:-}" ]
}

is_linux() {
  [ "$(uname -s 2>/dev/null || echo unknown)" = "Linux" ]
}

hyprland_session_likely() {
  is_linux && { [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] || command -v hyprctl >/dev/null 2>&1; }
}

print_environment_summary() {
  echo ""
  echo "=== Omgeving ==="
  echo "  uname:        $(uname -a 2>/dev/null || echo unknown)"
  echo "  HOME:         $HOME"
  echo "  CONFIG_DIR:   $CONFIG_DIR"
  if is_windows_shell; then
    echo "  Shell:        Windows (Git Bash / MSYS) — Hyprland leest NIET deze map tenzij je daar draait."
  elif hyprland_session_likely; then
    echo "  Shell:        Linux — Hyprland-config hoort hier te staan."
  elif is_linux; then
    echo "  Shell:        Linux — controleer of dit dezelfde gebruiker/home is als je Hyprland-sessie."
  else
    echo "  Shell:        onbekend — controleer CONFIG_DIR handmatig."
  fi
  echo ""
}

confirm_target_if_needed() {
  if [ "$FORCE" = true ]; then
    return 0
  fi
  if is_windows_shell; then
    echo "WAARSCHUWING: Je draait install.sh vanuit Windows (Git Bash/MSYS)."
    echo "Configs worden geplaatst in:"
    echo "  $CONFIG_DIR"
    echo ""
    echo "Een Hyprland-sessie op Linux gebruikt meestal bijvoorbeeld:"
    echo "  /home/<gebruiker>/.config"
    echo "niet C:\\Users\\...\\.config op Windows."
    echo ""
    echo "Voer installatie opnieuw uit IN je Linux/Hyprland-sessie:"
    echo "  cd <pad-naar-dit-project> && ./install.sh"
    echo "Of kopieer later met:"
    echo "  ./scripts/sync-to-linux-home.sh <bron-.config-pad>"
    echo ""
    read -r -p "Toch installeren naar bovenstaand CONFIG_DIR? [y/N] " answer
    case "$answer" in
      y | Y | yes | YES) ;;
      *)
        echo "Geannuleerd. Gebruik ./install.sh -y om deze vraag over te slaan."
        exit 0
        ;;
    esac
  fi
}

install_dependencies() {
  if ! command -v pacman >/dev/null 2>&1; then
    echo "pacman niet gevonden; pakketinstallatie overgeslagen."
    echo "Op Arch Linux: sudo pacman -S --needed ${ARCH_PACKAGES[*]}"
    return 0
  fi

  if ! is_linux; then
    echo "Geen Linux-omgeving; pakketinstallatie overgeslagen."
    return 0
  fi

  if [ -r /etc/os-release ]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    case "${ID:-}${ID_LIKE:-}" in
      *arch* | *Arch*) ;;
      *)
        echo "Waarschuwing: dit lijkt geen Arch-systeem (${PRETTY_NAME:-onbekend})."
        echo "Pakketinstallatie wordt overgeslagen; gebruik distro-specifieke pakketnamen."
        return 0
        ;;
    esac
  fi

  if ! command -v sudo >/dev/null 2>&1; then
    echo "sudo niet gevonden; installeer pakketten handmatig als root:"
    echo "pacman -S --needed ${ARCH_PACKAGES[*]}"
    return 0
  fi

  echo "Installeer benodigde pakketten via pacman..."
  sudo pacman -S --needed "${ARCH_PACKAGES[@]}"
}

enable_audio_services() {
  local script="$PROJECT_DIR/scripts/enable-audio.sh"

  if is_windows_shell; then
    echo "Audio-services: overgeslagen (Windows/Git Bash — geen systemd user-sessie)."
    echo "  Op Linux in je Hyprland-sessie: bash \"$script\""
    return 0
  fi

  if ! is_linux; then
    echo "Audio-services: overgeslagen (geen Linux)."
    return 0
  fi

  if [ ! -f "$script" ]; then
    echo "Audio-services: $script ontbreekt; overgeslagen."
    return 0
  fi

  chmod +x "$script" 2>/dev/null || true
  bash "$script"
}

enable_network_services() {
  local script="$PROJECT_DIR/scripts/enable-network.sh"

  if is_windows_shell; then
    echo "NetworkManager: overgeslagen (Windows/Git Bash)."
    echo "  Op Linux: bash \"$script\""
    return 0
  fi

  if ! is_linux; then
    echo "NetworkManager: overgeslagen (geen Linux)."
    return 0
  fi

  if [ ! -f "$script" ]; then
    echo "NetworkManager: $script ontbreekt; overgeslagen."
    return 0
  fi

  chmod +x "$script" 2>/dev/null || true
  bash "$script" -y
}

install_display_manager() {
  local script="$PROJECT_DIR/scripts/enable-graphical-login.sh"

  if is_windows_shell || ! is_linux; then
    echo "SDDM: overgeslagen (alleen op Linux Hyprland/Arch)."
    echo "  Zie README: Geen terminal bij opstarten"
    return 0
  fi

  if [ ! -f "$script" ]; then
    echo "SDDM: $script ontbreekt; overgeslagen."
    return 0
  fi

  chmod +x "$script" 2>/dev/null || true
  if [ "$WITH_SDDM" = true ]; then
    bash "$script" -y
  elif [ "$FORCE" = true ]; then
    echo "SDDM overgeslagen (-y). Grafisch inloggen: ./scripts/enable-graphical-login.sh"
  else
    echo ""
    echo "Grafisch inloggen (SDDM) voorkomt handmatige TTY-login vóór Hyprland."
    read -r -p "SDDM nu installeren en inschakelen? [y/N] " answer
    case "$answer" in
      y | Y | yes | YES)
        bash "$script" -y
        ;;
      *)
        echo "SDDM overgeslagen. Later: ./scripts/enable-graphical-login.sh"
        ;;
    esac
  fi
}

verify_hyprland_session_desktop() {
  local desktop="/usr/share/wayland-sessions/hyprland.desktop"

  if ! is_linux; then
    return 0
  fi

  if [ -f "$desktop" ]; then
    echo "Hyprland-sessie: $desktop (SDDM/GDM kan Hyprland tonen)"
  elif command -v Hyprland >/dev/null 2>&1 || command -v hyprland >/dev/null 2>&1; then
    echo "WAARSCHUWING: $desktop ontbreekt — herinstalleer hyprland voor display manager."
  fi
}

# Arch-pakketten uit README (Dependencies)
ARCH_PACKAGES=(
  hyprland
  waybar
  kitty
  hyprpaper
  hyprlock
  rofi-wayland
  dunst
  wl-clipboard
  grim
  slurp
  brightnessctl
  playerctl
  pavucontrol
  pipewire
  pipewire-pulse
  pipewire-alsa
  wireplumber
  alsa-utils
  alsa-firmware
  sof-firmware
  networkmanager
  network-manager-applet
  iw
  wireless-regdb
  linux-firmware
  bluez
  blueman
  upower
  dolphin
  firefox
  code
  ttf-jetbrains-mono-nerd
  inter-font
  wvkbd
  wlr-randr
)

resolve_config_dir
BACKUP_DIR="$CONFIG_DIR/big-sur-theme-backup-$(date +%Y%m%d-%H%M%S)"

echo "Installing Big Sur Hyprland theme..."

if [ ! -f "$PROJECT_DIR/assets/Background.jpg" ]; then
  echo "Missing assets/Background.jpg"
  exit 1
fi

if [ ! -f "$PROJECT_DIR/assets/Lockscreen.jpg" ]; then
  echo "Missing assets/Lockscreen.jpg (lock screen wallpaper; see README)"
  exit 1
fi

print_environment_summary
confirm_target_if_needed

install_dependencies
enable_audio_services
enable_network_services
install_display_manager
verify_hyprland_session_desktop

mkdir -p "$BACKUP_DIR"
mkdir -p "$CONFIG_DIR/hypr"
mkdir -p "$CONFIG_DIR/waybar"
mkdir -p "$CONFIG_DIR/kitty"
mkdir -p "$CONFIG_DIR/rofi"
mkdir -p "$CONFIG_DIR/dunst"
mkdir -p "$CONFIG_DIR/hypr/big-sur"
mkdir -p "$CONFIG_DIR/big-sur/scripts"

backup_path() {
  local path="$1"
  if [ -e "$path" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${path#$CONFIG_DIR/}")"
    cp -r "$path" "$BACKUP_DIR/${path#$CONFIG_DIR/}"
  fi
}

backup_path "$CONFIG_DIR/hypr/hyprland.conf"
backup_path "$CONFIG_DIR/hypr/hyprpaper.conf"
backup_path "$CONFIG_DIR/hypr/hyprlock.conf"
backup_path "$CONFIG_DIR/waybar/config.jsonc"
backup_path "$CONFIG_DIR/waybar/style.css"
backup_path "$CONFIG_DIR/kitty/kitty.conf"
backup_path "$CONFIG_DIR/kitty/big-sur.conf"
backup_path "$CONFIG_DIR/rofi/big-sur.rasi"
backup_path "$CONFIG_DIR/dunst/dunstrc"

WALLPAPER_DEST="$CONFIG_DIR/hypr/big-sur/Background.jpg"
LOCKSCREEN_DEST="$CONFIG_DIR/hypr/big-sur/Lockscreen.jpg"
cp "$PROJECT_DIR/assets/Background.jpg" "$WALLPAPER_DEST"
cp "$PROJECT_DIR/assets/Lockscreen.jpg" "$LOCKSCREEN_DEST"
cp "$PROJECT_DIR/scripts/"*.sh "$CONFIG_DIR/big-sur/scripts/"
chmod +x "$CONFIG_DIR/big-sur/scripts/"*.sh
cp "$PROJECT_DIR/hypr/"*.conf "$CONFIG_DIR/hypr/"
cp "$PROJECT_DIR/waybar/config.jsonc" "$CONFIG_DIR/waybar/config.jsonc"
cp "$PROJECT_DIR/waybar/style.css" "$CONFIG_DIR/waybar/style.css"
cp "$PROJECT_DIR/kitty/kitty.conf" "$CONFIG_DIR/kitty/kitty.conf"
cp "$PROJECT_DIR/kitty/big-sur.conf" "$CONFIG_DIR/kitty/big-sur.conf"

if [ -f "$PROJECT_DIR/rofi/big-sur.rasi" ]; then
  cp "$PROJECT_DIR/rofi/big-sur.rasi" "$CONFIG_DIR/rofi/big-sur.rasi"
fi

if [ -f "$PROJECT_DIR/dunst/dunstrc" ]; then
  cp "$PROJECT_DIR/dunst/dunstrc" "$CONFIG_DIR/dunst/dunstrc"
fi

chmod +x "$PROJECT_DIR/scripts/"*.sh 2>/dev/null || true

echo ""
echo "=== Installatie voltooid ==="
echo "Config-map (gebruik deze paden in je Hyprland-sessie):"
echo "  $CONFIG_DIR/hypr/hyprland.conf"
echo "  $CONFIG_DIR/hypr/hyprpaper.conf"
echo "  $WALLPAPER_DEST  (bron: assets/Background.jpg)"
echo "  $LOCKSCREEN_DEST  (bron: assets/Lockscreen.jpg)"
echo "  $CONFIG_DIR/hypr/hyprlock.conf"
echo "  $CONFIG_DIR/waybar/config.jsonc"
echo "  $CONFIG_DIR/waybar/style.css"
echo "  $CONFIG_DIR/kitty/kitty.conf"
echo "  $CONFIG_DIR/kitty/big-sur.conf"
echo "  $CONFIG_DIR/rofi/big-sur.rasi"
echo "  $CONFIG_DIR/dunst/dunstrc"
echo ""
echo "Backup: $BACKUP_DIR"
echo ""
if is_windows_shell; then
  echo "Je bent op Windows: start Hyprland op Linux en voer daar ./install.sh uit,"
  echo "of: ./scripts/sync-to-linux-home.sh \"$CONFIG_DIR\""
  echo ""
fi
echo "In je Hyprland-sessie:"
echo "  hyprctl reload"
echo "  $CONFIG_DIR/big-sur/scripts/start-waybar.sh"
echo "  $PROJECT_DIR/scripts/reload-theme.sh"
echo "  $PROJECT_DIR/scripts/apply-wallpaper.sh"
echo ""
echo "Geen TTY-login vóór desktop:"
echo "  ./scripts/enable-graphical-login.sh   # SDDM (grafisch inloggen → Hyprland)"
echo ""
echo "WiFi / NetworkManager:"
echo "  $CONFIG_DIR/big-sur/scripts/enable-network.sh"
