#!/bin/bash

# Helper script to report firmware version for components on the system (MB CPLD, BMC CPLD)
# Author : Hieu Huynh (hieu.huynh@amperecomputing.com)
#
# Get MB CPLD firmware revision:
#    ampere_firmware_version.sh mb_cpld
#
# Get BMC CPLD firmware revision:
#    ampere_firmware_version.sh bmc_cpld

# shellcheck disable=SC2046

do_mb_cpld_firmware_report() {
	echo "MB (CIO) CPLD"
	gpioset $(gpiofind hpm-fw-recovery)=1
	gpioset $(gpiofind jtag-program-sel)=1
	sleep 1
	ampere_cpldupdate_jtag -v
	ampere_cpldupdate_jtag -i
}

do_bmc_cpld_firmware_report() {
	echo "BMC CPLD"
	gpioset $(gpiofind jtag-program-sel)=0
	sleep 1
	ampere_cpldupdate_jtag -v
	ampere_cpldupdate_jtag -i
}

if [ $# -eq 0 ]; then
	echo "Usage:"
	echo "  - Get MB (CIO) CPLD firmware revision"
	echo "     $(basename "$0") mb_cpld"
	echo "  - Get BMC CPLD firmware revision"
	echo "     $(basename "$0") bmc_cpld"
	exit 0
fi

TYPE=$1

if [[ $TYPE == "mb_cpld" ]]; then
	do_mb_cpld_firmware_report
elif [[ $TYPE == "bmc_cpld" ]]; then
	do_bmc_cpld_firmware_report
else
	echo "Board type invalid"
fi

exit 0
