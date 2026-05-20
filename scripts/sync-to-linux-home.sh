#!/usr/bin/env bash
# Copy theme configs from a source .config tree (e.g. Windows Git Bash install)
# into the current Linux user's ~/.config for Hyprland.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

SOURCE_CONFIG=""
TARGET_CONFIG=""

usage() {
  cat <<'EOF'
Usage: ./scripts/sync-to-linux-home.sh [SOURCE_CONFIG_DIR]

SOURCE_CONFIG_DIR  Directory that contains hypr/, waybar/, etc.
                   (default: first existing path among common Windows mounts)

TARGET is always: $XDG_CONFIG_HOME or $HOME/.config on this machine.

Run from your Linux Hyprland session after installing from Windows/Git Bash.

Examples:
  ./scripts/sync-to-linux-home.sh
  ./scripts/sync-to-linux-home.sh /mnt/c/Users/Joey/.config
EOF
}

resolve_target_config() {
  if [ -n "${XDG_CONFIG_HOME:-}" ]; then
    TARGET_CONFIG="$XDG_CONFIG_HOME"
  else
    TARGET_CONFIG="$HOME/.config"
  fi
  mkdir -p "$TARGET_CONFIG"
  TARGET_CONFIG="$(cd "$TARGET_CONFIG" && pwd)"
}

guess_windows_config() {
  local user="${USER:-${LOGNAME:-}}"
  local candidates=()
  if [ -n "$user" ]; then
    candidates+=("/mnt/c/Users/$user/.config")
  fi
  candidates+=("/mnt/c/Users/"*"/.config")
  local c
  for c in "${candidates[@]}"; do
    if [ -d "$c/hypr" ] && [ -f "$c/hypr/hyprland.conf" ]; then
      echo "$c"
      return 0
    fi
  done
  return 1
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

if [ "$(uname -s 2>/dev/null || echo unknown)" != "Linux" ]; then
  echo "Dit script moet vanuit je Linux Hyprland-sessie draaien (niet Git Bash op Windows)." >&2
  exit 1
fi

resolve_target_config

if [ -n "${1:-}" ]; then
  SOURCE_CONFIG="$1"
else
  if ! SOURCE_CONFIG="$(guess_windows_config)"; then
    echo "Geen bron gevonden. Geef het pad naar je Windows .config map:" >&2
    echo "  ./scripts/sync-to-linux-home.sh /mnt/c/Users/<naam>/.config" >&2
    exit 1
  fi
fi

if [ ! -d "$SOURCE_CONFIG" ]; then
  echo "Bron bestaat niet: $SOURCE_CONFIG" >&2
  exit 1
fi

SOURCE_CONFIG="$(cd "$SOURCE_CONFIG" && pwd)"

echo "Bron:  $SOURCE_CONFIG"
echo "Doel:  $TARGET_CONFIG"
echo ""

for component in hypr waybar kitty rofi dunst; do
  if [ -d "$SOURCE_CONFIG/$component" ]; then
    mkdir -p "$TARGET_CONFIG/$component"
    cp -a "$SOURCE_CONFIG/$component/." "$TARGET_CONFIG/$component/"
    echo "  gekopieerd: $component/"
  fi
done

# Fallback: install fresh from project if hyprland.conf still missing
if [ ! -f "$TARGET_CONFIG/hypr/hyprland.conf" ] && [ -f "$PROJECT_DIR/install.sh" ]; then
  echo ""
  echo "Geen hyprland.conf in bron; voer project-install uit..."
  BIG_SUR_CONFIG_DIR="$TARGET_CONFIG" "$PROJECT_DIR/install.sh" -y
fi

echo ""
echo "Klaar. Configs staan in: $TARGET_CONFIG"
echo "  hyprctl reload"
echo "  pkill waybar; waybar &"
