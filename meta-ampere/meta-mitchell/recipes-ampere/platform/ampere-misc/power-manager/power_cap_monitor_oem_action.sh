#!/bin/bash

# shellcheck disable=SC2086
# shellcheck source=meta-ampere/meta-mitchell/recipes-ampere/platform/ampere-misc/power-manager/power_cap_dbus_utils.sh
source /usr/sbin/power_cap_dbus_utils.sh

cur_act_state=$(get_Power_Limit_Activate_State)
cur_except_act=$(get_System_Exception_Action)

while true
do
    pre_act_state=${cur_act_state}
    pre_except_act=${cur_except_act}
    reset_flag=false

    cur_act_state=$(get_Power_Limit_Activate_State)
    cur_except_act=$(get_System_Exception_Action)

    if [[ "${pre_act_state}" == "true" ]] && [[ "${cur_act_state}" == "false" ]] && [[ "${cur_except_act}" == *"Oem"* ]]
    then
        reset_flag=true
    fi

    if [[ "${cur_except_act}" != *"Oem"* ]] && [[ "${pre_except_act}" == *"Oem"* ]]
    then
        reset_flag=true
    fi

    if [[ "${reset_flag}" == "true" ]]
    then
        host_running=$(is_host_running)
        if [[ "${host_running}" == "false"* ]]
        then
            continue
        fi
        # Stop power-cap-exceed/drops-below services to ensure that no more 
        # power action is running
        systemctl stop power-cap-drops-below-limit.service
        systemctl stop power-cap-exceeds-limit.service
        plimit_max_value=$(get_Plimit_Sensor_MaxValue)
        set_Plimit_Sensor ${plimit_max_value}
        set_DRAM_Max_Throttle_Enable 0
    fi

    sleep 2
done
