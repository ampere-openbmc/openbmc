FILESEXTRAPATHS:append := "${THISDIR}/${PN}/altra-host-error-monitor:"

PACKAGECONFIG += " altra-host-error-monitor ac01-nvparm"

SRC_URI += " file://platform-config.json"

do_install:append() {
    install -d ${D}${datadir}/altra-host-error-monitor
    install -m 0644 -D ${UNPACKDIR}/platform-config.json \
        ${D}${datadir}/altra-host-error-monitor/config.json
}
