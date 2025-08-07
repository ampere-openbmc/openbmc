#!/bin/bash

# Helper script to support enable/disable Scandump Mode
# Author : Hieu Huynh (hieu.huynh@amperecomputing.com)
#
# To enable Scandump mode:
#    ampere_scandump_mode.sh enable
#
# To disable Scandump mode:
#    ampere_scandump_mode.sh disable
#
# To get Scandump mode status:
#    ampere_scandump_mode.sh getstatus
#
# The init() function will be called during BMC bootup
# to preserve the scandump condition (no user interaction)


dependent_services=("ampere-sysfw-hang-handler.service"
                    "pldmd.service")

init() {
	status=$(getstatus)

	if [[ $status =~ "enabled" ]]
	then
		echo "Preserve Scandump mode as enabled"
		handle_dependencies "disable"
	fi
}

handle_dependencies() {
	action=$1
	if [[ $action == "enable" ]]; then
		echo "Recover scandump mode dependent services"
		for service in "${dependent_services[@]}"
		do
			systemctl start "$service"
		done
		# Enable fan control
		/usr/sbin/ampere_fanctrl.sh setstatus 0
	else
		echo "Disable scandump mode dependent services"
		for service in "${dependent_services[@]}"
		do
			systemctl stop "$service"
		done
		# Disable fan control
		/usr/sbin/ampere_fanctrl.sh setstatus 1
		/usr/sbin/ampere_fanctrl.sh setspeed force all 100
	fi
}

enable_scandump_mode() {
	status=$(getstatus)
	if [[ $status =~ "enabled" ]]
	then
		echo "Scandump mode is already enabled"
		exit 0
	fi
	echo "Enable Scandump mode"

	handle_dependencies "disable"

	# Enable scandump mode in CPLD
	# Get Port0 value
	p0_val=$(i2cget -f -y 15 0x22 0x02)
	p0_val=$(("$p0_val" | (1 << 4)))
	# Set Port0[4] value to "1" to mask all CPU’s GPIOs, set Port0[4].
	i2cset -f -y 15 0x22 0x02 $p0_val

	p0_IOexp_val=$(i2cget -f -y 15 0x22 0x06)
	p0_IOexp_val=$(("$p0_IOexp_val" & ~(1 << 4)))
	# Config CPLD's IOepx Port0[4] from input to output, clear IOepx Port0[4].
	i2cset -f -y 15 0x22 0x06 $p0_IOexp_val
}

diable_scandump_mode() {
	echo "Disable Scandump mode"

	# Disable scandump mode in CPLD
	# Get Port0 value
	p0_val=$(i2cget -f -y 15 0x22 0x02)
	p0_val=$(("$p0_val" & ~(1 << 4)))
	# Set Port0[4] value to "0" to unmask all CPU’s GPIOs, clear Port0[4].
	i2cset -f -y 15 0x22 0x02 $p0_val

	p0_IOexp_val=$(i2cget -f -y 15 0x22 0x06)
	p0_IOexp_val=$(("$p0_IOexp_val" | (1 << 4)))
	# Config CPLD's IOepx Port0[4] from output to input, set IOepx Port0[4].
	i2cset -f -y 15 0x22 0x06 $p0_IOexp_val

	handle_dependencies "enable"
}

getstatus() {
	# Get CPLD's IOepx Port0[4], if this bit is "0" scandump mode is enabled.
	p0_IOexp_val=$(i2cget -f -y 15 0x22 0x06)
	p0_IOexp_val=$(("$p0_IOexp_val" & (1 << 4)))
	if [[ "$p0_IOexp_val" == "0" ]]; then
		echo "Scandump mode is enabled"
		exit 1
	else
		echo "Scandump mode is disabled"
		exit 0
	fi
}

# Usage of this utility
usage() {
	echo "Usage:"
	echo "  - To enable Scandump mode"
	echo "     $(basename "$0") enable"
	echo "  - To disable Scandump mode"
	echo "     $(basename "$0") disable"
	echo "  - To get Scandump mode status"
	echo "     $(basename "$0") getstatus"
	exit 0
}

if [[ $1 == "enable" ]]; then
	enable_scandump_mode
elif [[ $1 == "disable" ]]; then
	diable_scandump_mode
elif [[ $1 == "getstatus" ]]; then
	getstatus
elif [[ $1 == "init" ]]; then
	init
else
	echo "Invalid mode"
	usage
fi
