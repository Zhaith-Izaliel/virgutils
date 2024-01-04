#!/usr/bin/env bash

VERSION="1.0.0"

# Print colors
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# Globals
COUNT=0
HISTORY_SIZE=20
OUTPUT='{
  "text": 0,
  "alt": "",
  "tooltip": "",
  "class": "",
  "percentage": 0
}'


pretty-print() {
  echo -e "${BLUE}[$(date +'%Y-%m-%d|%H:%M:%S%z')]:${NC} $*"
}

err() {
  pretty-print "${RED}$*${NC}" >&2
}

function usage() {
  echo "
Usage: dunstbar [SETTINGS] [ARGUMENTS]

An utility to get notifications info from Dunst, in order to pass them to Waybar.

Version $VERSION

Author: Virgil Ribeyre.
Licensed: GNU GPLv3 Licence.

ARGUMENTS
  -h, --help                      Show this message.

  -v, --version                   Show version number.

  -p, --toggle-pause              Toggle pausing dunst.

  -c, --clear-history             Clear notification history.

  -j, --info                      Get dunst info in JSON format for Waybar.

SETTINGS
      --history=size              Defines the max number of messages reported in the history. Default to $HISTORY_SIZE.
"
  exit 0
}

function get_info() {
  # TODO: Update the $OUTPUT variable depending on the values reported by
  # dunstctl:
  # - "text":
  #   - If Dunst is paused: `dunstctl count waiting`
  #   - Else: `dunstctl count history`
  # - "alt": unused
  # - "tooltip": Corresponds of every "message" key from the history, on the
  #   last ${HISTORY_SIZE}-th messages
  # - "class": `waiting` if `dunstctl is-paused` = true, empty otherwise
  # - percentage: unused
}

function main() {
  while getopts "hvp-:" ARGS; do
    case "${ARGS}" in
      -)
        case "${OPTARG}" in
          help)
            usage
            ;;
          version)
            echo "$VERSION"
            exit 0
            ;;

          toggle-pause)
            dunstctl set-paused toggle
            ;;
          clear-history)
            dunstctl history-clear
            ;;
          info)
            get_info
            ;;
          history=*)
              local val=${OPTARG#*=}
              HISTORY_SIZE=$val
            ;;
          *)
            if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
              err "Unknown option --${OPTARG}. Use -h or --help for a list of options."
            fi
            exit 1
            ;;
        esac
        ;;
      h)
        usage
        ;;
      v)
        echo "$VERSION"
        exit 0
        ;;
      p)
        dunstctl set-paused toggle
        ;;
      c)
        dunstctl history-clear
        ;;
      -i)
        get_info
        ;;
      *)
        err "Unknown option ${ARGS}. Use -h or --help for a list of options."
        exit 1
        ;;
    esac
  done
}

ENABLED=""
DISABLED=""

if [ $COUNT != 0 ]; then
  DISABLED="  $COUNT";
fi
if dunstctl is-paused | grep -q "false" ; then echo $ENABLED; else echo $DISABLED; fi

main $*

