FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
            file://dbus_to_terminus_effecter.json \
            file://ampere_pldm_effecter_trigger.sh \
           "

do_install:append() {
    install -d ${D}/${datadir}/pldm
    install ${UNPACKDIR}/dbus_to_terminus_effecter.json ${D}/${datadir}/pldm/host/

    install -d ${D}/usr/sbin
    install -m 0755 ${UNPACKDIR}/ampere_pldm_effecter_trigger.sh ${D}/${sbindir}/
}
