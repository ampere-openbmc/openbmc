FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

PACKAGECONFIG:append = " json"

SRC_URI:append = " \
                  file://events.json \
                  file://fans.json \
                  file://groups.json \
                  file://zones.json \
                  file://monitor.json \
                  file://presence.json \
                  file://phosphor-fan-control@.service \
                  file://phosphor-fan-monitor@.service \
                  file://phosphor-fan-presence-tach@.service \
                 "

COMPAT_NAME = "com.ampere.Hardware.Chassis.Model.MtJefferson"

CONTROL_CONFIGS = "events.json fans.json zones.json groups.json"

do_install:append () {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/phosphor-fan-monitor@.service ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/phosphor-fan-control@.service ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/phosphor-fan-presence-tach@.service ${D}${systemd_system_unitdir}

    # datadir = /usr/share
    install -d ${D}${datadir}/phosphor-fan-presence/control/${COMPAT_NAME}
    install -d ${D}${datadir}/phosphor-fan-presence/monitor/${COMPAT_NAME}
    install -d ${D}${datadir}/phosphor-fan-presence/presence/${COMPAT_NAME}

    for CONTROL_CONFIG in ${CONTROL_CONFIGS}
    do
        install -m 0644 ${WORKDIR}/${CONTROL_CONFIG} \
            ${D}${datadir}/phosphor-fan-presence/control/${COMPAT_NAME}
    done

    install -m 0644 ${WORKDIR}/monitor.json \
        ${D}${datadir}/phosphor-fan-presence/monitor/${COMPAT_NAME}/config.json
    install -m 0644 ${WORKDIR}/presence.json \
        ${D}${datadir}/phosphor-fan-presence/presence/${COMPAT_NAME}/config.json
}
