#!/bin/bash

# shellcheck disable=SC2046
# shellcheck disable=SC2086
# shellcheck disable=SC2005

# This function get the property of a dbus object.
# If fail then returns nothing.
# This function only support simple data type (b/s/u/q..)
# Return nothing if request is fail.
#
# Parameters:
#    $1: Service name
#    $2: Object path
#    $3: Interface name
#    $4: Property name
function get_dbus_property()
{
    local dbus_service=$1
    local dbus_object_path=$2
    local dbus_interface=$3
    local dbus_property=$4
    local property_value

    property_value=$(busctl get-property ${dbus_service} ${dbus_object_path} \
                ${dbus_interface} ${dbus_property})

    # The format of return data of get-property action is "<data type> <value>"
    if [ -n "${property_value}" ]
    then
        echo $(echo ${property_value} | cut -d " " -f 2)
    fi
}

# This function set the property of a dbus object.
# This function only support simple data type (b/s/u/q..)
#
# Parameters:
#    $1: Service name
#    $2: Object path
#    $3: Interface name
#    $4: Property name
#    $5: Data type
#    $6: Value
function set_dbus_property()
{
    local dbus_service=$1
    local dbus_object_path=$2
    local dbus_interface=$3
    local dbus_property=$4
    local dbus_data_type=$5
    local dbus_value=$6

    busctl set-property ${dbus_service} ${dbus_object_path} ${dbus_interface} \
                ${dbus_property} ${dbus_data_type} ${dbus_value}
}
