#!/usr/bin/env bash
# Power Management, a wrapper around shutdown with libnotify
# Copyright (c) 2022 Virgil Ribeyre <https://github.com/Zhaith-Izaliel>
# Licensed under an MIT License

VERSION="1.4.5"

# Icons
ICON="system-shutdown"
SUMMARY="Power Management"
OUTPUT_FILE="/tmp/power-management-output.txt"

#######################################
# Show the usage
# Globals:
#   VM_NAME
#   RESOLUTION
#   VERSION
# Arguments:
#   None
# Outputs:
#   Exits with code 0
#######################################
usage() {
  echo "
Usage: power-management [OPTIONS...] [TIME] [WALL...]
Power Management, a wrapper around shutdown with libnotify

Version $VERSION

Author: Ribeyre Virgil.
Licensed: MIT.
----------
"
  shutdown --help
  exit 0
}

dunsitfy-all() {
  if [ "$EUID" -ne 0 ]; then
    dunstify "$@"
    return
  fi

  local users=($(users))
  for user_name in "${users[@]}"; do
    local
    sudo -u "$user_name" \
      DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $user_name)/bus" \
      DISPLAY=":0" \
      dunstify "$@"
  done
}

#######################################
# Main function of the script
# Globals:
#   ICON
#   SUMMARY
#   OUTPUT_FILE
# Arguments:
#   *: every arguments passed to the script
# Outputs:
#   None
#######################################
main() {
  if [ "$1" = "--help" ]; then
    usage
  fi

  shutdown "$*" &> $OUTPUT_FILE
  local exit_code=$?

  if [ "$exit_code" = "0" ]; then
    if [ "$*" = "-c" ]; then
      echo "Shutdown cancelled." > $OUTPUT_FILE
    fi

    cat $OUTPUT_FILE
    dunsitfy-all -u 2 -t 6000 -i "$ICON" "$SUMMARY" "$(cat $OUTPUT_FILE)"
  fi
  rm $OUTPUT_FILE
  exit $exit_code
}

# Trap the exit of the program to ensure clean up of the lignering processes.
main $*

