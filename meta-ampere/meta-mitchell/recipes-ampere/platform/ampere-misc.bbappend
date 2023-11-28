FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"
FILESEXTRAPATHS:append := "${THISDIR}/${PN}/nmi-manager:"
FILESEXTRAPATHS:append := "${THISDIR}/${PN}/power-manager:"
FILESEXTRAPATHS:append := "${THISDIR}/${PN}/crash-capture-manager:"

PACKAGECONFIG += " nmi-manager crash-capture-manager"
DEPENDS += "ac03-nvparm"

SRC_URI += " \
             file://dbus_utils.sh \
             file://power_cap_dbus_utils.sh \
             file://power_cap_exceed_limit.sh \
             file://power_cap_drop_below_limit.sh \
             file://power_cap_monitor_oem_action.sh \
             file://nmi.service \
             file://power-cap-drops-below-limit.service \
             file://power-cap-exceeds-limit.service \
             file://power-cap-monitor-oem-action.service \
           "

SYSTEMD_SERVICE:${PN} += " power-cap-monitor-oem-action.service"

do_install:append () {
    install -d ${D}/${sbindir}

    install -m 0755 ${UNPACKDIR}/dbus_utils.sh ${D}/${sbindir}/dbus_utils.sh
    install -m 0755 ${UNPACKDIR}/power_cap_dbus_utils.sh ${D}/${sbindir}/power_cap_dbus_utils.sh
    install -m 0755 ${UNPACKDIR}/power_cap_exceed_limit.sh ${D}/${sbindir}/power_cap_exceed_limit.sh
    install -m 0755 ${UNPACKDIR}/power_cap_drop_below_limit.sh ${D}/${sbindir}/power_cap_drop_below_limit.sh
    install -m 0755 ${UNPACKDIR}/power_cap_monitor_oem_action.sh ${D}/${sbindir}/power_cap_monitor_oem_action.sh

    install -m 0644 ${UNPACKDIR}/nmi.service ${D}${systemd_unitdir}/system/nmi.service
    install -m 0644 ${UNPACKDIR}/power-cap-drops-below-limit.service \
                    ${D}${systemd_unitdir}/system/power-cap-drops-below-limit.service
    install -m 0644 ${UNPACKDIR}/power-cap-exceeds-limit.service \
                    ${D}${systemd_unitdir}/system/power-cap-exceeds-limit.service
    install -m 0644 ${UNPACKDIR}/power-cap-monitor-oem-action.service \
                    ${D}${systemd_unitdir}/system/power-cap-monitor-oem-action.service
}
