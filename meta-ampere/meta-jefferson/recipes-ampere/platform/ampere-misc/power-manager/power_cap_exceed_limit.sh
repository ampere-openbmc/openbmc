#!/bin/bash

# shellcheck disable=SC2046
# shellcheck disable=SC2086
# shellcheck disable=SC2004
# shellcheck source=meta-ampere/meta-jefferson/recipes-ampere/platform/ampere-misc/power-manager/power_cap_dbus_utils.sh
source /usr/sbin/power_cap_dbus_utils.sh

# Check either the Exception action is OEM or not.
System_Exception_Action=$(get_System_Exception_Action)
if [[ "${System_Exception_Action}" != *"Oem"* ]]
then
    exit 0
fi

Current_Sys_Power_Consumed=$(get_Current_Sys_Power_Consumed)
System_Power_Limit=$(get_System_Power_Limit)
Plimit_Sensor=$(get_Plimit_Sensor)
Plimit_Sensor_MinValue=$(get_Plimit_Sensor_MinValue)

Current_Sys_Power_Consumed=${Current_Sys_Power_Consumed%.*}
System_Power_Limit=${System_Power_Limit%.*}
Plimit_Sensor=${Plimit_Sensor%.*}
Plimit_Sensor_MinValue=${Plimit_Sensor_MinValue%.*}

while [ ! ${System_Power_Limit} -gt ${Current_Sys_Power_Consumed} ]
do
    if [ ${Plimit_Sensor} -gt ${Plimit_Sensor_MinValue} ]
    then
        X=$((((${Current_Sys_Power_Consumed} - ${System_Power_Limit})) / ${devided_value}))
        if [ ${X} -gt ${X_limit} ]
        then
            X=${X_limit}
        fi

        Plimit_Sensor=$((${Plimit_Sensor} - ${X}))

        if [[ ${Plimit_Sensor} -lt ${Plimit_Sensor_MinValue} ]]
        then
            Plimit_Sensor=${Plimit_Sensor_MinValue}
        fi

        set_Plimit_Sensor ${Plimit_Sensor}
    fi

    # The poll rate of PSU sensor is 1s
    sleep 1s
    System_Power_Limit=$(get_System_Power_Limit)
    Current_Sys_Power_Consumed=$(get_Current_Sys_Power_Consumed)
    System_Power_Limit=${System_Power_Limit%.*}
    Current_Sys_Power_Consumed=${Current_Sys_Power_Consumed%.*}
done

exit 0
