FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

RDEPENDS:${PN} += "bash"

SRC_URI:append = " \
                  file://mctp-local.service \
                  file://mctpd.conf \
                 "
SRCREV = "9986862f88fd6e6ca75e2a29236cf332d640e600"

SYSTEMD_SERVICE:${PN} += "mctp-local.service"

EXTRA_OEMESON:append = " \
                        -Dtests=false \
                        -Dunsafe-writable-connectivity=true \
                       "

do_install:append() {
    install -d ${D}/etc/
    install -m 0644 ${UNPACKDIR}/mctp-local.service ${D}${systemd_system_unitdir}/
    install -m 0644 ${UNPACKDIR}/mctpd.conf ${D}/etc/mctpd.conf
}

