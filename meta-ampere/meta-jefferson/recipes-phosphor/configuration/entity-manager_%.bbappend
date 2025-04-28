FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
            file://blacklist.json \
            file://0004-configurations-remove-redundant-Backplane-Version.patch \
            file://0005-configurations-mtjefferson-update-PowerState-for-12V.patch \
           "

do_install:append() {
    find ${D}${datadir}/${PN}/configurations -maxdepth 1 -type f ! -name "mtjefferson*" -delete

    install -d ${D}${datadir}/${PN}
    install -m 0444 ${UNPACKDIR}/blacklist.json ${D}${datadir}/${PN}
    install -d ${D}${datadir}/${PN}/configurations
}
