#!/bin/bash

# shellcheck disable=SC2046

Socket=$1

if [ $(gpioget $(gpiofind host0-special-boot)) == 1 ]; then
    # Create SEL if Secprov failure in case of SPECIAL_BOOT mode
    touch /tmp/secprov
    /usr/sbin/ampere_add_redfishevent.sh OpenBMC.0.1.AmpereEvent.Warning "Authentication Failure detected: SECProv Failed"
else
    # Create SEL if Authentication Failure detected
    /usr/sbin/ampere_add_redfishevent.sh OpenBMC.0.1.AmpereEvent.Warning "Socket $Socket Authentication Failure detected"
fi
