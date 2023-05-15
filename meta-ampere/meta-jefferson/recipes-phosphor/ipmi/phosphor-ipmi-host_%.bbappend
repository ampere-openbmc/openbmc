FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

PACKAGECONFIG:append = " dynamic-sensors-static-fru"
PACKAGECONFIG[dynamic-sensors-static-fru] = "-Ddynamic-sensors-static-fru=enabled,-Ddynamic-sensors-static-fru=disabled"

PACKAGECONFIG:append = " dynamic-sensors"
HOSTIPMI_PROVIDER_LIBRARY += "libdynamiccmds.so"
