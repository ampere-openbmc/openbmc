SUMMARY = "Virtual Media Service"
DESCRIPTION = "Virtual Media Service"

SRC_URI = "git://github.com/Intel-BMC/virtual-media.git;branch=main;protocol=https"
SRCREV = "78fd799195824eb444a539bacc05ec4587205fd7"

S = "${WORKDIR}/git"

PV = "1.0+git${SRCPV}"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=e3fc50a88d0a364313df4b21ef20c29e"

SYSTEMD_SERVICE:${PN} += "xyz.openbmc_project.VirtualMedia.service"

FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
             file://0001-Fix-fail-to-Insert-and-Eject-media.patch \
             file://0002-Fix-build-error-with-boost-1.86.patch \
             file://virtual-media.json \
           "

DEPENDS = "udev boost nlohmann-json systemd sdbusplus"

RDEPENDS:${PN} += "nbd-client nbdkit"

inherit meson pkgconfig systemd

EXTRA_OEMESON:append = " \
    -Dlegacy-mode=enabled \
    -Dtests=disabled \
    "

FULL_OPTIMIZATION = "-Os -pipe -flto"

do_install:append() {
    install -m 0644 ${UNPACKDIR}/virtual-media.json ${D}${sysconfdir}
}
