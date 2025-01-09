FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://memoryLocationTable.json \
           "

do_install:append () {
    install -d ${D}${datadir}/${PN}
    install -m 0444 ${UNPACKDIR}/memoryLocationTable.json ${D}${datadir}/${PN}
}
