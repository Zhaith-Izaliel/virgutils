#!/usr/bin/env bash

bluetoothctl show | grep "Powered: yes" &> /dev/null
exit_code="$?"

if [ "$exit_code" = "0" ]; then
  bluetoothctl power off
else
  bluetoothctl power on
fi

