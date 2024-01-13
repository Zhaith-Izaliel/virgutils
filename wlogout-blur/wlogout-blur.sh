#!/usr/bin/env bash

VERSION="1.6.0"
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
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    usage
  fi

  if [ "$1" = "--version" ] || [ "$1" = "-v" ]; then
    version
  fi

  grimblast save screen $WLOGOUT_BLUR_IMAGE_LOCATION
  convert -scale 5% -blur 0x2.5 -resize 2000% $WLOGOUT_BLUR_IMAGE_LOCATION $WLOGOUT_BLUR_IMAGE_LOCATION
  wlogout $*
}

main $*

