#!/bin/bash

# shellcheck source=meta-ampere/meta-adlink/recipes-ampere/platform/ampere-utils/gpio-lib.sh
source /usr/sbin/gpio-lib.sh

function pre-platform-init() {
    echo "Do pre platform init"
}


function post-platform-init() {
    echo "Do post platform init"
}

export output_high_gpios_in_ac=(
    # add device enable, mux setting, device select gpios
    "power-chassis-control"
    "spi0-program-sel"
)

export output_low_gpios_in_ac=(
)

export input_gpios_in_ac=(
    # add device enable, mux setting, device select gpios
)

export output_high_gpios_in_bmc_reboot=(
    "spi0-program-sel"
)

export output_low_gpios_in_bmc_reboot=(
)

export input_gpios_in_bmc_reboot=(
)
