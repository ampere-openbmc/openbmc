FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:remove = "run-apr-on-software-reset"
PACKAGECONFIG:append = " host-gpio check-fwupdate-before-do-transition"

SRC_URI += " \
              file://ampere-phosphor-reboot-host@.service \
              file://0001-Limit-power-actions-when-the-host-is-off.patch \
              file://0002-Prevent-services-enter-failed-state-while-restarting.patch \
	   "

EXTRA_OEMESON:append = " \
                         -Dboot-count-max-allowed=1 \
                       "

FILES:${PN} += "${systemd_system_unitdir}/*"

do_install:append() {
    install -m 0644 ${UNPACKDIR}/ampere-phosphor-reboot-host@.service ${D}${systemd_unitdir}/system/phosphor-reboot-host@.service
}
