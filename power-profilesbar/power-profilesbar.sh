#!/usr/bin/env bash

VERSION="1.9.1"
OUTPUT='{
  "text": "",
  "alt": "",
  "tooltip": "",
  "class": ""
}'

# Print colors
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

pretty-print() {
  echo -e "${BLUE}[$(date +'%Y-%m-%d|%H:%M:%S%z')]:${NC} $*"
}

err() {
  pretty-print "${RED}$*${NC}" >&2
}

usage() {
  echo "
Usage: power-profilesbar [ARGUMENTS]

An utility to get power-profiles info from power-profiles-daemon, in order to pass them to Waybar.

Version $VERSION

Author: Virgil Ribeyre.
Licensed: GNU GPLv3 Licence.

ARGUMENTS
  -h, --help                      Show this message.

  -v, --version                   Show version number.

  -i, --info                      Get power-profiles info in JSON format for Waybar.
"
  exit 0
}

parse_info() {
  local profile=$(powerprofilesctl get)
  OUTPUT=$(echo $OUTPUT | jq ".text = \"${profile}\"
      | .alt = \"${profile}\"
      | .class = .alt
      | .tooltip = \"Current profile: ${profile}.\""
  )

  echo $OUTPUT | jq --unbuffered --compact-output "."
}

show_error() {
  echo $OUTPUT | jq --unbuffered --compact-output '.text = "ERROR" | .alt = "error" | .class = .alt | .tooltip = "An error has occured, please check the script."'
}

get_info() {
  parse_info
  local is_success=$?
  if [ "$is_success" != "0" ]; then
    show_error
  fi
}

main() {
  while getopts "hvi-:" ARGS; do
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

          info)
            get_info
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
      i)
        get_info
        ;;
      *)
        err "Unknown option ${ARGS}. Use -h or --help for a list of options."
        exit 1
        ;;
    esac
  done
}

main $*

