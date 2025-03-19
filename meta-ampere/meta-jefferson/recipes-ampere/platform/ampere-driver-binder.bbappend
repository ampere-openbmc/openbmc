FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
             file://ampere-power-on-driver-binder.conf \
           "

SYSTEMD_OVERRIDE:${PN}:append = "ampere-power-on-driver-binder.conf:ampere-power-on-driver-binder@.service.d/ampere-power-on-driver-binder.conf"
