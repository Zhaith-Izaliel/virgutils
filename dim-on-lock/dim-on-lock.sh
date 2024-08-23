#!/usr/bin/env bash
# Dim On Lock, a wrapper around brightnessctl to dim before lock
# Copyright (c) 2022 Virgil Ribeyre <https://github.com/Zhaith-Izaliel>
# Licensed under an MIT License

VERSION="1.17.3"

IS_MIN="true"


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
      --no-min          \tAllow dimming outside of the default minimal value, thus setting the brightness of the screen to 0 is possible.

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
    "h")
      usage
      ;;

    "v")
      version
      ;;

    "-")
      case "${OPTARG}" in
        "help")
          usage
          ;;

        "no-min")
          IS_MIN="false"
          ;;


        "version")
          version
          ;;

        "dim")
          brightnessctl --save
          local val="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
      
          if [ "$IS_MIN" = "true" ]; then
            brightnessctl --min-value="5000" set "${val}%-"
          else
            brightnessctl set "${val}%-"
          fi
        ;;

        "undim")
          brightnessctl --restore
        ;;
        
        "*")
          if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
            echo "Unknown option --${OPTARG}" >&2
          fi
        ;;
      esac
      ;;
    "*")
      if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
        echo "Non-option argument: '-${OPTARG}'" >&2
      fi
    ;;
    esac
  done
}

main "$@"

