#!/bin/bash

# shellcheck disable=SC2046
# shellcheck disable=SC2004
# shellcheck disable=SC2086
# shellcheck source=meta-ampere/meta-mitchell/recipes-ampere/platform/ampere-misc/power-manager/power_cap_dbus_utils.sh
source /usr/sbin/power_cap_dbus_utils.sh

# Check either the Exception action is OEM or not.
System_Exception_Action=$(get_System_Exception_Action)

if [[ "${System_Exception_Action}" != *"Oem"* ]]
then
    exit 0
fi

System_Power_Limit=$(get_System_Power_Limit)
Current_Sys_Power_Consumed=$(get_Current_Sys_Power_Consumed)
Plimit_Sensor_MaxValue=$(get_Plimit_Sensor_MaxValue)
Plimit_Sensor=$(get_Plimit_Sensor)

System_Power_Limit=${System_Power_Limit%.*}
Current_Sys_Power_Consumed=${Current_Sys_Power_Consumed%.*}
Plimit_Sensor_MaxValue=${Plimit_Sensor_MaxValue%.*}
Plimit_Sensor=${Plimit_Sensor%.*}

while [ ${System_Power_Limit} -gt ${Current_Sys_Power_Consumed} ]
do
    DRAM_Max_Throttle_Enable=$(get_DRAM_Max_Throttle_Enable)
    if [ -z ${DRAM_Max_Throttle_Enable} ]
    then
        exit 0
    fi

    if [ ${DRAM_Max_Throttle_Enable} -eq 1 ]
    then
        set_DRAM_Max_Throttle_Enable 0
    elif [ ${Plimit_Sensor} -lt ${Plimit_Sensor_MaxValue} ]
    then
        X=$((((${System_Power_Limit} - ${Current_Sys_Power_Consumed})) / ${devided_value}))
        if [ ${X} -gt ${X_limit} ]
        then
            X=${X_limit}
        fi

        Plimit_Sensor=$((${Plimit_Sensor} + ${X}))

        if [ ${Plimit_Sensor} -gt ${Plimit_Sensor_MaxValue} ]
        then
            Plimit_Sensor=${Plimit_Sensor_MaxValue}
        fi

        set_Plimit_Sensor ${Plimit_Sensor}
    else
        event="Power Limit OEM action: PLimit has been set to max"
        add_OEM_Action_Redfish_Log "${event}"
        break
    fi
    
    # The poll rate of PSU sensor is 1s
    sleep 1s
    System_Power_Limit=$(get_System_Power_Limit)
    Current_Sys_Power_Consumed=$(get_Current_Sys_Power_Consumed)
    System_Power_Limit=${System_Power_Limit%.*}
    Current_Sys_Power_Consumed=${Current_Sys_Power_Consumed%.*}
done

exit 0
