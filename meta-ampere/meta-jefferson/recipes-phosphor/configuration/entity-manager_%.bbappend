FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += " \
            file://blacklist.json \
           "

do_install:append() {
    find ${D}${datadir}/${PN}/configurations -maxdepth 1 -type f ! -name "mtjefferson*" -delete

    install -d ${D}${datadir}/${PN}
    install -m 0444 ${UNPACKDIR}/blacklist.json ${D}${datadir}/${PN}
    install -d ${D}${datadir}/${PN}/configurations
}
