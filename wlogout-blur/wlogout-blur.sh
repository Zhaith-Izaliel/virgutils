#!/usr/bin/env bash

VERSION="1.15.0"
WLOGOUT_BLUR_IMAGE_LOCATION="/tmp/wlogout-blur.png"

usage() {
  echo "
Usage: wlogout-blur [...]
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

    *)
      grimblast save screen $WLOGOUT_BLUR_IMAGE_LOCATION
      fastblur $WLOGOUT_BLUR_IMAGE_LOCATION $WLOGOUT_BLUR_IMAGE_LOCATION 25
      wlogout "$@"
    ;;
  esac      
}

main "$@"

