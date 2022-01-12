FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:remove = " intelcpusensor ipmbsensor exitairtempsensor external mcutempsensor"
PACKAGECONFIG:append = " nvmesensor"

SRC_URI += " \
            file://0001-Remove-throwing-exception-when-can-not-write-data-to.patch \
            file://0002-adcsensor-Add-support-DevName-option.patch \
            file://0003-ADC-Match-InterfaceAdded-signal.patch \
            file://0004-Support-configuration-Max-Min-values-from-EM.patch \
            file://0005-adcsensor-support-PresenceGpio-option.patch \
            file://0006-psusensor-monitor-interfaceAdded-signal-for-CPU-obje.patch \
           "
