FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
                file://ampere_power_on_failure_check.sh \
                file://ampere-host-on-host-check-override.conf \
                file://ampere-bert-power-handle.service \
                file://ampere-bert-power-handle.sh \
                file://obmc-power-start-override.conf \
           "

FILES:${PN} += " \
                 ${systemd_system_unitdir}/ampere-host-on-host-check@0.service.d \
                 ${systemd_system_unitdir}/ampere-bert-power-handle.service \
                 ${systemd_system_unitdir}/obmc-power-start@0.service.d \
               "
AMPERE_BERT_TMPL = "ampere-bert-power-handle.service"
AMPERE_BERT_INSTMPL = "ampere-bert-power-handle.service"
AMPERE_BERT_TGTFMT = "obmc-host-stop@{0}.target"
AMPERE_BERT_FMT = "../${AMPERE_BERT_TMPL}:${AMPERE_BERT_TGTFMT}.requires/${AMPERE_BERT_INSTMPL}"
SYSTEMD_LINK:${PN} += "${@compose_list_zip(d, 'AMPERE_BERT_FMT', 'OBMC_HOST_INSTANCES')}"
SYSTEMD_SERVICE:${PN} += "${AMPERE_BERT_TMPL}"

do_install:append() {
     install -m 0755 ${UNPACKDIR}/ampere_power_on_failure_check.sh ${D}/${sbindir}/
     install -m 0755 ${UNPACKDIR}/ampere-bert-power-handle.sh ${D}/${sbindir}/

     install -d ${D}${systemd_system_unitdir}/ampere-host-on-host-check@0.service.d
     install -m 644 ${UNPACKDIR}/ampere-host-on-host-check-override.conf \
        ${D}${systemd_system_unitdir}/ampere-host-on-host-check@0.service.d

     install -d ${D}${systemd_system_unitdir}/obmc-power-start@0.service.d
     install -m 644 ${UNPACKDIR}/obmc-power-start-override.conf \
        ${D}${systemd_system_unitdir}/obmc-power-start@0.service.d
}
