FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://blacklist.json \
           "

do_install:append() {
     install -d ${D}${datadir}/${PN}/configurations
     find ${D}${datadir}/${PN}/configurations -maxdepth 1 -type f ! -name "mtjade*" -delete
     rm -rf ${D}${datadir}/${PN}/configurations/meta
     rm -rf ${D}${datadir}/${PN}/configurations/tyan

     install -d ${D}${datadir}/${PN}
     install -m 0444 ${UNPACKDIR}/blacklist.json ${D}${datadir}/${PN}
}
