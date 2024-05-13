FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:append = " host-gpio"

SRC_URI += " \
              file://ampere-phosphor-reboot-host@.service \
              file://0001-Limit-power-actions-when-the-host-is-off.patch \
              file://0002-Prevent-services-enter-failed-state-while-restarting.patch \
              file://ampere_phosphor-service-monitor-default.json \
           "

EXTRA_OEMESON:append = " \
                         -Dboot-count-max-allowed=1 \
                       "

FILES:${PN} += "${systemd_system_unitdir}/*"

do_install:append() {
    install -m 0644 ${UNPACKDIR}/ampere-phosphor-reboot-host@.service ${D}${systemd_unitdir}/system/phosphor-reboot-host@.service

    install -d ${D}${sysconfdir}/phosphor-systemd-target-monitor
    install -m 0644 ${UNPACKDIR}/ampere_phosphor-service-monitor-default.json \
        ${D}${sysconfdir}/phosphor-systemd-target-monitor/phosphor-service-monitor-default.json
}
