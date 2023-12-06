#!/usr/bin/env bash

SCREENSHOTS_FOLDER="$HOME/Pictures/Screenshots"
GRIMBLAST_PID_FILE="/tmp/grimblast.pid"

if [ -f "$GRIMBLAST_PID_FILE" ]; then
  exit 0
fi

if [ ! -d "$SCREENSHOTS_FOLDER" ]; then
  mkdir -p "$SCREENSHOTS_FOLDER"
fi

grimblast --freeze --notify copysave "$1" "${SCREENSHOTS_FOLDER}$(date +%F:%H:%M:%S).png" &
pid=$!

echo "$pid" > "$GRIMBLAST_PID_FILE"
wait $pid

rm "$GRIMBLAST_PID_FILE"

