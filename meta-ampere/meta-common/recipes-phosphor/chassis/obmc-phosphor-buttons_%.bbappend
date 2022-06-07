FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

EXTRA_OEMESON:append = "-Dlong-press-time-ms=5000"

SRC_URI += " \
            file://0001-button-handler-Add-button-event-log.patch \
           "
