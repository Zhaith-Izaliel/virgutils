#!/usr/bin/env bash
VERSION="1.6.0"
PRIMARY_DISPLAY="eDP-1-1"
SECONDARY_DISPLAY="HDMI-0"
PRIMARY_RESOLUTION="1920x1080"
SECONDARY_RESOLUTION="1920x1080"

function usage() {
  echo "
Usage: double-display [SETTINGS] ... [ARGUMENTS]
Change displays setting when with 2 monitors depending on the input using xrandr

Version $VERSION

Author: Ribeyre Virgil.
Licensed: GNU GPLv3 Licence.

ARGUMENTS
  -h, --help                      Show this message.

  -v  --version                   Show version number.

      --duplicate                 Duplicate outputs.

      --left-of                   Put second screen on the left of the first.

      --right-of                  Put second screen on the right of the first.

      --below                     Put second screen below the first.

      --above                     Put second screen above the first.

      --primary-off               Turns off primary screen.

      --secondary-off             Turns off secondary screen.

SETTINGS

      --primary-display=*         Define the first screen for xrandr. Default value: $PRIMARY_DISPLAY

      --secondary-display=*       Define the second screen for xrandr. Default value: $SECONDARY_DISPLAY

      --primary-resolution=*      Define primary display resolution. Default value: $PRIMARY_RESOLUTION

      --secondary-resolution=*    Define primary display resolution. Default value: $SECONDARY_RESOLUTION
"
  exit 2
}

err() {
  echo "[$(date +'%Y-%m-%d|%H:%M:%S%z')]: $*" >&2
}

function check-if-double-display() {
  number_of_displays=$(xrandr | grep '\bconnected\b' | wc -l)

  if [ "$number_of_displays" != "2" ]; then
    err "There isn't exactly 2 screens connected. Aborting."
    exit 2
  fi
}

function change-display() {
  xrandr --output "$PRIMARY_DISPLAY" --primary --mode "$PRIMARY_RESOLUTION" --output "$SECONDARY_DISPLAY" --mode "$SECONDARY_RESOLUTION" "$1" "$PRIMARY_DISPLAY"
}

function turn-off-display() {
  xrandr --output "$1" --off --output "$2" --primary --mode "$3"
}

function main() {
  # FIXME: update the script to use wlr-randr
  echo "This script is not working as is, let me fix it first"
  exit 1
  check-if-double-display
  while getopts "hv-:" ARGS; do
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

      primary-display=*)
        local val=${OPTARG#*=}
        export PRIMARY_DISPLAY="$val"
        ;;

      secondary-display=*)
        local val=${OPTARG#*=}
        export SECONDARY_DISPLAY="$val"
        ;;

      primary-resolution=*)
        local val=${OPTARG#*=}
        export PRIMARY_RESOLUTION="$val"
        ;;

      secondary-resolution=*)
        local val=${OPTARG#*=}
        export SECONDARY_RESOLUTION="$val"
        ;;

      duplicate)
        change-display --same-as
        ;;

      right-of)
        change-display --right-of
        ;;

      left-of)
        change-display --left-of
        ;;

      below)
        change-display --below
        ;;

      above)
        change-display --above
        ;;

      primary-off)
        turn-off-display "$PRIMARY_DISPLAY" "$SECONDARY_DISPLAY" "$SECONDARY_RESOLUTION"
        ;;

      secondary-off)
        turn-off-display "$SECONDARY_DISPLAY" "$PRIMARY_DISPLAY" "$PRIMARY_RESOLUTION"
        ;;

      *)
        if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
          err "Unknown option --${OPTARG}. Use -h or --help for a list of options."
        fi
        exit 2
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
    *)
      exit 2
      ;;
    esac
  done
}

main "$*"

