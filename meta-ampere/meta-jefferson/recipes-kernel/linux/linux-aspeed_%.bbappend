FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

FIT_UBOOT_ENV = "boot.cmd"

SRC_URI += " \
            file://ampere.cfg \
            file://boot.cmd \
           "
