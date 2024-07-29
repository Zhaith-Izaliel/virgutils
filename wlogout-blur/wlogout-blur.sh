#!/usr/bin/env bash

VERSION="1.17.1"
WLOGOUT_BLUR_IMAGE_LOCATION="/tmp/wlogout-blur.png"
WLOGOUT_PID_FILE="/tmp/wlogout-blur.pid"

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
  wlogout "$@" &
  local pid=$!

  echo "$pid" >"$WLOGOUT_PID_FILE"
  wait $pid
}

main() {
  if [ -f "$WLOGOUT_PID_FILE" ]; then
    exit 0
  fi
  trap 'rm -f $WLOGOUT_PID_FILE' EXIT

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
    run "${@:2}"
    ;;

  *)
    grimblast save screen $WLOGOUT_BLUR_IMAGE_LOCATION
    fastblur $WLOGOUT_BLUR_IMAGE_LOCATION $WLOGOUT_BLUR_IMAGE_LOCATION 25
    run "$@"
    ;;
  esac
}

main "$@"
