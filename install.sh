#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/big-sur-theme-backup-$(date +%Y%m%d-%H%M%S)"

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
  ttf-jetbrains-mono-nerd
  inter-font
)

install_dependencies() {
  if ! command -v pacman >/dev/null 2>&1; then
    echo "pacman niet gevonden; pakketinstallatie overgeslagen."
    echo "Op Arch Linux: sudo pacman -S --needed ${ARCH_PACKAGES[*]}"
    return 0
  fi

  if [ "$(uname -s 2>/dev/null || echo unknown)" != "Linux" ]; then
    echo "Geen Linux-omgeving; pakketinstallatie overgeslagen."
    return 0
  fi

  if [ -r /etc/os-release ]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    case "${ID:-}${ID_LIKE:-}" in
      *arch*|*Arch*)
        ;;
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

echo "Installing Big Sur Hyprland theme..."

if [ ! -f "$PROJECT_DIR/assets/Background.jpg" ]; then
  echo "Missing assets/Background.jpg"
  exit 1
fi

install_dependencies

mkdir -p "$BACKUP_DIR"
mkdir -p "$HOME/.config/hypr"
mkdir -p "$HOME/.config/waybar"
mkdir -p "$HOME/.config/kitty"
mkdir -p "$HOME/.config/rofi"
mkdir -p "$HOME/.config/dunst"
mkdir -p "$HOME/.config/hypr/big-sur"

backup_path() {
  local path="$1"
  if [ -e "$path" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${path#$HOME/.config/}")"
    cp -r "$path" "$BACKUP_DIR/${path#$HOME/.config/}"
  fi
}

backup_path "$HOME/.config/hypr/hyprland.conf"
backup_path "$HOME/.config/hypr/hyprpaper.conf"
backup_path "$HOME/.config/waybar/config.jsonc"
backup_path "$HOME/.config/waybar/style.css"
backup_path "$HOME/.config/kitty/kitty.conf"
backup_path "$HOME/.config/kitty/big-sur.conf"
backup_path "$HOME/.config/rofi/big-sur.rasi"
backup_path "$HOME/.config/dunst/dunstrc"

cp "$PROJECT_DIR/assets/Background.jpg" "$HOME/.config/hypr/big-sur/Background.jpg"
cp "$PROJECT_DIR/hypr/"*.conf "$HOME/.config/hypr/"
cp "$PROJECT_DIR/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
cp "$PROJECT_DIR/waybar/style.css" "$HOME/.config/waybar/style.css"
cp "$PROJECT_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
cp "$PROJECT_DIR/kitty/big-sur.conf" "$HOME/.config/kitty/big-sur.conf"

if [ -f "$PROJECT_DIR/rofi/big-sur.rasi" ]; then
  cp "$PROJECT_DIR/rofi/big-sur.rasi" "$HOME/.config/rofi/big-sur.rasi"
fi

if [ -f "$PROJECT_DIR/dunst/dunstrc" ]; then
  cp "$PROJECT_DIR/dunst/dunstrc" "$HOME/.config/dunst/dunstrc"
fi

chmod +x "$PROJECT_DIR/scripts/"*.sh 2>/dev/null || true

echo "Installation complete."
echo "Backup created at: $BACKUP_DIR"
echo "Reload Hyprland with: hyprctl reload"
echo "Restart Waybar if needed: pkill waybar && waybar &"
