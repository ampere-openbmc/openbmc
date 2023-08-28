#!/bin/bash

## NAME: The Ext Vref control script
## DESCRIPTION: The scrip will update the Vref threshold
#               and apply HW setting based on user setting. The rule will follow
#               logic as below
#  - S01_EXT_VREF_SEL GPIO = 1 => EXT_VREF = 700mV
#  - S01_EXT_VREF_SEL GPIO = 0 => EXT_VREF = 600mV
#               During the BMC booting, the BMC will call to this script
#               with the [ext_vref] parameter is empty.
#
## Syntax: ampere_ext_vref_control.sh [ext_vref]
## Example: ampere_ext_vref_control.sh 600

# shellcheck disable=SC2046
# shellcheck source=meta-ampere/meta-mitchell/recipes-ampere/platform/ampere-platform-init/gpio-lib.sh
source /usr/sbin/gpio-lib.sh

# The threshold follows the ipmi report
declare -A lnc_threshold=([600]=0.590 [700]=0.685)
declare -A unc_threshold=([600]=0.610 [700]=0.715)

# Entity inventory dbus sensor
s0_ext_vref_obj="S0_EXT_VREF"
s1_ext_vref_obj="S1_EXT_VREF"
s0_ext_vref_path="/xyz/openbmc_project/inventory/system/board/Mt_Mitchell_Motherboard/$s0_ext_vref_obj"
s1_ext_vref_path="/xyz/openbmc_project/inventory/system/board/Mt_Mitchell_Motherboard/$s1_ext_vref_obj"
entity_service="xyz.openbmc_project.EntityManager"
unc_interface="xyz.openbmc_project.Configuration.ADC.Thresholds1"
lnc_interface="xyz.openbmc_project.Configuration.ADC.Thresholds3"
entity_property="Value"

# RW partition
ext_vref_sel_file=/var/configuration/ext_vref_select

# RO partition
ext_vref_sel_default=/run/initramfs/ro/usr/share/ampere-ext-vref-control/ext_vref_sel_default

# S01_EXT_VREF_SEL = 1: EXT_VREF = 700mV
# S01_EXT_VREF_SEL = 0: EXT_VREF = 600V
hw_setting=(600 700)

# CPU idcode
# Ban8 = 4100a2d
# Siryn B0 = 13100a2d
cpu_idcode=(4100a2d 13100a2d)

# Entity-manager config json file
entity_config_file=/usr/share/entity-manager/configurations/mtmitchell_mb.json
system_config_file=/var/configuration/system.json
unc_direction_name="greater than"
lnc_direction_name="less than"
severity_non_critical=0
tmp_file=/tmp/tmp.json

# Power control dbus
chassis_service="xyz.openbmc_project.State.Chassis"
chassis_path="/xyz/openbmc_project/state/chassis0"
chassis_interface="xyz.openbmc_project.State.Chassis"
power_property="CurrentPowerState"

# Host state dbus
host_state_service="xyz.openbmc_project.State.Host"
host_state_path="/xyz/openbmc_project/state/host0"
host_state_interface="xyz.openbmc_project.State.Host"
host_state_property="CurrentHostState"

# Poll SOC_PWR_GD (s0-soc-pgood)
interval=100
duration=0.2

# Error code
cmdNotSupported=193
invalidVref=204
cmdInvalid4HostOn=213
hwConfigured=254
unspecifiedError=255

#GPIO Pin
ext_vref_sel_pin="ext-vref-sel"
sys_reset_pin="host0-sysreset-n"

help() {
	echo "Configure EXT VREF"
	echo "Usage: $(basename "$0") <option>"
	echo "Example :"
	echo "    When Reboot BMC"
	echo "        $(basename "$0") update-sensor-config"
	echo "    When Turn ON HOST"
	echo "        $(basename "$0") check-hw"
	echo "        $(basename "$0") assert-sys-reset"
	echo "        $(basename "$0") control-vref"
	echo "    When use ipmi command"
	echo "        $(basename "$0") 700"
}

apply_hw_setting() {
	for key in "${!hw_setting[@]}"
	do
		if [ "$1" == "${hw_setting[$key]}" ]; then
			gpioset $(gpiofind "$ext_vref_sel_pin")="$key"
			return
		fi
	done

	exit $invalidVref
}

read_hw_setting() {
	ext_vref_pin=$(gpio_name_get "$ext_vref_sel_pin")
	if [ "$?" != '1' ]; then
		echo "${hw_setting["$ext_vref_pin"]}"
	fi
}

check_pin_direction() {
	gpio=$(gpioinfo | grep -w "$1")
	if [ "$?" == '1' ]; then
		echo "Failed to get direction of $1 pin"
		return
	fi

	gpio=$(echo "$gpio" | cut -d ':' -f2 | cut -d '"' -f3)
	if echo "$gpio" | grep -q -E "input"; then
		echo "input"
	elif echo "$gpio" | grep -q -E "output"; then
		echo "output"
	fi
}

read_cpu_idcode() {
	# Poll SOC_PWR_GD (s0-soc-pgood)
	cnt=$interval
	while [ $cnt -gt 0 ];
	do
		state=$(gpioget $(gpiofind s0-soc-pgood))
		if [ "$state" == "1" ]; then
			break
		fi
		cnt=$((cnt - 1))
		if [ "$cnt" == "0" ]; then
			# The polling is timeout
			echo "$unspecifiedError"
			return
		fi
		sleep $duration
	done

	# BMC open access to CPU JTAG
	gpioset $(gpiofind hpm-fw-recovery)=0
	gpioset $(gpiofind jtag-sel-s0)=0

	# Read CPU IDcode by ampere_cpldupdate_jtag tool
	cpu_idcode_str=$(ampere_cpldupdate_jtag -u)
	if [ "$?" == '1' ]; then
		echo "$unspecifiedError"
		return
	fi

	# Return Ext Vref value based on CPU IDcode
	for key in "${!cpu_idcode[@]}"
	do
		if echo "$cpu_idcode_str" | grep -q -E "${cpu_idcode[$key]}"; then
			echo "${hw_setting["$key"]}"
			return
		fi
	done

	echo "$unspecifiedError"
	return
}

recover_ext_vref_config() {
	# Check the HW was configured?
	pin_direction=$(check_pin_direction "$ext_vref_sel_pin")
	if [ "$pin_direction" == "output" ]; then
		# The HW was configured
		# Recover from HW setting
		ext_vref_from_hw=$(read_hw_setting)
		echo "$ext_vref_from_hw" > "$ext_vref_sel_file"
		echo "Recover config file from HW setting"
	else
		# The HW have not yet configured
		# Recover from default setting
		cp $ext_vref_sel_default $ext_vref_sel_file
		echo "Recover config file from default setting"
	fi
}

read_vref_json() {
	vref_obj=$1
	direction_name=$2
	severity=$3

	cmd=$(printf "jq '.[].Exposes.[] | select(.Name==\"%s\").Thresholds.[] | select((.Direction==\"%s\") and .Severity==%d).Value' %s" "$vref_obj" "$direction_name" "$severity" "$entity_config_file")
	threshold=$(eval "$cmd")
	if [ "$?" == '1' ]; then
		echo "$unspecifiedError"
		return
	fi

	echo "$threshold"
}

update_vref_json() {
	vref_obj=$1
	direction_name=$2
	severity=$3
	threshold_input=$4

	cmd=$(printf "jq '(.[].Exposes.[] | select(.Name==\"%s\").Thresholds.[] | select((.Direction==\"%s\") and .Severity==%d).Value) |= %s' %s" "$vref_obj" "$direction_name" "$severity" "$threshold_input" "$entity_config_file")
	eval "$cmd" > "$tmp_file"
	if [ "$?" == '1' ]; then
		echo "$unspecifiedError"
		return
	fi

	mv "$tmp_file" "$entity_config_file"
	if [ -s $system_config_file ]; then
		rm "$system_config_file"
	fi

	echo "Update the $vref_obj in Entity-manager config successful"
}

set_property() {
	path=$1
	threshold=$2
	interface=$3

	mapper wait "$path"
	cur_val=$(busctl get-property "$entity_service" "$path" "$interface" "$entity_property")
	if [ "$?" == '1' ]; then
		echo "$unspecifiedError"
		return
	fi

	cur_val=$(echo "$cur_val" | cut -d' ' -f2)
	if [ "$cur_val" != "$threshold" ]; then
		busctl set-property "$entity_service" "$path" "$interface" "$entity_property" d "$threshold"
		if [ "$?" == '1' ]; then
			echo "$unspecifiedError"
			return
		fi
	fi
}

update_vref_sensor_threshold() {
	threshold=$1
	ext_vref_path=$2
	interface=$3

	rv=$(set_property "$ext_vref_path" "$threshold" "$interface")
	if [ "$rv" == "$unspecifiedError" ]; then
		echo "$unspecifiedError"
		return
	fi

}

update_sensor()
{
	ext_vref_input=$1
	sensor_threshold=$2

	unc_threshold_input=${unc_threshold["$ext_vref_input"]}
	lnc_threshold_input=${lnc_threshold["$ext_vref_input"]}

	# Read Vref threshold from entity-manager config file
	s0_unc_threshold=$(read_vref_json "$s0_ext_vref_obj" "$unc_direction_name" "$severity_non_critical")
	s0_lnc_threshold=$(read_vref_json "$s0_ext_vref_obj" "$lnc_direction_name" "$severity_non_critical")
	s1_unc_threshold=$(read_vref_json "$s1_ext_vref_obj" "$unc_direction_name" "$severity_non_critical")
	s1_lnc_threshold=$(read_vref_json "$s1_ext_vref_obj" "$lnc_direction_name" "$severity_non_critical")

	# Update Vref threshold to entity-manager config file
	if [ "$unc_threshold_input" != "$s0_unc_threshold" ]; then
		if [ -n "$sensor_threshold" ]; then
			update_vref_sensor_threshold "$unc_threshold_input" "$s0_ext_vref_path" "$unc_interface"
		fi
		update_vref_json "$s0_ext_vref_obj" "$unc_direction_name" "$severity_non_critical" "$unc_threshold_input"
	fi

	if [ "$unc_threshold_input" != "$s1_unc_threshold" ]; then
		if [ -n "$sensor_threshold" ]; then
			update_vref_sensor_threshold "$unc_threshold_input" "$s1_ext_vref_path" "$unc_interface"
		fi
		update_vref_json "$s1_ext_vref_obj" "$unc_direction_name" "$severity_non_critical" "$unc_threshold_input"
	fi

	if [ "$lnc_threshold_input" != "$s0_lnc_threshold" ]; then
		if [ -n "$sensor_threshold" ]; then
			update_vref_sensor_threshold "$lnc_threshold_input" "$s0_ext_vref_path" "$lnc_interface"
		fi
		update_vref_json "$s0_ext_vref_obj" "$lnc_direction_name" "$severity_non_critical" "$lnc_threshold_input"
	fi

	if [ "$lnc_threshold_input" != "$s1_lnc_threshold" ]; then
		if [ -n "$sensor_threshold" ]; then
			update_vref_sensor_threshold "$lnc_threshold_input" "$s1_ext_vref_path" "$lnc_interface"
		fi
		update_vref_json "$s1_ext_vref_obj" "$lnc_direction_name" "$severity_non_critical" "$lnc_threshold_input"
	fi
}

apply_ext_vref() {
	ext_vref_input=$1

	# Apply HW setting
	apply_hw_setting "$ext_vref_input"
	if [ "$?" == '1' ]; then
		echo "Failed to apply HW setting"
		echo "$unspecifiedError"
		return
	fi

	# Store user setting to ext_vref config
	echo "$ext_vref_input" > "$ext_vref_sel_file"
	echo "Store user setting $ext_vref_input to config file"

	# Update sensor threshold and senor config json
	update_sensor "$ext_vref_input" 1
}

update_vref_config_by_ipmi_commad() {
	ext_vref_input=$1

	# Check HOST status
	chassisstate=$(busctl get-property "$chassis_service" "$chassis_path" "$chassis_interface" "$power_property" | awk -F. '{print $NF}' | sed 's/.$//')
	echo "--- Current Chassis State: $chassisstate"
	if [ "$chassisstate" == 'On' ]; then
		exit $cmdInvalid4HostOn
	fi

	# Check vref input same as current value
	if [ -s $ext_vref_sel_file ]; then
		ext_vref_sel=$(cat "$ext_vref_sel_file")
		if [ "$ext_vref_sel" == "$ext_vref_input" ]; then
			exit 0
		fi
	fi

	# Only uses the IPMI OEM command when the external debugger is plugged into the platform
	# Check JTAG debugger presents
	jtag_dbgr=$(gpioget $(gpiofind jtag-dbgr-prsnt-n))
	if [ "$jtag_dbgr" == "0" ]
	then
		# The JTAG debugger is present
		# Apply Ext Vref update
		apply_ext_vref "$ext_vref_input"
	fi
}

update_ext_vref_threshold_sensor_when_bmc_reboot() {
	# Check configs file is existed
	if [ ! -s $ext_vref_sel_file ]; then
		# Empty File, Recover mode
		recover_ext_vref_config
	fi

	ext_vref_sel=$(cat $ext_vref_sel_file)
	# Update sensor config json
	update_sensor "$ext_vref_sel"
}

control_ext_vref_when_power_on_host() {
	# Check JTAG debugger presents
	jtag_dbgr=$(gpioget $(gpiofind jtag-dbgr-prsnt-n))
	if [ "$jtag_dbgr" == "0" ]
	then
		# Check configs file is existed
		if [ ! -s $ext_vref_sel_file ]; then
			# Empty File, Recover mode
			recover_ext_vref_config
		fi
		ext_vref_sel=$(cat $ext_vref_sel_file)
		# Apply Ext Vref update
		apply_ext_vref "$ext_vref_sel"
	else
		# BMC reads IDCODE
		ext_vref_sel=$(read_cpu_idcode)
		if [ "$ext_vref_sel" == "$unspecifiedError" ]; then
			# BMC sets SYS_RESET_N = HIGH to release CPU
			gpioset $(gpiofind "$sys_reset_pin")=1
			echo "Read CPU IDCODE failed"
			exit $unspecifiedError
		fi
		# Apply Ext Vref update
		apply_ext_vref "$ext_vref_sel"
	fi

	# BMC sets SYS_RESET_N = HIGH to release CPU
	gpioset $(gpiofind "$sys_reset_pin")=1
}

assert_sys_reset() {
	# BMC sets SYS_RESET_N =LOW to hold CPU in reset
	gpioset $(gpiofind "$sys_reset_pin")=0
}

check_hw_configured() {
	# Check the HW was configured
	pin_direction=$(check_pin_direction "$ext_vref_sel_pin")
	if [ "$pin_direction" == "input" ]; then
		echo "Control ext vref"
		exit 0
	elif [ "$pin_direction" == "output" ]; then
		echo "Ext Vref HW setting was configured before, skip control ext vref"
		exit $hwConfigured
	else
		exit $unspecifiedError
	fi
}

check_board_id() {
	# Check the mainboard by board_id (i2c0, address 0x20)
	board_id=$(i2cget -y -a 0 0x20 0x0 b)
	if [ "$?" == '1' ]; then
		echo "Failed to read board_id from i2c"
		exit $unspecifiedError
	fi

	# BIT[2] of the Board_ID will define the board name
	# 0: Mt.Mitchell
	# 1: Mt.David

	# BIT[5:4] Define xVTx
	# XVT1: 00
	# XVT2: 01
	# XVT3: 10

	# BIT[7:6] Define version
	# EV : 00
	# DV : 01
	# PV : 10
	mb_id_2=$(( board_id & 0x04 ))
	md_id_5_4=$(( (board_id & 0x30)>>4 ))
	md_id_7_6=$(( (board_id & 0xC0)>>6 ))
	if [ "$mb_id_2" == '0' ]; then
		if [[ $md_id_7_6 -lt 2 ]]; then
			exit $cmdNotSupported
		fi

		if [[ $md_id_5_4 -lt 1 ]]; then
			exit $cmdNotSupported
		fi
	fi
}

ext_vref=$1
#Check pamarameter from user setting
if [ -n "$ext_vref" ]; then
	if [ "$ext_vref" == "update-sensor-config" ]; then
		# Update sensor config json when BMC reboot
		check_board_id
		update_ext_vref_threshold_sensor_when_bmc_reboot
	elif [ "$ext_vref" == "check-hw" ]; then
		# Check HW when Turn ON HOST
		check_board_id
		check_hw_configured
	elif [ "$ext_vref" == "assert-sys-reset" ]; then
		# Asert sys reset pin when Turn On HOST
		assert_sys_reset
	elif [ "$ext_vref" == "control-vref" ]; then
		# Control Vref when Turn On HOST
		control_ext_vref_when_power_on_host
	else
		# Control Vref when use the ipmitool command
		check_board_id
		update_vref_config_by_ipmi_commad "$ext_vref"
	fi
fi

exit 0
