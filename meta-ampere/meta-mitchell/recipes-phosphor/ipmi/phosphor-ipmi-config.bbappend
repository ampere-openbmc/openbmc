FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " file://fru_id.json"

FILES:${PN} += " ${datadir}/ipmi-providers/fru_id.json"

do_install:append() {
    install -m 0644 -D ${UNPACKDIR}/fru_id.json \
        ${D}${datadir}/ipmi-providers/fru_id.json
}
