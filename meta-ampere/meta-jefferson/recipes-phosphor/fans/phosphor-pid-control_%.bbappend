FILESEXTRAPATHS:prepend:= "${THISDIR}/${PN}:"

inherit obmc-phosphor-systemd

SRC_URI:append = " \
                  file://${BPN}.service \
                 "

PACKAGECONFIG:append = " handle-missing-object-paths "
PACKAGECONFIG[handle-missing-object-paths] = "-Dhandle-missing-object-paths=true,-Dhandle-missing-object-paths=false"

do_install:append() {
    install -m 644 ${UNPACKDIR}/${BPN}.service ${D}${systemd_system_unitdir}
}
