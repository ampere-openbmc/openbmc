#!/bin/bash
#
# This script is used to set the default MAC address to the same one that's used
# in the ADLINK MegaRAC BMC images. If the eth address exists in the U-boot
# environment, that's used in preference to the hard-coded address.
#

ETH0_MAC_ADDR=00:30:64:33:87:e5
ETH1_MAC_ADDR=06:c2:49:a6:09:3b

if fw_printenv "ethaddr" 2>/dev/null; then
  ETH0_MAC_ADDR=$(fw_printenv "ethaddr" 2>/dev/null | sed "s/^ethaddr=//")
fi

if fw_printenv "eth1addr" 2>/dev/null; then
  ETH1_MAC_ADDR=$(fw_printenv "eth1addr" 2>/dev/null | sed "s/^eth1addr=//")
fi

# Check if the Ethernet port has correct MAC Address
ETH0_INCLUDE_MAC=$(ip link show eth0 | grep link | awk '{print $2}' | grep -i "$ETH0_MAC_ADDR")
if [ -n "$ETH0_INCLUDE_MAC" ]; then
    echo "MAC Addresses are already configured"
    exit 0
fi

for i in 0 1; do
    MAC_ADDR=ETH${i}_MAC_ADDR
    ENV_PORT=$((i+1))
    if [ $i = 0 ]; then
        UBOOTENV=ethaddr
        INTERFACE=eth0
    else
        UBOOTENV=eth1addr
        INTERFACE=usb0
    fi

    fw_setenv ${UBOOTENV} "${!MAC_ADDR}"

    # Enabling BMC-generated ARP responses & setting SNMP Community String to public
    if [ $i = 0 ]; then
        ip link set "${INTERFACE}" down
        ip link set dev "${INTERFACE}" address "${!MAC_ADDR}"
        retval=$?
        if [[ $retval -ne 0 ]]; then
            echo "ERROR: Can not update ${INTERFACE} MAC ADDR"
            exit 1
        fi

        # Setting LAN MAC Address to xx:xx:xx:xx:xx:xx
        ipmitool lan set "${ENV_PORT}" macaddr "${!MAC_ADDR}"
        ipmitool lan set "${ENV_PORT}" arp respond on
        ipmitool lan set "${ENV_PORT}" snmp public
        ip link set "${INTERFACE}" up
    fi
    echo "Successfully updated the MAC address ${!MAC_ADDR} for ${INTERFACE}"
done
