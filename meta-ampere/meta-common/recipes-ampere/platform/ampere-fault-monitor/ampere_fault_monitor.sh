#!/bin/bash
# This script PSU and update fault LED status

# shellcheck disable=SC2046

# Inventory variables
inv_service="xyz.openbmc_project.Inventory.Manager"
inv_inf="xyz.openbmc_project.Inventory.Item"

# Led variables
led_service='xyz.openbmc_project.LED.GroupManager'
led_psu_fault_path='/xyz/openbmc_project/led/groups/psu_fault'
led_fault_interface='xyz.openbmc_project.Led.Group'
led_fault_property='Asserted'
on="true"
off="false"

turn_on_off_psu_fault_led() {
    busctl set-property $led_service $led_psu_fault_path $led_fault_interface $led_fault_property b "$1" >> /dev/null
}

check_psu_failed() {
    local psu0_presence
    local psu1_presence

    psu0_presence=$(busctl get-property "$inv_service" \
        /xyz/openbmc_project/inventory/system/powersupply/PowerSupply0 \
        "$inv_inf" Present | cut -d' ' -f2)
    psu0_failed="true"
    if [ "$psu0_presence" == "true" ]; then
        psu0_failed="false"
    fi

    psu1_presence=$(busctl get-property "$inv_service" \
        /xyz/openbmc_project/inventory/system/powersupply/PowerSupply1 \
        "$inv_inf" Present | cut -d' ' -f2)
    psu1_failed="true"
    if [ "$psu1_presence" == "true" ]; then
        psu1_failed="false"
    fi

    if [ "$psu0_failed" == "true" ] || [ "$psu1_failed" == "true" ]; then
        turn_on_off_psu_fault_led $on
    else
        turn_on_off_psu_fault_led $off
    fi
}

# Daemon start
while true
do
    # Monitors PSU presence
    check_psu_failed

    sleep 2
done

exit 1
