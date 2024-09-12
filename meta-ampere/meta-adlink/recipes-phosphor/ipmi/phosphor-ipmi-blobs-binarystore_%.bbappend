FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI:append = " file://config.json"
FILES:${PN}:append = " ${datadir}/binaryblob/config.json"

do_install:append() {
    install -d ${D}${datadir}/binaryblob/
    install ${WORKDIR}/config.json ${D}${datadir}/binaryblob/config.json
}
