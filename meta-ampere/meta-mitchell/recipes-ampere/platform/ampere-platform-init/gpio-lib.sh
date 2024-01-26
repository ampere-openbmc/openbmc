#!/bin/bash

# Configure GPIO as output and set its value
AST2600_GPIO_BASE=(
    512
    720
    756
)

function gpio_get_val() {
	echo "$1" > /sys/class/gpio/export
	cat /sys/class/gpio/gpio"$1"/value
	echo "$1" > /sys/class/gpio/unexport
}

function gpio_name_get()
{
    str=$(gpiofind "$1")
    #Verify error code when run gpiofind
    if [ "$?" == '1' ]; then
        echo "Invalid gpio name $1"
    else
        offset=$(echo "$str"|cut -d " " -f 2)
        gpioid=$(echo "$str"|cut -c 9)
        gpioPin=$(("$offset" + ${AST2600_GPIO_BASE[$gpioid]}))
        gpio_get_val "$gpioPin"
    fi
}
