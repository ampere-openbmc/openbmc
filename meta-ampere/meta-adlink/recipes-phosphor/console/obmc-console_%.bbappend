FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

CONSOLE_CLIENT_SERVICE_FMT = "obmc-console-ssh@{0}.service"
CONSOLE_SERVER_CONF_FMT = "file://server.{0}.conf"
CONSOLE_CLIENT_CONF_FMT = "file://client.{0}.conf"

# Declare port spcific config files
OBMC_CONSOLE_TTYS = "ttyS0 ttyS1"
CONSOLE_CLIENT = "2200 2201"

SRC_URI += " \
             ${@compose_list(d, 'CONSOLE_SERVER_CONF_FMT', 'OBMC_CONSOLE_TTYS')} \
             ${@compose_list(d, 'CONSOLE_CLIENT_CONF_FMT', 'CONSOLE_CLIENT')} \
             file://obmc-console@.service \
           "

SYSTEMD_SERVICE:${PN}:remove = "obmc-console-ssh.socket"

SYSTEMD_SERVICE:${PN}:append = " \
                                  ${@compose_list(d, 'CONSOLE_CLIENT_SERVICE_FMT', 'CONSOLE_CLIENT')} \
                                "

FILES:${PN}:remove = "${systemd_system_unitdir}/obmc-console-ssh@.service.d/use-socket.conf"

PACKAGECONFIG:append = " concurrent-servers"

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/obmc-console@.service ${D}${systemd_system_unitdir}

    # Install the console client configurations
    install -m 0644 ${WORKDIR}/client.*.conf ${D}${sysconfdir}/${BPN}
}
