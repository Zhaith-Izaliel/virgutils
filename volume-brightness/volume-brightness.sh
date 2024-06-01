#!/usr/bin/env bash
# Volume-Brightness: Update volume or brightness while showing a nice
# notification
# Copyright (c) 2023 Virgil Ribeyre <https://gitlab.com/Zhaith-Izaliel>
# Licensed under an MIT License

VERSION="1.15.0"

#######################################
# Show the usage
# Globals:
#   VERSION
# Arguments:
#   None
# Outputs:
#   Exits with code 0
#######################################
usage() {
  echo "
Usage: volume-brightness [COMMANDS...]
Volume-Brightness, update volume or brightness while showing a nice notification

Version $VERSION

Author: Ribeyre Virgil.
Licensed: MIT.
----------
COMMANDS:
  -h, --help                                Show this message
      --version                             Print version information
  -v, --volume     [MAX] [ID] [VOL]%[+/-]   Set volume of [ID] up until [MAX] with [VOL] (see wpctl --help);
  -b, --brightness [VALUE]                  Set brightness with [value] (see(brightnessctl(1)));
"
  exit 0
}


#######################################
# Show the version
# Arguments:
#   None
# Globals:
#   VERSION
#######################################
version() {
  echo "$VERSION"
  exit 0
}


#######################################
# Set the brightness of the screen and show a progress bar notification
# Arguments:
#   value - (any) Value to set the brightness to (see brightnessctl(1))
#######################################
set_brightness() {
  brightnessctl set "$1"
  local max="$(brightnessctl max)"
  local current="$(brightnessctl get)"
  local percent="$((100*$current/$max))"

  dunstify -h "int:value:${percent}" "Brightness"
}

#######################################
# Set the volume of the given sink and show a progress bar notification
# Arguments:
#   limit - (float) to set the volume limit of the given sink
#   sink  - (string) the volume sink (see pipewire(1))
#   value - ([VOL]%[+/-]) the percentage to change the volume with
#######################################
set_volume() {
  wpctl set-volume -l $1 $2 $3
  local max="$(echo "scale=1; $1*100" | bc | sed 's/\..*$//')"
  local current_float="$(wpctl get-volume $2 | awk -F ' ' '{print $2}')"
  local current="$(echo "scale=1; $current_float*100" | bc | sed 's/\..*$//')"
  local percent="$((100*$current/$max))"

  if (($current == 100)); then
    dunstify -u low -h "int:value:${percent}" "Volume"
    return $?
  elif (($current > 100)); then
    dunstify -u critical -h "int:value:${percent}" "Volume"
    return $?
  fi

  dunstify -h "int:value:${percent}" "Volume"
}


#######################################
# Main entry point of the script
# Arguments:
#   * - (any[]) The arguments of the script
#######################################
main() {
  case "$1" in
    "-h")
      usage
      ;;

    "--help")
      usage
      ;;

    "--version")
      version
      ;;

    "-v")
      set_volume $2 $3 $4
      ;;

    "--volume")
      set_volume $2 $3 $4
      ;;

    "-b")
      set_brightness $2
      ;;

    "--brightness")
      set_brightness $2
      ;;

  esac
}

main $*

