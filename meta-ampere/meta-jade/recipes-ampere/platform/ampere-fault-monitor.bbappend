FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

RDEPENDS:${PN} = "bash"

SRC_URI += " \
            file://ampere_check_gpio_fault.sh \
           "

do_install:append() {
    install -d ${D}/${sbindir}
    install -m 755 ${UNPACKDIR}/ampere_check_gpio_fault.sh ${D}/${sbindir}/
}
