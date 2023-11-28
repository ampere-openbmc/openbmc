SUMMARY = "Ampere Platform Environment Definitions"
DESCRIPTION = "Ampere Platform Environment Definitions"
PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SRC_URI = " \
           file://ampere_add_redfishevent.sh \
           file://ampere_spi_util.sh \
           file://ampere_power_control_lock.sh \
           file://utils-lib.sh \
          "

RDEPENDS:${PN} = "bash"

do_install() {
    install -d ${D}/usr/sbin
    install -m 0755 ${UNPACKDIR}/ampere_add_redfishevent.sh ${D}/${sbindir}/
    install -m 0755 ${UNPACKDIR}/ampere_spi_util.sh ${D}/${sbindir}/
    install -m 0755 ${UNPACKDIR}/ampere_power_control_lock.sh ${D}/${sbindir}/
    install -m 0755 ${UNPACKDIR}/utils-lib.sh ${D}/${sbindir}/
}
