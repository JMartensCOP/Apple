#!/usr/bin/env bash
# Cycle primary display rotation: 0° → 90° → 180° → 270° (Hyprland transform 0–3)
set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.cache}/big-sur"
STATE_FILE="$STATE_DIR/display-rotation"
mkdir -p "$STATE_DIR"

read_state() {
  if [ -f "$STATE_FILE" ]; then
    cat "$STATE_FILE"
  else
    echo "0"
  fi
}

write_state() {
  printf '%s\n' "$1" >"$STATE_FILE"
}

# Laptop panel eerst (eDP-*), anders eerste monitor uit hyprctl
detect_monitor() {
  local mon=""

  if command -v hyprctl >/dev/null 2>&1; then
    if command -v jq >/dev/null 2>&1; then
      mon="$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.name | test("^eDP")) | .name' | head -1)"
      if [ -z "$mon" ] || [ "$mon" = "null" ]; then
        mon="$(hyprctl monitors -j 2>/dev/null | jq -r '.[0].name // empty')"
      fi
    else
      mon="$(hyprctl monitors 2>/dev/null | awk '
        BEGIN { first = "" }
        /^Monitor / {
          n = $2
          sub(/\(.*/, "", n)
          if (n ~ /^eDP/) { print n; exit }
          if (first == "") first = n
        }
        END { if (first != "") print first }
      ')"
    fi
  fi

  if [ -z "$mon" ] && command -v wlr-randr >/dev/null 2>&1; then
    mon="$(wlr-randr 2>/dev/null | awk '/^[^ ]/ { if ($1 ~ /^eDP/) { print $1; exit } }')"
    if [ -z "$mon" ]; then
      mon="$(wlr-randr 2>/dev/null | awk '/^[^ ]/ { print $1; exit }')"
    fi
  fi

  if [ -z "$mon" ]; then
    echo "Geen monitor gevonden (hyprctl / wlr-randr)." >&2
    exit 1
  fi
  echo "$mon"
}

current_transform_hypr() {
  local mon="$1"
  if ! command -v hyprctl >/dev/null 2>&1; then
    return 1
  fi
  if command -v jq >/dev/null 2>&1; then
    hyprctl monitors -j 2>/dev/null | jq -r --arg m "$mon" '.[] | select(.name == $m) | .transform // 0'
    return 0
  fi
  hyprctl monitors 2>/dev/null | awk -v want="$mon" '
    /^Monitor / { cur = $2; sub(/\(.*/, "", cur) }
    cur == want && /transform:/ { print $2; exit }
  '
}

apply_hypr() {
  local mon="$1" transform="$2"
  # Hyprland 0.54+: hyprctl keyword monitor <naam>,transform,<0-7>
  hyprctl keyword "monitor ${mon},transform,${transform}"
}

# wlr-randr: normal | 90 | 180 | 270
apply_wlr() {
  local mon="$1" transform="$2"
  local mode="normal"
  case "$transform" in
    0) mode="normal" ;;
    1) mode="90" ;;
    2) mode="180" ;;
    3) mode="270" ;;
    *) mode="normal" ;;
  esac
  wlr-randr --output "$mon" --transform "$mode"
}

MONITOR="$(detect_monitor)"
CURRENT="$(read_state)"

# Sync met actuele Hyprland-transform indien beschikbaar
if ACTUAL="$(current_transform_hypr "$MONITOR" 2>/dev/null)" && [ -n "$ACTUAL" ]; then
  case "$ACTUAL" in
    0 | 1 | 2 | 3) CURRENT="$ACTUAL" ;;
  esac
fi

NEXT=$(( (CURRENT + 1) % 4 ))
LABELS=("0° (normaal)" "90°" "180°" "270°")

if command -v hyprctl >/dev/null 2>&1; then
  apply_hypr "$MONITOR" "$NEXT"
elif command -v wlr-randr >/dev/null 2>&1; then
  apply_wlr "$MONITOR" "$NEXT"
else
  echo "Installeer Hyprland of wlr-randr voor schermrotatie." >&2
  exit 1
fi

write_state "$NEXT"
notify-send "Schermrotatie" "${MONITOR}: ${LABELS[$NEXT]}" 2>/dev/null || true
