#!/usr/bin/env bash
TEMPDIR="/tmp/nix-npm-install/"
VERSION="1.10.1"
PACKAGE_NAME=""
PACKAGE_VERSION=""

usage() {
  echo "
Usage: nix-npm-install [PACKAGE] ([VERSION])
Install a npm package globaly as a Nix package.

Version $VERSION

Author: Ribeyre Virgil.
Licensed: MIT.

ARGUMENTS
  -h, --help                      Show this message.

  -v  --version                   Show version number.
"
  exit 0
}

version() {
  echo "$VERSION"
  exit 0
}

#######################################
# Print a formatted message with a date string at its begining
# Globals:
#   None
# Arguments:
#   String: message
# Outputs:
#   Writes message to stdout
#######################################
pretty-print() {
  echo "[$(date +'%Y-%m-%d|%H:%M:%S%z')]: $*"
}

#######################################
# Repport errors to stderr and print them
# Globals:
#   None
# Arguments:
#   String: error message
# Outputs:
#   Writes message to stdout and to stderr
#######################################
err() {
  pretty-print "$*" >&2
}

check-package() {
  if [ "$PACKAGE_NAME" = "" ]; then
    err "You didn't specify a package name. Aborting."
    exit 2
  fi
}

install-package() {
  check-package

  mkdir -p "$TEMPDIR/$PACKAGE_NAME"
  pushd "$TEMPDIR/$PACKAGE_NAME" || exit 1

  local package=""
  if [ "$PACKAGE_VERSION" != "" ]; then
    package="[{\"$PACKAGE_NAME\": \"$PACKAGE_VERSION\"}]"
  else
    package="[\"$PACKAGE_NAME\"]"
  fi

  node2nix -18 --input <(echo "$package")
  nix-env -f default.nix -iA "$PACKAGE_NAME"

  popd || exit 1
}

cleanup() {
  if [ -d "$TEMPDIR" ]; then
    rm -r $TEMPDIR
  fi
}

trap cleanup EXIT

main() {
  case $1 in
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
    PACKAGE_NAME=$1
    ;;
  esac
  PACKAGE_VERSION=$2
  install-package
}

main "$*"

