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

  # Spotify: spotify-launcher zit in ARCH_PACKAGES (Arch extra). Geen volledige -Syu
  # bij elke install — --needed installeert alleen ontbrekende pakketten.
  local pacman_extra=()
  if etcher_pacman_package="$(etcher_pacman_package_name 2>/dev/null || true)" && [ -n "$etcher_pacman_package" ]; then
    pacman_extra+=("$etcher_pacman_package")
    echo "Balena Etcher: $etcher_pacman_package gevonden in officiële repos — via pacman."
  fi
  echo "Installeer benodigde pakketten via pacman..."
  sudo pacman -S --needed "${ARCH_PACKAGES[@]}" "${pacman_extra[@]}"
}

install_osk_optional() {
  if is_windows_shell || ! is_linux; then
    return 0
  fi

  if command -v wvkbd-deskintl >/dev/null 2>&1 || command -v wvkbd-mobintl >/dev/null 2>&1; then
    echo "Schermtoetsenbord: wvkbd-binaries gevonden."
    return 0
  fi

  if command -v yay >/dev/null 2>&1; then
    echo ""
    echo "=== Schermtoetsenbord (wvkbd via AUR) ==="
    echo "Probeer wvkbd-deskintl te installeren met yay..."
    if yay -S --needed --noconfirm wvkbd-deskintl; then
      if command -v wvkbd-deskintl >/dev/null 2>&1; then
        echo "Schermtoetsenbord: wvkbd-deskintl geïnstalleerd."
        return 0
      fi
    else
      echo "yay installatie mislukt — onboard (pacman) blijft fallback."
    fi
  fi

  if command -v onboard >/dev/null 2>&1; then
    echo "Schermtoetsenbord: onboard (pacman-fallback) — Waybar 󰌌 werkt."
    if ! command -v yay >/dev/null 2>&1; then
      echo "  Voor native Wayland-OSK: installeer yay en run: yay -S wvkbd-deskintl"
    fi
    return 0
  fi

  echo ""
  echo "=== Schermtoetsenbord (wvkbd) ==="
  echo "wvkbd staat niet in de officiële Arch-repositories (alleen AUR)."
  echo "Fallback onboard hoort via pacman geïnstalleerd te zijn (install.sh)."
  echo "Geen systemd-service — start via Waybar 󰌌 of:"
  echo "  bash \"$PROJECT_DIR/scripts/toggle-osk.sh\""
  echo "  bash \"$PROJECT_DIR/scripts/test-osk.sh\""
  echo ""
  if command -v yay >/dev/null 2>&1; then
    echo "Installeer handmatig: yay -S wvkbd-deskintl"
  else
    echo "Installeer yay, daarna: yay -S wvkbd-deskintl"
    echo "Of alleen onboard: sudo pacman -S onboard"
  fi
  echo "Diagnose: bash \"$PROJECT_DIR/scripts/diagnose-convertible.sh\""
  echo "Log bij klik: ~/.cache/big-sur/osk.log"
}

spotify_available() {
  command -v spotify-launcher >/dev/null 2>&1 && return 0
  command -v spotify >/dev/null 2>&1 && return 0
  [ -x /usr/bin/spotify ] && return 0
  if command -v flatpak >/dev/null 2>&1 && flatpak info com.spotify.Client >/dev/null 2>&1; then
    return 0
  fi
  if command -v pacman >/dev/null 2>&1; then
    pacman -Q spotify >/dev/null 2>&1 && return 0
    pacman -Q spotify-launcher >/dev/null 2>&1 && return 0
  fi
  return 1
}

cursor_available() {
  command -v cursor >/dev/null 2>&1 && return 0
  command -v Cursor >/dev/null 2>&1 && return 0
  [ -x /usr/bin/cursor ] && return 0
  [ -x "$HOME/.local/bin/cursor" ] && return 0
  local pattern path
  shopt -s nullglob
  for pattern in \
    "$HOME/Applications/cursor"*.AppImage \
    "$HOME/Applications/Cursor"*.AppImage \
    "$HOME/Downloads/cursor"*.AppImage \
    "$HOME/Downloads/Cursor"*.AppImage; do
    for path in $pattern; do
      [ -f "$path" ] && return 0
    done
  done
  shopt -u nullglob
  if command -v flatpak >/dev/null 2>&1; then
    flatpak info com.todesktop.230313mzl4w4u92 >/dev/null 2>&1 && return 0
    flatpak list --app 2>/dev/null | grep -q '^com\.todesktop\.' && return 0
  fi
  if command -v pacman >/dev/null 2>&1; then
    pacman -Q cursor-bin >/dev/null 2>&1 && return 0
    pacman -Q cursor-appimage >/dev/null 2>&1 && return 0
  fi
  return 1
}

install_cursor_optional() {
  if is_windows_shell || ! is_linux; then
    return 0
  fi

  if cursor_available; then
    local hint=""
    if command -v cursor >/dev/null 2>&1; then
      hint="$(command -v cursor)"
    elif command -v Cursor >/dev/null 2>&1; then
      hint="$(command -v Cursor)"
    elif [ -x /usr/bin/cursor ]; then
      hint="/usr/bin/cursor"
    elif [ -x "$HOME/.local/bin/cursor" ]; then
      hint="$HOME/.local/bin/cursor"
    else
      hint="AppImage of Flatpak (zie launch-cursor.sh)"
    fi
    echo "Cursor IDE: client gevonden ($hint)."
    return 0
  fi

  local yay_flags=(--needed)
  if [ "$FORCE" = true ]; then
    yay_flags+=(--noconfirm)
  fi

  if command -v yay >/dev/null 2>&1; then
    echo ""
    echo "=== Cursor IDE (AUR via yay) ==="
    echo "Cursor staat niet in officiële Arch-repos — probeer cursor-bin..."
    if yay -S "${yay_flags[@]}" cursor-bin; then
      if cursor_available; then
        echo "Cursor IDE: cursor-bin geïnstalleerd."
        return 0
      fi
    else
      echo "cursor-bin mislukt — probeer cursor-appimage..."
      if yay -S "${yay_flags[@]}" cursor-appimage; then
        if cursor_available; then
          echo "Cursor IDE: cursor-appimage geïnstalleerd."
          return 0
        fi
      fi
    fi
  elif command -v paru >/dev/null 2>&1; then
    echo ""
    echo "=== Cursor IDE (AUR via paru) ==="
    local paru_flags=(--needed)
    [ "$FORCE" = true ] && paru_flags+=(--noconfirm)
    if paru -S "${paru_flags[@]}" cursor-bin || paru -S "${paru_flags[@]}" cursor-appimage; then
      if cursor_available; then
        echo "Cursor IDE: geïnstalleerd via paru."
        return 0
      fi
    fi
  fi

  report_cursor_status
}

report_cursor_status() {
  if is_windows_shell || ! is_linux; then
    return 0
  fi

  if cursor_available; then
    return 0
  fi

  echo ""
  echo "=== Cursor IDE ==="
  echo "Cursor staat niet in Arch extra — alleen AUR (cursor-bin / cursor-appimage) of AppImage."
  echo "Met yay: yay -S cursor-bin   (of: yay -S cursor-appimage)"
  echo "Met paru: paru -S cursor-bin"
  echo "AppImage: download van https://cursor.com → ~/Applications/Cursor-*.AppImage (chmod +x)"
  echo "Waybar 󰏘 en Super+Shift+U: bash \"$PROJECT_DIR/scripts/launch-cursor.sh\""
  echo "Log bij klik: ~/.cache/big-sur/cursor.log"
  echo "Optioneel auto-install: ./install.sh -y   (met yay/paru)"
}

etcher_pacman_package_name() {
  if ! command -v pacman >/dev/null 2>&1; then
    return 1
  fi
  local pkg
  for pkg in etcher-bin balena-etcher-bin balena-etcher etcher; do
    if pacman -Si "$pkg" >/dev/null 2>&1; then
      echo "$pkg"
      return 0
    fi
  done
  return 1
}

etcher_available() {
  command -v balena-etcher >/dev/null 2>&1 && return 0
  command -v etcher >/dev/null 2>&1 && return 0
  [ -x /usr/bin/balena-etcher ] && return 0
  [ -x /usr/bin/etcher ] && return 0
  [ -x /opt/balena-etcher/etcher ] && return 0
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
      [ -f "$path" ] && return 0
    done
  done
  shopt -u nullglob
  if command -v flatpak >/dev/null 2>&1; then
    flatpak info io.balena.etcher >/dev/null 2>&1 && return 0
    flatpak list --app 2>/dev/null | grep -qi etcher && return 0
  fi
  if command -v pacman >/dev/null 2>&1; then
    pacman -Q etcher-bin >/dev/null 2>&1 && return 0
    pacman -Q balena-etcher >/dev/null 2>&1 && return 0
    pacman -Q balena-etcher-bin >/dev/null 2>&1 && return 0
  fi
  return 1
}

install_etcher_optional() {
  if is_windows_shell || ! is_linux; then
    return 0
  fi

  if etcher_available; then
    local hint=""
    if command -v balena-etcher >/dev/null 2>&1; then
      hint="$(command -v balena-etcher)"
    elif command -v etcher >/dev/null 2>&1; then
      hint="$(command -v etcher)"
    elif [ -x /opt/balena-etcher/etcher ]; then
      hint="/opt/balena-etcher/etcher"
    else
      hint="AppImage of Flatpak (zie launch-etcher.sh)"
    fi
    echo "Balena Etcher: client gevonden ($hint)."
    return 0
  fi

  if etcher_pacman_package="$(etcher_pacman_package_name 2>/dev/null || true)" && [ -n "$etcher_pacman_package" ]; then
    echo "Balena Etcher: $etcher_pacman_package hoort via pacman geïnstalleerd te zijn."
    report_etcher_status
    return 0
  fi

  local yay_flags=(--needed)
  if [ "$FORCE" = true ]; then
    yay_flags+=(--noconfirm)
  fi

  if command -v yay >/dev/null 2>&1; then
    echo ""
    echo "=== Balena Etcher (AUR via yay) ==="
    echo "Etcher staat niet in officiële Arch-repos — probeer etcher-bin..."
    if yay -S "${yay_flags[@]}" etcher-bin; then
      if etcher_available; then
        echo "Balena Etcher: etcher-bin geïnstalleerd."
        return 0
      fi
    else
      echo "etcher-bin mislukt — probeer balena-etcher..."
      if yay -S "${yay_flags[@]}" balena-etcher; then
        if etcher_available; then
          echo "Balena Etcher: balena-etcher geïnstalleerd."
          return 0
        fi
      fi
    fi
  elif command -v paru >/dev/null 2>&1; then
    echo ""
    echo "=== Balena Etcher (AUR via paru) ==="
    local paru_flags=(--needed)
    [ "$FORCE" = true ] && paru_flags+=(--noconfirm)
    if paru -S "${paru_flags[@]}" etcher-bin || paru -S "${paru_flags[@]}" balena-etcher; then
      if etcher_available; then
        echo "Balena Etcher: geïnstalleerd via paru."
        return 0
      fi
    fi
  fi

  report_etcher_status
}

report_etcher_status() {
  if is_windows_shell || ! is_linux; then
    return 0
  fi

  if etcher_available; then
    return 0
  fi

  echo ""
  echo "=== Balena Etcher ==="
  echo "Etcher staat niet in Arch extra — alleen AUR (etcher-bin / balena-etcher) of AppImage."
  echo "Met yay: yay -S etcher-bin   (of: yay -S balena-etcher)"
  echo "Met paru: paru -S etcher-bin"
  echo "AppImage: download van https://etcher.balena.io → ~/Applications/balena-etcher-*.AppImage (chmod +x)"
  echo "Waybar 󰋊 en Super+Shift+H: bash \"$PROJECT_DIR/scripts/launch-etcher.sh\""
  echo "Log bij klik: ~/.cache/big-sur/etcher.log"
  echo "Optioneel auto-install: ./install.sh -y   (met yay/paru)"
}

report_spotify_status() {
  if is_windows_shell || ! is_linux; then
    return 0
  fi

  if spotify_available; then
    local hint=""
    if command -v spotify-launcher >/dev/null 2>&1; then
      hint="$(command -v spotify-launcher)"
    elif command -v spotify >/dev/null 2>&1; then
      hint="$(command -v spotify)"
    elif [ -x /usr/bin/spotify ]; then
      hint="/usr/bin/spotify"
    elif command -v flatpak >/dev/null 2>&1 && flatpak info com.spotify.Client >/dev/null 2>&1; then
      hint="flatpak com.spotify.Client"
    else
      hint="pacman-pakket (binary zoeken in PATH)"
    fi
    echo "Spotify: client gevonden ($hint)."
    return 0
  fi

  echo ""
  echo "=== Spotify ==="
  echo "spotify-launcher hoort via pacman geïnstalleerd te zijn (install.sh ARCH_PACKAGES)."
  echo "Handmatig: sudo pacman -S --needed spotify-launcher"
  echo "Waybar 󰓇 en Super+Shift+S: bash \"$PROJECT_DIR/scripts/launch-spotify.sh\""
  echo "Test: bash \"$PROJECT_DIR/scripts/test-spotify.sh\""
  echo "Log bij klik: ~/.cache/big-sur/spotify.log"
  echo "Alternatief: flatpak install flathub com.spotify.Client"
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

enable_bluetooth_services() {
  local script="$PROJECT_DIR/scripts/enable-bluetooth.sh"

  if is_windows_shell; then
    echo "Bluetooth: overgeslagen (Windows/Git Bash)."
    echo "  Op Linux: bash \"$script\""
    return 0
  fi

  if ! is_linux; then
    echo "Bluetooth: overgeslagen (geen Linux)."
    return 0
  fi

  if [ ! -f "$script" ]; then
    echo "Bluetooth: $script ontbreekt; overgeslagen."
    return 0
  fi

  chmod +x "$script" 2>/dev/null || true
  bash "$script" -y
}

setup_shell_profile() {
  local script="$CONFIG_DIR/big-sur/scripts/setup-bash-profile.sh"

  if is_windows_shell; then
    echo "Shell-profiel: overgeslagen (Windows/Git Bash)."
    echo "  Op Linux na install: bash \"$script\" -y"
    return 0
  fi

  if ! is_linux; then
    echo "Shell-profiel: overgeslagen (geen Linux)."
    return 0
  fi

  if [ ! -f "$script" ]; then
    echo "Shell-profiel: $script ontbreekt; overgeslagen."
    return 0
  fi

  bash "$script" -y
}

verify_hyprland_session_desktop() {
  local desktop="/usr/share/wayland-sessions/hyprland.desktop"

  if ! is_linux; then
    return 0
  fi

  if [ -f "$desktop" ]; then
    echo "Hyprland-sessie: $desktop"
  elif command -v Hyprland >/dev/null 2>&1 || command -v hyprland >/dev/null 2>&1; then
    echo "WAARSCHUWING: $desktop ontbreekt — herinstalleer het hyprland-pakket."
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
  bluez-utils
  blueman
  upower
  dolphin
  firefox
  code
  ttf-jetbrains-mono-nerd
  inter-font
  onboard
  spotify-launcher
  wdisplays
  btop
  git
  base-devel
  flatpak
  gnome-software
  vlc
  libreoffice-fresh
  keepassxc
  thunderbird
  gparted
  gnome-disk-utility
  wireshark-qt
  nmap
  remmina
  steam
  mangohud
  lutris
  prismlauncher
  docker
  docker-compose
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
install_osk_optional
install_cursor_optional
install_etcher_optional
report_spotify_status
enable_audio_services
enable_network_services
enable_bluetooth_services
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

setup_shell_profile

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
echo "Hyprland na login (tty1):"
echo "  $CONFIG_DIR/big-sur/scripts/setup-bash-profile.sh   # als autostart ontbreekt"
echo "  Log uit en opnieuw in op tty1, of: reboot"
echo ""
echo "WiFi / NetworkManager:"
echo "  $CONFIG_DIR/big-sur/scripts/enable-network.sh"
echo ""
echo "Bluetooth / BlueZ:"
echo "  $CONFIG_DIR/big-sur/scripts/enable-bluetooth.sh"
echo ""
echo "Instellingenmenu (rofi; geen gnome-control-center vereist):"
echo "  Super+, of Waybar 󰒓 → $CONFIG_DIR/big-sur/scripts/settings-menu.sh"
echo "  Apps-submenu: Super+, → Apps, of $CONFIG_DIR/big-sur/scripts/launch-apps-menu.sh"
echo "  Beeldscherm: wdisplays (pacman extra) — $CONFIG_DIR/big-sur/scripts/open-display-settings.sh"
echo ""
echo "Vouw-laptop (schermtoetsenbord):"
echo "  bash \"$CONFIG_DIR/big-sur/scripts/diagnose-convertible.sh\""
