FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
           file://0001-Support-flash-image-size-less-than-chip-size.patch \
           "

PACKAGECONFIG:remove = " pci usb ftdi"