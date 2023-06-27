#!/bin/bash
# shellcheck disable=SC2004

fan_ctrl_bus=0x08
fan_ctrl_addr=0x5c

adt7462_reg_cfg1=0x01
adt7462_reg_cfg2=0x02
adt7462_reg_tach_enable=0x07
adt7462_reg_pwm_cfg=0x21
adt7462_reg_max_pwm=0x2c

adt7462_high_freq_mode=0x04
adt7462_setup_complete=0x20
adt7462_bhvr_manual_mode=0xe0
adt7462_tach_enable=0xff
adt7462_max_pwm=0xff
fan_nums=4

fan_hwmon_num=$(ls /sys/bus/i2c/drivers/adt7462/8-005c/hwmon)
fan_hwmon_path="/sys/class/hwmon/$fan_hwmon_num"
adt7462_bus_addr="8-005c"

phosphor_fan_service=("phosphor-fan-control@0.service"
                      "phosphor-fan-monitor@0.service"
                      "phosphor-fan-presence-tach@0.service"
                      "phosphor-pid-control.service")

declare -A fan_id_list
fan_list=(0 1 2 3)
fan_id_list=([0]=0 [1]=1 [2]=2 [3]=3)
input_list=(1 3 5 7)
pwm_list=(1 2 3 4)

function stop_phosphor_fan_services() {
    for service in "${phosphor_fan_service[@]}"
    do
        systemctl stop "$service"
        busctl call org.freedesktop.systemd1 /org/freedesktop/systemd1 org.freedesktop.systemd1.Manager MaskUnitFiles asbb 1 "$service" true true
    done
    systemctl daemon-reload
}

function start_phosphor_fan_services() {
    for service in "${phosphor_fan_service[@]}"
    do
        busctl call org.freedesktop.systemd1 /org/freedesktop/systemd1 org.freedesktop.systemd1.Manager UnmaskUnitFiles asb 1 "$service" true
    done

    systemctl daemon-reload

    for service in "${phosphor_fan_service[@]}"
    do
        if [ "$service" == "phosphor-pid-control.service" ] &&
        [ "$(obmcutil chassisstate | awk -F. '{print $NF}')" == 'Off' ]; then
            continue
        fi
        systemctl start "$service"
    done
}

function fan_controller_init() {
    # Check the ADT7462 driver binded before
    ADT7462=/sys/bus/i2c/drivers/adt7462/"$adt7462_bus_addr"
    if [ -d "$ADT7462" ]; then
        echo "Unbind the ADT7462 driver"
        echo "$adt7462_bus_addr" > /sys/bus/i2c/drivers/adt7462/unbind
        sleep 1
    fi
    # Set Maximum PWM duty cycle
    i2cset -f -y $fan_ctrl_bus $fan_ctrl_addr $adt7462_reg_max_pwm $adt7462_max_pwm
    # Set High frequency mode
    val=$(i2cget -f -y $fan_ctrl_bus $fan_ctrl_addr $adt7462_reg_cfg2)
    val=$(($val | $adt7462_high_freq_mode))
    i2cset -f -y $fan_ctrl_bus $fan_ctrl_addr $adt7462_reg_cfg2 $val
    # Enable TACH
    i2cset -f -y $fan_ctrl_bus $fan_ctrl_addr $adt7462_reg_tach_enable $adt7462_tach_enable
    # Set PWM Manual mode
    for i in $(seq 0 $((fan_nums - 1)))
    do
        reg_pwm_cfg=$(($adt7462_reg_pwm_cfg + $i))
        val=$(i2cget -f -y $fan_ctrl_bus $fan_ctrl_addr $reg_pwm_cfg)
        val=$(($val | $adt7462_bhvr_manual_mode))
        i2cset -f -y $fan_ctrl_bus $fan_ctrl_addr $reg_pwm_cfg $val
    done
    # Setup complete
    val=$(i2cget -f -y $fan_ctrl_bus $fan_ctrl_addr $adt7462_reg_cfg1)
    val=$(($val | $adt7462_setup_complete))
    i2cset -f -y $fan_ctrl_bus $fan_ctrl_addr $adt7462_reg_cfg1 $val
    # Bind ADT7462 driver
    echo "Bind the ADT7462 driver"
    echo "$adt7462_bus_addr" > /sys/bus/i2c/drivers/adt7462/bind
}

function getstatus() {
    status="Enabled"
    ret=0
    for service in "${phosphor_fan_service[@]}"
    do
        service_stt=$(systemctl is-active "$service" | grep inactive)
        if [ -n "$service_stt" ]; then
            status="Disabled"
            ret=1
            break
        fi
    done
    echo "Thermal Control operational status: $status"
    exit ${ret}
}

function setstatus() {
    if [ "$1" == 0 ]; then
        # Enable fan services
        start_phosphor_fan_services
    else
        # Disable fan services
        stop_phosphor_fan_services
    fi
}

function setspeed() {
    # Get fan_pwm value of the fan
    fan_index=$1
    pwm_val=$2
    id=${fan_id_list[${fan_index}]}

    if [ -n "$id" ]
    then
        # Get pwm sysfs file of the fan
        fan_pwm=pwm${pwm_list[$id]}
        # Scale PWM to 255, adding 50 for rounding.
        pwm_scaled=$(((($pwm_val * 255) + 50) / 100))

        if ! (echo "$pwm_scaled" > "${fan_hwmon_path}/${fan_pwm}");
        then
            echo "Error: Set Fan PWM Duty Cycle failed!"
            exit 255
        fi
    else
        echo "Error: Fan $fan_index doesn't exist"
        exit 1
    fi
}

function getspeed() {
    fan_index=$1
    id=${fan_id_list[${fan_index}]}
    if [ -n "$id" ]
    then
        fan_input=fan${input_list[$id]}_input
        fan_pwm=pwm${pwm_list[$id]}

        # Get fan speed and pwm from hwmon
        tach_reading=$(cat "${fan_hwmon_path}/${fan_input}")
        ret=$?
        if [ $ret != 0 ]; then
            echo "Error: Get Fan Speed failed!"
            exit 1
        fi

        pwm_reading=$(cat "${fan_hwmon_path}/$fan_pwm")
        ret=$?
        if [ $ret != 0 ]; then
            echo "Error: Get Fan PWM Duty Cycle failed!"
            exit 1
        fi

        # Scale PWM to 100, adding 127 for rounding.
        pwm_reading_scaled=$(((("$pwm_reading" * 100) + 127) / 255))

        echo "FAN${fan_index}, PWM: $pwm_reading, Duty cycle: $pwm_reading_scaled%, Speed(RPM): $tach_reading"
    else
        echo "Error: Fan $fan_index doesn't exist"
        exit 1
    fi
}

# Usage of this utility
function usage() {
    echo "Usage:"
    echo "  ampere_fanctrl.sh [getstatus] [setstatus <0:enable|1:disable>] [setspeed all/<fan> <duty>] [getspeed <fan>]"
    echo "  fan: 0-3"
    echo "  duty: 1-100"
}

if [ "$1" == "getstatus" ]; then
    getstatus
elif [ "$1" == "setstatus" ] && [ -n "$2" ]; then
    setstatus "$2"
elif [ "$1" == "setspeed" ]; then
    if [ "$2" == "all" ] && [ -n "$3" ]; then
        for fan in "${fan_list[@]}"
        do
            setspeed "$fan" "$3"
        done
    elif [ -n "$2" ] && [ -n "$3" ]; then
        setspeed "$2" "$3"
    else
        usage
    fi
elif [ "$1" == "getspeed" ]; then
    if [ "$2" == "all" ]; then
        for fan in "${fan_list[@]}"
        do
            getspeed "$fan"
        done
    elif [ -n "$2" ]; then
        getspeed "$2"
    else
        usage
    fi
else
    usage
fi
