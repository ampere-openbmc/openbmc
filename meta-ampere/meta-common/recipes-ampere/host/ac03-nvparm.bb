SUMMARY = "Ampere Computing NVP Management Tool"
DESCRIPTION = "Ampere Computing NVP Management Tool"
PR = "r1"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

inherit pkgconfig

RDEPENDS:${PN} += "bash"
SYSTEMD_PACKAGES = "${PN}"

SRC_URI = "git://github.com/AmpereComputing/NVP-Management-Tool.git;protocol=https;branch=main"
SRCREV = "1fedb82076120f6d547a644eea03e223c1cf1cfb"

S = "${WORKDIR}/git"

INSANE_SKIP:${PN} += "already-stripped"
INSANE_SKIP:${PN} += "ldflags"

do_configure[network] =  "1"
do_compile[network] = "1"

EXTRA_OECMAKE = " \
                -DFETCHCONTENT_FULLY_DISCONNECTED=OFF \
                "
do_configure:prepend() {
  cd ${WORKDIR}/git
  git submodule update --init --recursive
}

do_compile() {
oe_runmake -C ${S}/lib/libspinorfs 'CROSS_COMPILE=arm-openbmc-linux-gnueabi-' 'SYSROOT=${WORKDIR}/recipe-sysroot'
oe_runmake -C ${S}/src 'CROSS_COMPILE=arm-openbmc-linux-gnueabi-' 'SYSROOT=${WORKDIR}/recipe-sysroot'
}

do_install() {
    install -d ${D}/usr/sbin
    install -d ${D}/usr/lib
    install -d ${D}/usr/include
    install -m 0755 ${S}/src/nvparm ${D}/${sbindir}/
    install -m 0755 ${S}/lib/libspinorfs/libspinorfs.a ${D}/${libdir}/
    install -m 0755 ${S}/include/spinorfs.h ${D}/usr/include
}
