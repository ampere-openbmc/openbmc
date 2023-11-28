#!/bin/bash
# Ampere Utilities lib provides the API to
# Check Socket present: sx_present 0/1

# shellcheck disable=SC2046

ERR_SUCCESS="0"
ERR_FAILURE="1"

function sx_present()
{
	index=$1
	retVal=$ERR_FAILURE
	objects=$(busctl call xyz.openbmc_project.ObjectMapper \
				/xyz/openbmc_project/object_mapper \
				xyz.openbmc_project.ObjectMapper GetObject sas \
				/xyz/openbmc_project/inventory/system/chassis/motherboard/cpu"$index" \
				1 xyz.openbmc_project.Inventory.Item)
	if [[ "$objects" == "" ]]; then
		state=$(gpioget $(gpiofind presence-cpu"$index"))
		if [[ "$state" == "0" ]]; then
			retVal=$ERR_SUCCESS
		fi
	else
		service=$(echo "$objects" | cut -d" " -f3 | cut -d"\"" -f2)
		if [[ "$objects" != "" ]]; then
			present=$(busctl get-property "$service" \
						/xyz/openbmc_project/inventory/system/chassis/motherboard/cpu"$index" \
						xyz.openbmc_project.Inventory.Item Present | cut -d" " -f2)
			if [[ "$present" == "true" ]]; then
				retVal=$ERR_SUCCESS
			fi
		fi
	fi

	echo "$retVal"
}
