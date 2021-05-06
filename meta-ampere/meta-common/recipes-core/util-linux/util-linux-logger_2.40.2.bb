SUMMARY = "Enter messages into the system log"
HOMEPAGE = "https://en.wikipedia.org/wiki/Util-linux"

inherit autotools gettext manpages pkgconfig systemd update-alternatives python3-dir bash-completion ptest gtk-doc

LICENSE = "BSD-4-Clause"
LIC_FILES_CHKSUM = "file://Documentation/licenses/COPYING.BSD-4-Clause-UC;md5=263860f8968d8bafa5392cab74285262"

MAJOR_VERSION = "${@'.'.join(d.getVar('PV').split('.')[0:2])}"
SRC_URI = "${KERNELORG_MIRROR}/linux/utils/util-linux/v${MAJOR_VERSION}/util-linux-${PV}.tar.xz"
SRC_URI[sha256sum] = "d78b37a66f5922d70edf3bdfb01a6b33d34ed3c3cafd6628203b2a2b67c8e8b3"

S = "${WORKDIR}/util-linux-${PV}"

EXTRA_OECONF = "--disable-all-programs --enable-logger"

PACKAGECONFIG = " systemd "
PACKAGECONFIG[systemd] = "--with-systemd --with-systemdsystemunitdir=${systemd_system_unitdir}, --without-systemd --without-systemdsystemunitdir,systemd"

do_install:append () {
    rm -rf ${D}${sbindir} ${D}${libdir}/systemd ${D}${libdir}/tmpfiles.d
}

ALTERNATIVE_PRIORITY = "80"
ALTERNATIVE:${PN} = "logger"
ALTERNATIVE:${PN}-doc = "logger.1"
ALTERNATIVE_LINK_NAME[logger] = "${bindir}/logger"
ALTERNATIVE_LINK_NAME[logger.1] = "${mandir}/man1/logger.1"
