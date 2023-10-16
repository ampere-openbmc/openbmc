#!/bin/bash

# shellcheck disable=SC2046

inv_service="xyz.openbmc_project.Inventory.Manager"
inv_obj_s0="/xyz/openbmc_project/inventory/system/chassis/motherboard/cpu0"
inv_obj_s1="/xyz/openbmc_project/inventory/system/chassis/motherboard/cpu1"
inv_inf="xyz.openbmc_project.Inventory.Item"
inv_property="Present"

function check_cpu_presence()
{
	# Check CPU presence, identify whether it is 1P or 2P system
	s0_presence=$(busctl get-property "$inv_service" "$inv_obj_s0" \
		"$inv_inf" "$inv_property" | cut -d' ' -f2)
	s1_presence=$(busctl get-property "$inv_service" "$inv_obj_s1" \
		"$inv_inf" "$inv_property" | cut -d' ' -f2)
	if [ "$s0_presence" == "true" ] && [ "$s1_presence" == "true" ]; then
		ampere_add_redfishevent.sh OpenBMC.0.1.AmpereEvent.OK "Host firmware boots with 2 Processor"
	elif [ "$s0_presence" == "true" ]; then
		ampere_add_redfishevent.sh OpenBMC.0.1.AmpereEvent.OK "Host firmware boots with 1 Processor"
	else
		ampere_add_redfishevent.sh OpenBMC.0.1.AmpereEvent.OK "No Processor is present"
	fi
}

function get_dbus_property()
{
	service=$1
	object_path=$2
	interface=$3
	property=$4

	value=$(busctl get-property "$service" "$object_path" "$interface" "$property" | cut -d" " -f2)

	echo "$value"
}

function is_ATX_power_good()
{
	pgood_value=$(get_dbus_property org.openbmc.control.Power \
		/org/openbmc/control/power0 org.openbmc.control.Power pgood)

	if [ "$pgood_value" == "0" ]
	then
		echo 0
	else
		echo 1
	fi
}

function is_PCP_power_good()
{
	pcp_value=$(get_dbus_property xyz.openbmc_project.State.HostCondition.Gpio0 \
		/xyz/openbmc_project/Gpios/host0 xyz.openbmc_project.Condition.HostFirmware \
		CurrentFirmwareCondition)

	if [[ "$pcp_value" == *".Running"* ]]
	then
		echo 1
	else
		echo 0
	fi
}

function check_power_state()
{
	echo "ATX power good checking"
	state=$(is_ATX_power_good)
	if [ "$state" == "0" ]
	then
		echo "Error: Failed to turn on ATX Power"
		ampere_add_redfishevent.sh OpenBMC.0.1.PowerSupplyPowerGoodFailed.Critical "60000"
		exit 0
	else
		ampere_add_redfishevent.sh OpenBMC.0.1.AmpereEvent.OK "ATX Power is ON"
	fi

	echo "Soc power good checking"
	state=$(gpioget $(gpiofind s0-soc-pgood))
	if [ "$state" == "0" ]
	then
		echo "Error: Soc domain power failure"
		ampere_add_redfishevent.sh OpenBMC.0.1.AmpereCritical.Critical "Soc domain, power failure"
		exit 0
	else
		ampere_add_redfishevent.sh OpenBMC.0.1.AmpereEvent.OK "SoC power domain is ON"
	fi

	echo "PCP power good checking"
	state=$(is_PCP_power_good)
	if [ "$state" == "0" ]
	then
		echo "Error: PCP domain power failure. Power off Host"
		ampere_add_redfishevent.sh OpenBMC.0.1.AmpereCritical.Critical "PCP domain, power failure"
		busctl set-property xyz.openbmc_project.State.Chassis \
			/xyz/openbmc_project/state/chassis0 \
			xyz.openbmc_project.State.Chassis RequestedPowerTransition s \
			xyz.openbmc_project.State.Chassis.Transition.Off
		exit 0
	else
		ampere_add_redfishevent.sh OpenBMC.0.1.AmpereEvent.OK "PCP power is ON"
	fi
}

action=$1

if [ "$action" == "check_cpu" ]
then
	echo "Check CPU presence"
	check_cpu_presence
elif [ "$action" == "check_power" ]
then
	echo "Check Power state"
	check_power_state
fi

exit 0
