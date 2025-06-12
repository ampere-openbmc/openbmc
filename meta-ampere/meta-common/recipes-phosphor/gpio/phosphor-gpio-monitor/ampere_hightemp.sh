#!/bin/bash

cpu="$1"
action="$2"
status_file="/tmp/cpu${cpu}_hightemp.status"
lock_file="/tmp/cpu${cpu}_hightemp.lock"
ampere_redfish="/usr/sbin/ampere_add_redfishevent.sh"

cleanup() {
  if [ -f "$lock_file" ]; then
    rm -f "$lock_file"
  fi
}

# Set trap to clean up on script exit or interruption
trap cleanup EXIT INT TERM

if [ ! -f "$lock_file" ]; then
  echo $$ > "$lock_file"
  if [ ! -f "$status_file" ]; then
    echo 0 >  "$status_file"
  fi
  # status = "0" means hightemp is already in deassert state
  # status = "1" means hightemp is already in assert state
  status=$(cat "${status_file}")

  if [ "$action" == "assert" ]; then
    if [ ! "$status" == "1" ]; then
      echo 1 > "$status_file"
      $ampere_redfish OpenBMC.0.1.AmpereWarning "CPU${cpu} HighTemp asserted"
    fi
  elif [ "$action" == "deassert" ]; then
    if [ ! "$status" == "0" ]; then
      echo 0 > "$status_file"
      $ampere_redfish OpenBMC.0.1.AmpereEvent "CPU${cpu} HighTemp deasserted"
    fi
  fi
fi
