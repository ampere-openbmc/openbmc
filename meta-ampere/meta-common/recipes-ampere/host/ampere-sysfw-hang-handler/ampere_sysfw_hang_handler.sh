#!/bin/bash

# shellcheck disable=SC2046

# Do event trigger
function sel_trigger()
{
	echo "Error: system firmware hang, trigger sel"
	ampere_add_redfishevent.sh OpenBMC.0.1.AmpereCritical.Critical "System firmware, Mpro hang"
}

# Do reset the system
function reset_system()
{
	echo "Error: system firmware hang, reset the system"
	ipmitool chassis power reset
}

s0_last_hb_state=0
cnt=-1

p0_IOexp_val=$(i2cget -f -y 15 0x22 0x06)
p0_IOexp_val=$(("$p0_IOexp_val" & (1 << 4)))
if [[ "$p0_IOexp_val" == "0" ]]; then
    echo "Restrict to monitor heart beat GPIO when scandump mode is enabled"
    exit 0
fi

while true
do
    if [ -f /var/ampere/sysfw-hang-disable ]; then
        break
    fi

    # Monitor heart beat GPIO value, GPIOF4 for Socket 0
    s0_hb_state=$(gpioget $(gpiofind s0-heartbeat))
    if [ "$s0_last_hb_state" != "$s0_hb_state" ]; then
        cnt=0
    else
        cnt=$((cnt + 1))
    fi

    if [ "$cnt" -ge 6 ]; then
        echo "Error: system firmware hang"
        sel_trigger
        reset_system
        exit 0
    fi
    s0_last_hb_state="$s0_hb_state"
    sleep 0.5
done

exit 0
