SUMMARY = "Free and Open On-Chip Debugging, In-System Programming and Boundary-Scan Testing"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=599d2d1ee7fc84c0467b3d19801db870"
DEPENDS = "libusb-compat libftdi"
RDEPENDS:${PN} = "libusb1"

#Remote Git Repository
SRC_URI = "git://github.com/AmpereComputing/ampere-openocd.git;protocol=https;branch=release/4.4.1.1"
SRCREV = "3722638511ed72be5e0f6b8a22402da57022a246"
S = "${WORKDIR}/git"

inherit pkgconfig autotools-brokensep gettext

BBCLASSEXTEND += "native nativesdk"

do_configure[network] = "1"

do_configure() {
    ./bootstrap
    install -m 0755 ${STAGING_DATADIR_NATIVE}/gnu-config/config.guess ${S}/jimtcl/autosetup
    install -m 0755 ${STAGING_DATADIR_NATIVE}/gnu-config/config.sub ${S}/jimtcl/autosetup
    oe_runconf
}

do_install() {
    oe_runmake DESTDIR=${D} install
    if [ -e "${D}${infodir}" ]; then
      rm -Rf ${D}${infodir}
    fi
    if [ -e "${D}${mandir}" ]; then
      rm -Rf ${D}${mandir}
    fi
    if [ -e "${D}${bindir}/.debug" ]; then
      rm -Rf ${D}${bindir}/.debug
    fi
}

FILES:${PN} = " \
  ${datadir}/openocd/* \
  ${bindir}/openocd \
  "

PACKAGECONFIG = "jtag_driver"
PACKAGECONFIG[doxygen-html] = "--enable-doxygen-html,--disable-doxygen-html"
PACKAGECONFIG[doxygen-pdf] = "--enable-doxygen-pdf,--disable-doxygen-pdf"
PACKAGECONFIG[dummy] = "--enable-dummy,--disable-dummy"
PACKAGECONFIG[rshim] = "--enable-rshim,--disable-rshim"
PACKAGECONFIG[dmem] = "--enable-dmem,--disable-dmem"
PACKAGECONFIG[ftdi] = "--enable-ftdi,--disable-ftdi"
PACKAGECONFIG[stlink] = "--enable-stlink,--disable-stlink"
PACKAGECONFIG[ti-icdi] = "--enable-ti-icdi,--disable-ti-icdi"
PACKAGECONFIG[ulink] = "--enable-ulink,--disable-ulink"
PACKAGECONFIG[angie] = "--enable-angie,--disable-angie"
PACKAGECONFIG[usb-blaster-2] = "--enable-usb-blaster-2,--disable-usb-blaster-2"
PACKAGECONFIG[ft232r] = "--enable-ft232r,--disable-ft232r"
PACKAGECONFIG[vsllink] = "--enable-vsllink,--disable-vsllink"
PACKAGECONFIG[xds110] = "--enable-xds110,--disable-xds110"
PACKAGECONFIG[cmsis-dap-v2] = "--enable-cmsis-dap-v2,--disable-cmsis-dap-v2"
PACKAGECONFIG[osbdm] = "--enable-osbdm,--disable-osbdm"
PACKAGECONFIG[opendous] = "--enable-opendous,--disable-opendous"
PACKAGECONFIG[armjtagew] = "--enable-armjtagew,--disable-armjtagew"
PACKAGECONFIG[rlink] = "--enable-rlink,--disable-rlink"
PACKAGECONFIG[usbprog] = "--enable-usbprog,--disable-usbprog"
PACKAGECONFIG[esp-usb-jtag] = "--enable-esp-usb-jtag,--disable-esp-usb-jtag"
PACKAGECONFIG[cmsis-dap] = "--enable-cmsis-dap,--disable-cmsis-dap"
PACKAGECONFIG[nulink] = "--enable-nulink,--disable-nulink"
PACKAGECONFIG[kitprog] = "--enable-kitprog,--disable-kitprog"
PACKAGECONFIG[usb-blaster] = "--enable-usb-blaster,--disable-usb-blaster"
PACKAGECONFIG[presto] = "--enable-presto,--disable-presto"
PACKAGECONFIG[openjtag] = "--enable-openjtag,--disable-openjtag"
PACKAGECONFIG[buspirate] = "--enable-buspirate,--disable-buspirate"
PACKAGECONFIG[jlink] = "--enable-jlink,--disable-jlink"
PACKAGECONFIG[parport] = "--enable-parport,--disable-parport"
PACKAGECONFIG[parport-ppdev] = "--enable-parport-ppdev,--disable-parport-ppdev"
PACKAGECONFIG[parport-giveio] = "--enable-parport-giveio,--disable-parport-giveio"
PACKAGECONFIG[jtag_vpi] = "--enable-jtag_vpi,--disable-jtag_vpi"
PACKAGECONFIG[vdebug] = "--enable-vdebug,--disable-vdebug"
PACKAGECONFIG[jtag_dpi] = "--enable-jtag_dpi,--disable-jtag_dpi"
PACKAGECONFIG[jtag_driver] = "--enable-jtag_driver,--disable-jtag_driver"
PACKAGECONFIG[amtjtagaccel] = "--enable-amtjtagaccel,--disable-amtjtagaccel"
PACKAGECONFIG[bcm2835gpio] = "--enable-bcm2835gpio,--disable-bcm2835gpio"
PACKAGECONFIG[imx_gpio] = "--enable-imx_gpio,--disable-imx_gpio"
PACKAGECONFIG[am335xgpio] = "--enable-am335xgpio,--disable-am335xgpio"
PACKAGECONFIG[ep93xx] = "--enable-ep93xx,--disable-ep93xx"
PACKAGECONFIG[at91rm9200] = "--enable-at91rm9200,--disable-at91rm9200"
PACKAGECONFIG[gw16012] = "--enable-gw16012,--disable-gw16012"
PACKAGECONFIG[sysfsgpio] = "--enable-sysfsgpio,--disable-sysfsgpio"
PACKAGECONFIG[xlnx-pcie-xvc] = "--enable-xlnx-pcie-xvc,--disable-xlnx-pcie-xvc"
PACKAGECONFIG[remote-bitbang] = "--enable-remote-bitbang,--disable-remote-bitbang"
