#!/bin/bash

HOST_FW=/var/lib/host_fw_revision

# Update the Host Firmware Revision to D-bus
if [ -f "$HOST_FW" ]; then
    host_fw=$(cat $HOST_FW)
    busctl set-property xyz.openbmc_project.Software.Manager \
        /xyz/openbmc_project/software/bios_active \
        xyz.openbmc_project.Software.Version Version s "$host_fw"
fi
