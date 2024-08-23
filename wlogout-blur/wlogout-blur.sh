#!/usr/bin/env bash

VERSION="1.17.3"
WLOGOUT_BLUR_IMAGE_LOCATION="/tmp/wlogout-blur.png"
USE_BG="true"

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
}

usage() {
  echo "
Usage: wlogout-blur [wlogout-blur ARG] [wlogout ARGS]
Wlogout Blur, a wrapper around wlogout to create a blurred background

Version $VERSION

Author: Ribeyre Virgil.
Licensed: MIT.
----------
SETTINGS

WLOGOUT_BLUR_IMAGE_LOCATION   Set the temporary location of the image used as background image.
                              Default: $WLOGOUT_BLUR_IMAGE_LOCATION
----------
WRAPPER COMMANDS

-h,  --help       Show this message and exit.

-v,  --version    Show the version and exit.

     --no-bg      Do not use the blue background image. This option is used when you need wlogout with duplicate prevention while not needing the blurred background image trick. 

----------
"
  wlogout --help
  exit 0
}

version() {
  echo "
Wrapper version: $VERSION
----------
Wlogout version: $(wlogout --version)
"
  exit 0
}

run() {
  local pid
  pid="$(pidof wlogout)"

  if [ "$pid" != "" ]; then
    err "There is already a Wlogout process running with PID $pid"
    exit 1
  fi

  if [ "$USE_BG" = "true" ]; then
    grimblast save screen $WLOGOUT_BLUR_IMAGE_LOCATION
    fastblur $WLOGOUT_BLUR_IMAGE_LOCATION $WLOGOUT_BLUR_IMAGE_LOCATION 25
  fi

  wlogout "$@"
}

main() {

  case "$1" in
  -h)
    usage
    ;;

  --help)
    usage
    ;;

  -v)
    version
    ;;

  --version)
    version
    ;;

  --no-bg)
    USE_BG="false"
    run "${@:2}"
    ;;

  *)
    run "$@"
    ;;
  esac
}

main "$@"
