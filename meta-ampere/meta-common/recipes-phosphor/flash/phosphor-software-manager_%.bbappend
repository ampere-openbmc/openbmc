FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
             file://firmware_update.sh \
             file://turn_on_host_after_flash.sh \
             file://turn-on-the-host-after-flash@.service \
             file://0001-BMC-Updater-Support-update-on-BMC-Alternate-device.patch \
           "

PACKAGECONFIG:append = " flash_bios static-dual-image"

SYSTEMD_SERVICE:${PN}:updater += "${@bb.utils.contains('PACKAGECONFIG', 'flash_bios', 'turn-on-the-host-after-flash@.service', '', d)}"

FILES:${PN} += "${@bb.utils.contains('PACKAGECONFIG', 'flash_bios', '${systemd_unitdir}/system/turn-on-the-host-after-flash@.service', '', d)}"

RDEPENDS:${PN} += "bash flashrom"

do_install:append() {
    install -d ${D}/usr/sbin
    install -m 0755 ${UNPACKDIR}/firmware_update.sh ${D}/usr/sbin/firmware_update.sh
    install -m 0755 ${UNPACKDIR}/turn_on_host_after_flash.sh ${D}/usr/sbin/turn_on_host_after_flash.sh

    install -m 0644 ${UNPACKDIR}/turn-on-the-host-after-flash@.service ${D}${systemd_unitdir}/system/turn-on-the-host-after-flash@.service
}
