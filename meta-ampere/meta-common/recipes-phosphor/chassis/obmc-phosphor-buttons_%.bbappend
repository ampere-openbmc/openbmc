FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

EXTRA_OEMESON:append = "-Dlong-press-time-ms=5000"

SRC_URI += " \
            file://0001-button-handler-Add-button-event-log.patch \
            file://0002-buttons-support-power-button-whose-name-is-POWER_BUT.patch \
            file://0003-button-handler-correct-the-object-path-of-host-chass.patch \
           "
