#!/bin/bash

# This script is used to turn on the Host after flashing.
# It has to wait for BMC's state enter to "Ready" status
# due to current BMC's state is "UpdateInProgress", therefore
# we can not request to turn on the Host immediately.

time_out=30

if [ "$#" -gt 0 ]
then
    time_out=$1
fi

for i in $(seq 1 "$time_out")
do
    bmc_state=$(busctl get-property xyz.openbmc_project.State.BMC \
                /xyz/openbmc_project/state/bmc0 xyz.openbmc_project.State.BMC \
                CurrentBMCState | cut -d " " -f 2)

    if [[ "${bmc_state}" == *".Ready"* ]]
    then
        temp_val=$(busctl set-property xyz.openbmc_project.State.Host0 \
                /xyz/openbmc_project/state/host0 xyz.openbmc_project.State.Host \
                RequestedHostTransition s xyz.openbmc_project.State.Host.Transition.On)
        break
    fi

    sleep 1s
done

exit
