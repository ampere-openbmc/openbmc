FILESEXTRAPATHS_append_mtjade := "${THISDIR}/${PN}:"

DEPENDS_append_mtjade = " mtjade-yaml-config"

RRECOMMENDS_${PN} += "ipmitool"

EXTRA_OECONF_mtjade = " \
    SENSOR_YAML_GEN=${STAGING_DIR_HOST}${datadir}/mtjade-yaml-config/ipmi-sensors-${MACHINE}.yaml \
    FRU_YAML_GEN=${STAGING_DIR_HOST}${datadir}/mtjade-yaml-config/ipmi-fru-read.yaml \
    "

SRC_URI += "file://0001-mtjade-FRU-Updated-the-phosphor-host-ipmid-to-handle.patch \
            file://0002-Implement-the-set-get-system-boot-option-parameters.patch \
            "

do_install_append_mtjade(){
    install -d ${D}${includedir}/phosphor-ipmi-host
    install -m 0644 -D ${S}/sensorhandler.hpp ${D}${includedir}/phosphor-ipmi-host
    install -m 0644 -D ${S}/selutility.hpp ${D}${includedir}/phosphor-ipmi-host
}