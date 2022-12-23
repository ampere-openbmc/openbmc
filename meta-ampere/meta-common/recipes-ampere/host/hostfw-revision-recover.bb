SUMMARY = "Phosphor OpenBMC Recover Host Firmware Revision Service"
DESCRIPTION = "Phosphor OpenBMC Recover Host Firmware Revision Daemon"

PR = "r1"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

S = "${WORKDIR}/sources"
UNPACKDIR = "${S}"

inherit systemd
inherit obmc-phosphor-systemd

DEPENDS += "systemd"
RDEPENDS:${PN} += "libsystemd"
RDEPENDS:${PN} += "bash"

SRC_URI = " \
           file://ampere_hostfw_revision_recover.sh \
           file://hostfw-revision-recover.service \
          "

SYSTEMD_PACKAGES = "${PN}"

SYSTEMD_SERVICE:${PN} += "hostfw-revision-recover.service"

do_install () {
    install -d ${D}${sbindir}
    install -m 0755 ${UNPACKDIR}/ampere_hostfw_revision_recover.sh ${D}${sbindir}/
}
