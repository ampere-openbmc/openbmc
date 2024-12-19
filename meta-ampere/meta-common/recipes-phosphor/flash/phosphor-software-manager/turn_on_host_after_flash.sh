#!/bin/bash

# This script is used to turn on the Host after flashing.
# It has to wait until no more firmware being updated by checking
# xyz.openbmc_project.Software.ActivationBlocksTransition interface.

time_out=30

if [ "$#" -gt 0 ]
then
    time_out=$1
fi

function is_fw_updating()
{
    number_fw_is_updating=$(busctl call xyz.openbmc_project.ObjectMapper /xyz/openbmc_project/object_mapper \
            xyz.openbmc_project.ObjectMapper GetSubTree sias / 0 1 \
            xyz.openbmc_project.Software.ActivationBlocksTransition | cut -d " " -f 2)

    if [ "$number_fw_is_updating" == "0" ]
    then
        echo "False"
    else
        echo "True"
    fi
}

for i in $(seq 1 "$time_out")
do
    is_fw_updating=$(is_fw_updating)

    if [ "$is_fw_updating" == "False" ]
    then
        temp_val=$(busctl set-property xyz.openbmc_project.State.Host0 \
                    /xyz/openbmc_project/state/host0 xyz.openbmc_project.State.Host \
                    RequestedHostTransition s xyz.openbmc_project.State.Host.Transition.On)
        break
    fi

    sleep 1s
done

exit
