#!/usr/bin/env bash

VERSION="1.19.0"

# Print colors
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# Globals
HISTORY_SIZE=20
OUTPUT='{"text": "","alt": "","tooltip": "","class": ""}'

pretty-print() {
  echo -e "${BLUE}[$(date +'%Y-%m-%d|%H:%M:%S%z')]:${NC} $*"
}

err() {
  pretty-print "${RED}$*${NC}" >&2
}

usage() {
  echo "
Usage: dunstbar [SETTINGS] [ARGUMENTS]

An utility to get notifications info from Dunst, in order to pass them to Waybar.

Version $VERSION

Author: Virgil Ribeyre.
Licensed: GNU GPLv3 Licence.

ARGUMENTS
  -h, --help                      Show this message.

  -v, --version                   Show version number.

  -p, --toggle-pause              Toggle pausing dunst.

  -c, --clear-history             Clear notification history.

  -i, --info                      Get dunst info in JSON format for Waybar.

SETTINGS
      --history=size              Defines the max number of messages reported in the history. Default to $HISTORY_SIZE.
"
  exit 0
}

dunst_ts_to_unix() {
  local dunst_ts seconds_uptime ts_now
  # Convert DUNST_TIMESTAMP from ns to seconds
  dunst_ts=$(($1 / 1000 / 1000))
  # Get seconds since boot
  seconds_uptime=$(date +%s -d@"$(cut -d' ' -f1 /proc/uptime)")
  # Get seconds as UNIX timestamp
  ts_now=$(date +%s)
  # Print the diff of: NOW - (uptime - dunst-timestamp)
  printf %d $((ts_now - seconds_uptime + dunst_ts))
}

strip_quotes() {
  sed -e 's/^"//' -e 's/"$//' <<<"$1"
}

calculate_date_from_timestamps() {
  date +'%F %H:%M' -d @"$(dunst_ts_to_unix "$1")"
}

get_tooltip_history() {
  local history cleaned_history length end accumulator
  history=$(dunstctl history | jq "first(.data.[]) | .[0:${HISTORY_SIZE}]")

  cleaned_history=$(
    echo "$history" | jq '
    map(
      {
        body: .body.data,
        summary: ("<b>" + .summary.data + "</b>"),
        timestamp: .timestamp.data
      }
    )'
  )

  length=$(echo "$cleaned_history" | jq "length")
  if [ "$length" = "0" ]; then
    echo "🍂 No notifications in history yet."
    return
  fi

  end=$((length - 1))
  accumulator=""
  for i in $(seq 0 $end); do
    local timestamp summary body
    timestamp=$(echo "$cleaned_history" | jq "nth($i) | .timestamp")

    summary=$(echo "$cleaned_history" | jq "nth($i) | .summary")
    summary=$(strip_quotes "$summary")

    body=$(echo "$cleaned_history" | jq "nth($i) | .body")
    body=$(strip_quotes "$body")
    if [ "$i" != "0" ]; then
      accumulator="${accumulator}\n\n"
    fi

    if [ "$body" = "" ]; then
      accumulator="${accumulator}${summary}\n🕗<i>$(calculate_date_from_timestamps "$timestamp")</i>"
    else
      accumulator="${accumulator}${summary}\n🕗<i>$(calculate_date_from_timestamps "$timestamp")</i>\n${body}"
    fi
  done

  echo "$accumulator"
}

parse_info() {
  if dunstctl is-paused | grep -q "false"; then
    local count_history count_displayed count
    count_history=$(dunstctl count history)
    count_displayed=$(dunstctl count displayed)
    count=$((count_history + count_displayed))
    OUTPUT=$(
      echo "$OUTPUT" | jq \
        ".text = $count | .alt = \"not-paused\" | .class = .alt"
    )
  else
    OUTPUT=$(
      echo "$OUTPUT" | jq \
        ".text = $(dunstctl count waiting) | .alt = \"paused\" | .class = .alt"
    )
  fi
  local tooltip
  tooltip=$(get_tooltip_history)

  echo "$OUTPUT" | jq --unbuffered --compact-output ".tooltip = \"$tooltip\""
}

show_error() {
  echo "$OUTPUT" | jq --unbuffered --compact-output '.text = "ERROR" | .alt = "error" | .class = .alt | .tooltip = "An error has occurred, please check the script."'
}

get_info() {
  parse_info
  local is_success=$?
  if [ "$is_success" != "0" ]; then
    show_error
  fi
}

main() {
  local optspec="hvpci-:"
  while getopts "$optspec" ARGS; do
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

      toggle-pause)
        dunstctl set-paused toggle
        ;;
      clear-history)
        dunstctl history-clear
        ;;
      info)
        get_info
        ;;
      history=*)
        local val=${OPTARG#*=}
        HISTORY_SIZE=$val
        ;;
      *)
        if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
          err "Unknown option --${OPTARG}. Use -h or --help for a list of options."
        fi
        exit 1
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
    p)
      dunstctl set-paused toggle
      ;;
    c)
      dunstctl history-clear
      ;;
    i)
      get_info
      ;;
    *)
      err "Unknown option ${ARGS}. Use -h or --help for a list of options."
      exit 1
      ;;
    esac
  done
}

main "$@"
