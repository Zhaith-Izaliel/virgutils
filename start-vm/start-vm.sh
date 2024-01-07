#!/usr/bin/env bash
# Start VM, a script to run a GPU Passthrough VM with libvirt, Looking Glass and Scream
# Copyright (c) 2021 Virgil Ribeyre <https://github.com/Zhaith-Izaliel>
# Licensed under an MIT License

VERSION="1.5.0"

# Options
## The VM Name in Virsh
VM_NAME="Luminous-Rafflesia"
## Start Looking Glass in fullscreen
FULLSCREEN="no"
## Allow running Looking Glass
LOOKING_GLASS="true"
## Make the script verbose
VERBOSE="false"
## Tells if the VM failed to start
VM_FAILED="false"
## Looking Glass window resolution
RESOLUTION="1920x1080"
## Attemps before the Looking Glass client stop rebooting
ATTEMPTS=5
## Isolate CPUS during the hook script
ISOLATE_CPUS="false"

# Icons
DEFAULT_ICON="luminous-rafflesia"
NO_LG_ICON="luminous-rafflesia-nolg"
ERROR_ICON="luminous-rafflesia-error"

# Notify
SUMMARY="$VM_NAME (KVM)"
SHOWN_ICON="$DEFAULT_ICON"

# Print colors:
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

#######################################
# Show the usage
# Globals:
#   VM_NAME
#   RESOLUTION
#   VERSION
# Arguments:
#   None
# Outputs:
#   Exits with code 0
#######################################
usage() {
  echo "
Usage: start-vm [ARGUMENTS]
Start a Windows VM with GPU Passthrough with Virt-Manager. It also runs Looking Glass to stream the display to the current display and Scream to stream through the virtual network the audio. It is meant to be use in a graphical environment only.

Version $VERSION

Author: Ribeyre Virgil.
Licensed: MIT.

ARGUMENTS
  -h, --help                      Show this message.

      --version                   Show version number.

      --name=[NAME]               The VM name. Default $VM_NAME.

      --resolution=[RESOLUTION]   Looking Glass Client resolution. Default $RESOLUTION.

  -l  --no-lg                     Disable Looking Glass.

  -F  --fullscreen                Run Looking Glass as fullscreen. Doesn't work with -l or --no-lg

  -i  --isolate                   Tells virsh to run the hook script setting up CPU isolation.

  -v  --verbose                   Display more informations.
"
  exit 0
}

#######################################
# Print the script version
# Globals:
#   VERSION
# Arguments:
#   None
# Outputs:
#   Exits with code 0
#######################################
version() {
  echo "$VERSION"
  exit 0
}

#######################################
# Print a formatted message with a date string at its begining. Can read through stdin too
# Globals:
#   BLUE
#   NC
# Arguments:
#   String: message
# Outputs:
#   Writes message to stdout
#######################################
pretty-print() {
  echo -e "${BLUE}[$(date +'%Y-%m-%d|%H:%M:%S%z')]:${NC} $*"
}

#######################################
# Write the passed string to stdout if VERBOSE is true
# Globals:
#   VERBOSE
# Arguments:
#   String: message
# Outputs:
#   Writes message to stdout
#######################################
verbose() {
  if [ "$VERBOSE" = "true" ]; then
    pretty-print "$*"
  fi
}

#######################################
# Repport errors to stderr and print them while sending a notification to the DE
# Globals:
#   RED
#   NC
#   ERROR_ICON
#   SUMMARY
# Arguments:
#   String: error message
# Outputs:
#   Writes message to stdout and to stderr
#######################################
err() {
  pretty-print "${RED}$*${NC}" >&2
  notify-send -t 2000 -i "$ERROR_ICON" "$SUMMARY" "$*"
}

#######################################
# Wrap Looking Glass for convenience
# Globals:
#   FULLSCREEN
#   RESOLUTION
# Arguments:
#   None
# Outputs:
#   None
#######################################
looking-glass() {
  looking-glass-client -m 97 \
    -c DXGI \
    egl:scale=1 \
    egl:doubleBuffer=yes \
    win:size=$RESOLUTION \
    win:title=$VM_NAME \
    win:fullScreen=$FULLSCREEN
}

#######################################
# Wrap Virsh for convenience
# Globals:
#   None
# Arguments:
#   *: every arguments passed for virsh
# Outputs:
#   None
#######################################
virsh-wrapper() {
  ISOLATE_CPUS=$ISOLATE_CPUS virsh -c qemu:///system "$*"
}

#######################################
# Check if the VM is running
# Globals:
#   VM_NAME
# Arguments:
#   None
# Outputs:
#   Return 0 if the VM is running, 1 otherwise.
#######################################
is-vm-running() {
  virsh-wrapper list --state-running | grep $VM_NAME &>/dev/null
  return $?
}

#######################################
# Run Looking Glass and restart it everytime it crashes while the VM is still running,
# printing an error to both stderr and as a notification
# Globals:
#   LOOKING_GLASS
# Arguments:
#   None
# Outputs:
#   Return 1 if Looking Glass is not meant to be runned
#######################################
run-lg() {
  if [ "$LOOKING_GLASS" = "false" ]; then
    return 1
  fi

  verbose "Starting Looking-Glass..."
  sleep 10

  local restart_lg="true"
  local i=1
  while [ "$restart_lg" = "true" ] && [ "$ATTEMPTS" -gt $i ]; do
    looking-glass
    ((i += 1))
    is-vm-running
    local vm_running=$?
    if [ "$vm_running" = "0" ]; then
      err "Looking Glass stopped unexpectedly!"
      verbose "Restarting Looking Glass..."
    else
      local restart_lg="false"
    fi
  done
}

#######################################
# Run the VM
# Globals:
#   VM_NAME
#   VM_FAILED
# Arguments:
#   None
# Outputs:
#   Exit the script with a none 0 exit code if the VM can't be runned or fail.
#######################################
run-vm() {
  is-vm-running
  local is_running=$?

  if [ "$is_running" = "0" ]; then
    err "$VM_NAME is already running. If you need a linked service try running it as a standalone in a command line interface. Aborting."
    exit 1
  fi

  virsh-wrapper start --domain $VM_NAME

  local exit_code=$?
  if [ "$exit_code" != 0 ]; then
    VM_FAILED="true"
    err "$VM_NAME did not start correctly. Check its configuration. Aborting..."
    exit $exit_code
  fi

  verbose "$VM_NAME has started!"
}

#######################################
# Parse the options with getops
# Globals:
#   ARGS
#   OPTARG
#   OPTERR
#   VERBOSE
#   LOOKING_GLASS
#   SCREAM
#   RESOLUTION
#   FULLSCREEN
#   VM_NAME
# Arguments:
#   *: every arguments of the script passed for getopts
# Outputs:
#   Exit the script with a code 2 when any provided argument isn't recognized.
#######################################
parse-options() {
  while getopts "hvlFi-:" ARGS; do
    case "${ARGS}" in
    -)
      case "${OPTARG}" in
      help)
        usage
        ;;
      version)
        version
        ;;
      verbose)
        VERBOSE="true"
        ;;
      no-lg)
        SHOWN_ICON="$NO_LG_ICON"
        LOOKING_GLASS="false"
        ;;
      fullscreen)
        FULLSCREEN="yes"
        ;;
      isolate)
        ISOLATE_CPUS="true"
        ;;
      name=*)
        local val=${OPTARG#*=}
        VM_NAME=$val
        ;;
      resolution=*)
        local val=${OPTARG#*=}
        RESOLUTION=$val
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
      VERBOSE="true"
      ;;
    l)
      SHOWN_ICON="$NO_LG_ICON"
      LOOKING_GLASS="false"
      ;;
    F)
      FULLSCREEN="yes"
      ;;
    i)
      ISOLATE_CPUS="true"
      ;;
    *)
      exit 2
      ;;
    esac
  done
}

#######################################
# Shutdown the VM
# Globals:
#   VM_NAME
# Arguments:
#   None
# Outputs:
#   Return 0 if the vm is shutdown. Otherwise returns the exit code of the virsh shutdown command.
#######################################
shutdown-vm() {
  verbose "Shutting down your VM."
  is-vm-running
  local is_running=$?

  if [ "$is_running" != "0" ]; then
    verbose "$VM_NAME is already shut down!"
    return 0
  fi

  virsh-wrapper shutdown --domain "$VM_NAME"
  return $?
}

#######################################
# Clean up every lingering services and programs before exiting the script
# Globals:
#   VM_NAME
#   VM_FAILED
#   SHOWN_ICON
#   SUMMARY
# Arguments:
#   None
# Outputs:
#   Return 1 if the vm wasn't able to start at all. Otherwise 0.
#######################################
clean-up-exit() {
  if [ "$VM_FAILED" = "true" ]; then
    return 1
  fi

  shutdown-vm
  local exit_code=$?

  if [ "$exit_code" != "0" ]; then
    err "$VM_NAME didn't stop correctly. The VM $VM_NAME is still running within Virsh."
  else
    notify-send -t 2000 -i "$SHOWN_ICON" "$SUMMARY" "$(echo -e "<b>$VM_NAME</b> as been shutdown correctly.\n Bye!")"
  fi
}

#######################################
# Main function of the script
# Globals:
#   VM_NAME
#   SHOWN_ICON
#   SUMMARY
# Arguments:
#   *: every arguments passed to the script
# Outputs:
#   None
#######################################
main() {
  parse-options "$*"
  verbose "Starting the VM..."
  run-vm
  notify-send -t 2000 -i "$SHOWN_ICON" "$SUMMARY" "$(echo -e "<b>$VM_NAME</b> has started.\n<b>Looking Glass</b> will start shortly.")"
  run-lg
}

# Trap the exit of the program to ensure clean up of the lignering processes.
trap clean-up-exit EXIT
main "$*"

