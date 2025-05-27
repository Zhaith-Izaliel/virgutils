#!/usr/bin/env bash

VERSION="1.18.1"

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
Usage: nightlights [Hyprsunset ARGS]
Nightlights, a wrapper around Hyprsunset to run or kill Nightlights

Version $VERSION

Author: Ribeyre Virgil.
Licensed: MIT.
----------
WRAPPER COMMANDS

-h,  --help       Show this message and exit.

-v,  --version    Show the version and exit.

----------
"
  hyprsunset --help
  exit 0
}

version() {
  echo "
Wrapper version: $VERSION
"
  exit 0
}

run() {
  local pid
  pid="$(pidof hyprsunset)"

  if [ "$pid" != "" ]; then
    kill "$pid"
    exit $?
  fi

  hyprsunset "$@"
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
    run "$@"
    ;;
  esac
}

main "$@"
