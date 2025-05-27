#!/usr/bin/env bash
# Dim On Lock, a wrapper around brightnessctl to dim before lock
# Copyright (c) 2022 Virgil Ribeyre <https://github.com/Zhaith-Izaliel>
# Licensed under an MIT License

VERSION="1.18.1"

MIN=""

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
  echo -e "
Usage: dim-on-lock [OPTIONS...] [dim/undim]
Dim On Lock, a wrapper around brightnessctl to dim before lock

Version $VERSION

Author: Ribeyre Virgil.
Licensed: MIT.
----------
OPTIONS:
  -h, --help            \tShow this message
  -v, --version         \tPrint version information

SETTINGS:
      --min=[MIN]       \tSets a minimum value of brightness when dimming. The brightness will never be lower than this value.

COMMANDS:
      --dim\t[VALUE] \tDim screen by [VALUE]
      --undim           \tSet brightness to previous state before dimming
"
  exit 0
}

version() {
  echo "$VERSION"
  exit 0
}

main() {
  local optspec=":hv-:"
  while getopts "$optspec" optchar; do
    case "${optchar}" in
    h)
      usage
      ;;

    v)
      version
      ;;

    -)
      case "${OPTARG}" in
      help)
        usage
        ;;

      min=*)
        local val
        val="${OPTARG#*=}"
        MIN="$val"
        ;;

      version)
        version
        ;;

      dim)
        brightnessctl --save
        local val
        val="${!OPTIND}"
        OPTIND=$((OPTIND + 1))

        echo "min: $MIN"

        if [ -n "$MIN" ]; then
          brightnessctl --min-value="$MIN" set "${val}%-"
        else
          brightnessctl set "${val}%-"
        fi
        ;;

      undim)
        brightnessctl --restore
        ;;

      *)
        if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
          echo "Unknown option --${OPTARG}" >&2
        fi
        ;;
      esac
      ;;
    *)
      if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
        echo "Non-option argument: '-${OPTARG}'" >&2
      fi
      ;;
    esac
  done
}

main "$@"
