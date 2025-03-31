FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
            file://blacklist.json \
            file://0001-configurations-mtjefferson-add-PCIe-NIC-temperature.patch \
            file://0002-configurations-mtjefferson-update-Stepwise_PCIeNIC_M.patch \
            file://0003-update-PowerState-for-S0_EXT_VREF.patch \
           "

do_install:append() {
    find ${D}${datadir}/${PN}/configurations -maxdepth 1 -type f ! -name "mtjefferson*" -delete

    install -d ${D}${datadir}/${PN}
    install -m 0444 ${UNPACKDIR}/blacklist.json ${D}${datadir}/${PN}
    install -d ${D}${datadir}/${PN}/configurations
}
