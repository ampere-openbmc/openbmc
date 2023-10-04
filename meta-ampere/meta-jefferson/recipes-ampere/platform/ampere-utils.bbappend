FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

INSANE_SKIP:${PN} = "already-stripped"

SRC_URI:append = " \
                  file://ampere_firmware_upgrade.sh \
                  file://ampere_flash_bios.sh \
                  file://ampere_power_util.sh \
                  file://ampere_fanctrl.sh \
                  file://ampere_firmware_version.sh \
                  file://ampere_scandump_mode.sh \
                 "

do_install:append() {
    install -d ${D}/usr/sbin
    install -m 0755 ${UNPACKDIR}/ampere_firmware_upgrade.sh ${D}/${sbindir}/
    install -m 0755 ${UNPACKDIR}/ampere_flash_bios.sh ${D}/${sbindir}/
    install -m 0755 ${UNPACKDIR}/ampere_power_util.sh ${D}/${sbindir}/
    install -m 0755 ${UNPACKDIR}/ampere_fanctrl.sh ${D}/${sbindir}/
    install -m 0755 ${UNPACKDIR}/ampere_firmware_version.sh ${D}/${sbindir}/
    install -m 0755 ${UNPACKDIR}/ampere_scandump_mode.sh ${D}/${sbindir}/
}
