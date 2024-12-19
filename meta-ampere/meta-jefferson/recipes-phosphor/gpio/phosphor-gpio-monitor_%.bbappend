FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

RDEPENDS:${PN}-monitor += "bash"
RDEPENDS:${PN} = "bash"

SRC_URI += " \
            file://phosphor-multi-gpio-monitor.json \
            file://phosphor-multi-gpio-presence.json \
            file://ampere_sys_auth_failure.sh \
           "

SYSTEMD_SERVICE:${PN}-monitor += " \
                                  ampere_sys_auth_failure@.service \
                                 "

FILES:${PN}-monitor += " \
                        ${datadir}/${PN}/phosphor-multi-gpio-monitor.json \
                        /usr/sbin/ampere_sys_auth_failure.sh \
                       "

FILES:${PN}-presence += " \
                         ${datadir}/${PN}/phosphor-multi-gpio-presence.json \
                        "

do_install:append() {
    install -d ${D}${bindir}
    install -m 0644 ${UNPACKDIR}/phosphor-multi-gpio-monitor.json ${D}${datadir}/${PN}/
    install -m 0644 ${UNPACKDIR}/phosphor-multi-gpio-presence.json ${D}${datadir}/${PN}/

    install -d ${D}${sbindir}
    install -m 0755 ${UNPACKDIR}/ampere_sys_auth_failure.sh ${D}/${sbindir}/
}
