FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
             file://power_limit.json \
           "

FILES:${PN} += " \
                 ${datadir}/ipmi-providers/power_limit.json \
               "

do_install:append() {
    install -m 0644 -D ${UNPACKDIR}/power_limit.json \
        ${D}${datadir}/ipmi-providers/power_limit.json
}

do_install:append:mtjade() {
    # The Mt.Jade platform does not support power limit/DIMM setting, therefore,
    # those default configuration should be removed.
    echo "{}" > ${D}${datadir}/ipmi-providers/power_limit.json
}
