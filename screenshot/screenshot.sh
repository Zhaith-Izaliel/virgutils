#!/usr/bin/env bash

SCREENSHOTS_FOLDER="$HOME/Pictures/Screenshots"

# Notify-send
ERROR_ICON="system-error"
SUMMARY="wlogout-blur"

# Print colors:
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

pretty-print() {
  echo -e "${BLUE}[$(date +'%Y-%m-%d|%H:%M:%S%z')]:${NC} $*"
}

err() {
  pretty-print "${RED}$*${NC}" >&2
  notify-send -u critical -t 5000 -i "$ERROR_ICON" "$SUMMARY" "$*"
}

run() {
  if [ ! -d "$SCREENSHOTS_FOLDER" ]; then
    mkdir -p "$SCREENSHOTS_FOLDER"
  fi

  local pid
  pid="$(pidof grim)"

  if [ "$pid" != "" ]; then
    err "There is already a Grimblast process running with PID $pid"
    exit 1
  fi
  grimblast --freeze --notify copysave "$1" "${SCREENSHOTS_FOLDER}/$(date +%F:%H:%M:%S).png"
}

run "$@"
