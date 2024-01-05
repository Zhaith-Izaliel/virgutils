#!/usr/bin/env bash
# Dim On Lock, a wrapper around brightnessctl to dim before lock
# Copyright (c) 2022 Virgil Ribeyre <https://github.com/Zhaith-Izaliel>
# Licensed under an MIT License

VERSION="1.4.4"
DIM_VALUE=""

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
  echo "
Usage: dim-on-lock [OPTIONS...] [dim/undim]
Dim On Lock, a wrapper around brightnessctl to dim before lock

Version $VERSION

Author: Ribeyre Virgil.
Licensed: MIT.
----------
OPTIONS:
  -h, --help    Show this message
  -v, -version  Print version information

COMMANDS:
  dim  [VALUE]  Dim screen by [VALUE]
  undim         Set brightness to previous state before dimming
"
  exit 0
}

version() {
  echo "$VERSION"
}

main() {
  case "$1" in
    "-h")
      usage
      ;;

    "--help")
      usage
      ;;

    "-v")
      version
      ;;

    "--version")
      version
      ;;

    "dim")
      brightnessctl --save
      brightnessctl --min-value="5000" set "${2}%-"
    ;;

    "undim")
      brightnessctl --restore
    ;;
  esac
}

main $*

