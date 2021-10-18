SUMMARY = "Jim Tcl, a small implementation of the Tcl programming language."
LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d69300147248518155ea330e78019033"
SECTION = "libs"

SRC_URI = "git://github.com/msteveb/jimtcl.git;protocol=https;branch=master"
SRCREV = "36d2288d248f218dd9c913cd243e86455cce8c74"

PV = "1.0+git${SRCPV}"
S = "${WORKDIR}/git"

inherit pkgconfig autotools autotools-brokensep gettext

BBCLASSEXTEND += "native nativesdk"

do_configure() {
    ./configure \
        --build=${BUILD_SYS} \
        --host=${TARGET_SYS} \
        --prefix=${prefix} \
        --docdir=${docdir} \
        --shared
}

do_compile() {
    oe_runmake DESTDIR=${D}
}

do_install() {
    oe_runmake DESTDIR=${D} install
    if [ -e "${D}${bindir}/build-jim-ext" ]; then
        rm -Rf ${D}${bindir}/build-jim-ext
    fi
    if [ -e "${D}${libdir}/jim" ]; then
        rm -Rf ${D}${libdir}/jim
    fi
}

PACKAGE_BEFORE_PN = " ${PN}-bin "
