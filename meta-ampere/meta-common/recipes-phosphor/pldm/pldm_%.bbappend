FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

RDEPENDS:${PN} += "bash"

SRC_URI = "git://github.com/ampere-openbmc/pldm;protocol=https;branch=ampere \
           file://host_eid \
          "
SRCREV = "d94a3f711fb8f2ce76871d9bc72aa6a5d491ae3f"

SYSTEMD_SERVICE:${PN}:remove = " \
                                pldmSoftPowerOff.service \
                               "
SRC_URI:remove = "file://pldm-softpoweroff"

PACKAGECONFIG:append = " oem-ampere"

FULL_OPTIMIZATION:append = " -Os"

do_install:append() {
    install -d ${D}/${datadir}/pldm
    install ${UNPACKDIR}/host_eid ${D}/${datadir}/pldm/

    IBMPDR="${D}${datadir}/pldm/pdr"
    rm -rf $IBMPDR
    LINK="${D}${systemd_unitdir}/obmc-host-shutdown@0.target.wants/pldmSoftPowerOff.service"
    rm -f $LINK
    LINK="${D}${systemd_unitdir}/obmc-host-warm-reboot@0.target.wants/pldmSoftPowerOff.service"
    rm -f $LINK
    rm -f ${D}${systemd_unitdir}/system/pldmSoftPowerOff.service
    rm -rf ${D}/${bindir}/pldm-softpoweroff
}
