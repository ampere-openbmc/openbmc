FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Remove, from the comhpcalt image, the service file that starts the skeleton power
# control application. That image will use the power control application
# included in the x86-power-control repository.
OBMC_CONTROL_FMT = ""
