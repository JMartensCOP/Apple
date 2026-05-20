#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR=""
BACKUP_DIR=""
FORCE=false

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --config-dir PATH   Install configs here (default: $XDG_CONFIG_HOME or $HOME/.config)
  -y, --yes           Skip confirmation when target may not be your Hyprland session
  -h, --help          Show this help

Environment:
  BIG_SUR_CONFIG_DIR  Same as --config-dir

On Linux Hyprland, run from a terminal in your session (not Git Bash on Windows):
  ./install.sh

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

install_opera_gx() {
  if command -v opera-gx >/dev/null 2>&1; then
    echo "Opera GX is al geinstalleerd."
    return 0
  fi

  if ! command -v pacman >/dev/null 2>&1; then
    echo "Opera GX niet geinstalleerd (pacman niet beschikbaar)."
    echo "Installeer opera-gx handmatig of pas \$browser aan in keybinds.conf."
    return 0
  fi

  if ! is_linux; then
    return 0
  fi

  if [ -r /etc/os-release ]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    case "${ID:-}${ID_LIKE:-}" in
      *arch* | *Arch*) ;;
      *)
        echo "Opera GX installatie overgeslagen (geen Arch-systeem)."
        return 0
        ;;
    esac
  fi

  if pacman -Si opera-gx >/dev/null 2>&1; then
    if command -v sudo >/dev/null 2>&1; then
      echo "Installeer Opera GX via pacman..."
      sudo pacman -S --needed opera-gx
      return 0
    fi
    echo "Installeer Opera GX handmatig: pacman -S opera-gx"
    return 0
  fi

  local aur_helper=""
  if command -v yay >/dev/null 2>&1; then
    aur_helper="yay"
  elif command -v paru >/dev/null 2>&1; then
    aur_helper="paru"
  fi

  if [ -n "$aur_helper" ]; then
    echo "Opera GX staat niet in de officiele Arch-repositories (alleen AUR)."
    if [ "$FORCE" = true ]; then
      echo "Installeer Opera GX via $aur_helper (-y)..."
      if "$aur_helper" -S --needed opera-gx; then
        return 0
      fi
      echo "Opera GX installatie via $aur_helper mislukt."
    elif [ -t 0 ]; then
      read -r -p "Opera GX installeren via $aur_helper? [y/N] " answer
      case "$answer" in
        y | Y | yes | YES)
          if "$aur_helper" -S --needed opera-gx; then
            return 0
          fi
          echo "Opera GX installatie via $aur_helper mislukt."
          ;;
      esac
    else
      echo "Niet-interactieve modus: Opera GX overgeslagen."
      echo "Installeer handmatig: $aur_helper -S opera-gx"
      return 0
    fi
  else
    echo "Geen AUR-helper (yay/paru) gevonden."
  fi

  if command -v opera-gx >/dev/null 2>&1; then
    return 0
  fi

  if pacman -Si opera >/dev/null 2>&1 && command -v sudo >/dev/null 2>&1; then
    if [ "$FORCE" = true ]; then
      echo "Installeer Opera (standaard, geen GX) via pacman (-y)..."
      sudo pacman -S --needed opera
      echo "Let op: pas \$browser aan naar 'opera' in hypr/keybinds.conf."
      return 0
    elif [ -t 0 ]; then
      read -r -p "Opera (standaard, geen GX) installeren via pacman? [y/N] " answer
      case "$answer" in
        y | Y | yes | YES)
          sudo pacman -S --needed opera
          echo "Let op: pas \$browser aan naar 'opera' in hypr/keybinds.conf."
          return 0
          ;;
      esac
    fi
  fi

  echo "Opera GX niet geinstalleerd."
  echo "Installeer handmatig: yay -S opera-gx"
  echo "Of pas \$browser aan in hypr/keybinds.conf naar jouw browser."
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
  install_opera_gx
}

# Arch-pakketten uit README (Dependencies)
ARCH_PACKAGES=(
  hyprland
  waybar
  kitty
  hyprpaper
  rofi-wayland
  dunst
  wl-clipboard
  grim
  slurp
  brightnessctl
  playerctl
  pavucontrol
  networkmanager
  network-manager-applet
  bluez
  blueman
  dolphin
  ttf-jetbrains-mono-nerd
  inter-font
)

resolve_config_dir
BACKUP_DIR="$CONFIG_DIR/big-sur-theme-backup-$(date +%Y%m%d-%H%M%S)"

echo "Installing Big Sur Hyprland theme..."

if [ ! -f "$PROJECT_DIR/assets/Background.jpg" ]; then
  echo "Missing assets/Background.jpg"
  exit 1
fi

print_environment_summary
confirm_target_if_needed

install_dependencies

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
backup_path "$CONFIG_DIR/waybar/config.jsonc"
backup_path "$CONFIG_DIR/waybar/style.css"
backup_path "$CONFIG_DIR/kitty/kitty.conf"
backup_path "$CONFIG_DIR/kitty/big-sur.conf"
backup_path "$CONFIG_DIR/rofi/big-sur.rasi"
backup_path "$CONFIG_DIR/dunst/dunstrc"

WALLPAPER_DEST="$CONFIG_DIR/hypr/big-sur/Background.jpg"
cp "$PROJECT_DIR/assets/Background.jpg" "$WALLPAPER_DEST"
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
