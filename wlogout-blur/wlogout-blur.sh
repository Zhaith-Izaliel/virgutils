#!/usr/bin/env bash

VERSION="1.9.0"
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

-l, --layer       Use Hyprland the layer shell instead of a blurred screenshot (requires hyprctl) 

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

use_screenshot() {  
  grimblast save screen $WLOGOUT_BLUR_IMAGE_LOCATION
  convert -scale 5% -blur 0x2.5 -resize 2000% $WLOGOUT_BLUR_IMAGE_LOCATION $WLOGOUT_BLUR_IMAGE_LOCATION
  wlogout $*
}

use_layer_shell() {
  hyrpctl layers
  wlogout $*
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

    -l)
      use_layer_shell ${@:2}
    ;;

    --layer)
      use_layer_shell ${@:2}
    ;;

    *)
      use_screenshot $*
    ;;
  esac      
}

main $*

