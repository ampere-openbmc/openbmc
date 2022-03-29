FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

EXTRA_OEMESON += " -Ddata_com_ampere=true"

SRC_URI:append = " \
                   file://0001-Add-HostInterface-dbus.patch \
                   file://0002-Add-Ampere-Crash-Capture-manager-interface.patch \
                 "
