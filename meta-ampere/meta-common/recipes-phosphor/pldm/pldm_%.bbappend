FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

RDEPENDS:${PN} += "bash"

SRC_URI = "git://github.com/ampere-openbmc/pldm;protocol=https;branch=ampere \
           file://host_eid \
          "
SRCREV = "b5b98e3228000049d0576a9d5e1cb51b3c95d886"

SYSTEMD_SERVICE:${PN}:remove = " \
                                pldmSoftPowerOff.service \
                               "
SRC_URI:remove = "file://pldm-softpoweroff"

PACKAGECONFIG:append = " oem-ampere"

FULL_OPTIMIZATION:append = " -Os"

do_install:append() {
    install -d ${D}/${datadir}/pldm
    install ${UNPACKDIR}/host_eid ${D}/${datadir}/pldm/

    IBMPDR="${D}${datadir}/pldm/pdr/com.ibm*"
    rm -rf $IBMPDR
    LINK="${D}${systemd_unitdir}/obmc-host-shutdown@0.target.wants/pldmSoftPowerOff.service"
    rm -f $LINK
    LINK="${D}${systemd_unitdir}/obmc-host-warm-reboot@0.target.wants/pldmSoftPowerOff.service"
    rm -f $LINK
    rm -f ${D}${systemd_unitdir}/system/pldmSoftPowerOff.service
    rm -rf ${D}/${bindir}/pldm-softpoweroff
}
