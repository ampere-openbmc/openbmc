FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:remove = " intelcpusensor ipmbsensor exitairtempsensor external mcutempsensor mctpreactor"
PACKAGECONFIG:append = " nvmesensor"

SRC_URI += " \
            file://0001-Remove-throwing-exception-when-can-not-write-data.patch \
            file://0002-ADC-Match-InterfaceAdded-signal.patch \
            file://0003-Support-configuration-Max-Min-values-from-EM.patch \
            file://0004-adcsensor-support-PresenceGpio-option.patch \
            file://0005-psusensor-monitor-interfaceAdded-signal-for-CPU.patch \
           "
