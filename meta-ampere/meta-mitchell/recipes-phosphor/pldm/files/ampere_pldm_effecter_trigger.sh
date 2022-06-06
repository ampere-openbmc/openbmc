#!/bin/bash

# Usage of this utility
function usage() {
    echo "Usage: ampere_pldm_effecter_trigger.sh [OPTION] <0/1> [type] [value]"
    echo "SOCKET:"
    echo "        0: Setting for S0"
    echo "        1: Setting for S1"
    echo "OPTION:"
    echo "        -h|--help"
    echo "        -g|--get <0/1> <type>   : To get value of one type"
    echo "        -s|--set <0/1> <type> <value>   :To set value of one type"
    echo "TYPE:"
    echo "        PLimit: Set SoC power limit"
    echo "        PMinPowerLimit: Set SoC power min limit"
    echo "        DRAMMThrotEn: Enable DRAM Throt. Value 1"
    echo "        BERTTrigger: Trigger one BERT event. Value 2"
    echo "        NMITrigger: Trigger an non-maskable interrupt to the host processor. Value 2"
}

object="xyz.openbmc_project.PLDM"
interfaceName="xyz.openbmc_project.Sensor.Value"
propertyName="Value"

listPathS0=(
    "/xyz/openbmc_project/effecters/power/S0_PLimit"
    "/xyz/openbmc_project/effecters/power/S0_PMin_Pwr_Lmt"
    "/xyz/openbmc_project/effecters/oem/S0_DRAM_MThrotEn"
    "/xyz/openbmc_project/effecters/count/S0_Effecter_204"
    "/xyz/openbmc_project/effecters/count/S0_Effecter_201"
)

listPathS1=(
    "/xyz/openbmc_project/effecters/power/S1_PLimit"
    "/xyz/openbmc_project/effecters/power/S1_PMin_Pwr_Lmt"
    "/xyz/openbmc_project/effecters/oem/S1_DRAM_MThrotEn"
    "/xyz/openbmc_project/effecters/count/S1_Effecter_204"
    "/xyz/openbmc_project/effecters/count/S1_Effecter_201"
)

listOptions=(
    "PLimit"
    "PMinPowerLimit"
    "DRAMMThrotEn"
    "NMITrigger"
    "BERTTrigger"
)

function get_all_options() {
    if [[ "$1" == "0" ]] || [[ "$1" == "" ]]; then
        for idx in "${!listOptions[@]}"; do
            str=$(busctl get-property "$object" "${listPathS0[$idx]}" "$interfaceName" "$propertyName")
            val=$(echo "$str" | cut -d " " -f 2)
            echo "[S0] ${listOptions[$idx]}: $val"
        done
    fi
    if [[ "$1" == "1" ]] || [[ "$1" == "" ]]; then
        for idx in "${!listOptions[@]}"; do
            str=$(busctl get-property "$object" "${listPathS1[$idx]}" "$interfaceName" "$propertyName")
            val=$(echo "$str" | cut -d " " -f 2)
            echo "[S1] ${listOptions[$idx]}: $val"
        done
    fi
}

function get_option() {
    if [ "$1" == "0" ]; then
        str=$(busctl get-property "$object" "${listPathS0[$2]}" "$interfaceName" "$propertyName")
        val=$(echo "$str" | cut -d " " -f 2)
        echo "[S0] ${listOptions[$2]}: $val"
    elif [ "$1" == "1" ]; then
        str=$(busctl get-property "$object" "${listPathS1[$2]}" "$interfaceName" "$propertyName")
        val=$(echo "$str" | cut -d " " -f 2)
        echo "[S1] ${listOptions[$2]}: $val"
    fi
}

function find_type_idx() {
    for idx in "${!listOptions[@]}"; do
        if [ "${listOptions[$idx]}" == "$1" ]; then
            echo "$idx"
            return 1
        fi
    done
    echo "-1"
}

function set_option() {
    if [ "$1" == "0" ]; then
        str=$(busctl set-property "$object" "${listPathS0[$2]}" "$interfaceName" "$propertyName" d "$3")
        echo "[S0]  Set ${listOptions[$2]}: to $3"
    elif [ "$1" == "1" ]; then
        str=$(busctl set-property "$object" "${listPathS1[$2]}" "$interfaceName" "$propertyName" d "$3")
        echo "[S1] Set ${listOptions[$2]}: to $3"
    fi
}

operation=$1
socket=$2
type=$3
value=$4

# Process operations
case "$operation" in
    "-g" | "--get")
        if [[ "$socket" != "0" ]] && [[ "$socket" != "1" ]] && [[ "$socket" != "" ]]; then
            echo "Invalid socket \"$socket\". Socket must be 0 or 1 or empty."
            exit
        fi

        st=$(find_type_idx "$type")
        if [ "$st" != "-1" ]; then
            get_option "$socket" "$st"
        else
            get_all_options "$socket"
        fi
        ;;
    "-s" | "--set")
        if [[ "$socket" != "0" ]] && [[ "$socket" != "1" ]]; then
            echo "Invalid socket \"$socket\". Socket must be 0 or 1 for set."
            exit
        fi

        st=$(find_type_idx "$type")
        if [ "$st" == "-1" ]; then
            echo "Invalid option to set $type"
            exit
        fi

        if [[ "$type" == "BERTTrigger" ]] || [[ "$type" == "NMITrigger" ]]; then
            value="2"
            set_option "$socket" "$st" "$value"
        elif [[ "$type" == "DRAMMThrotEn" ]]; then
            value="1"
            set_option "$socket" "$st" "$value"
        else
            set_option "$socket" "$st" "$value"
        fi
        ;;
    "-h" | "--help" | "")
            usage;
            ;;
esac

