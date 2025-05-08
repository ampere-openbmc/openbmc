FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:remove = " intelcpusensor ipmbsensor exitairtempsensor external mcutempsensor mctpreactor"
PACKAGECONFIG:append = " nvmesensor nvme-pec-checking "

PACKAGECONFIG[nvme-pec-checking] = "-Dnvme-pec-checking=true, -Dnvme-pec-checking=false"

SRC_URI += " \
            file://0001-Remove-throwing-exception-when-can-not-write-data-to.patch \
            file://0002-ADC-Match-InterfaceAdded-signal.patch \
            file://0003-Support-configuration-Max-Min-values-from-EM.patch \
            file://0004-adcsensor-support-PresenceGpio-option.patch \
            file://0005-psusensor-monitor-interfaceAdded-signal-for-CPU-obje.patch \
            file://0006-nvmesensor-Enale-PEC-checking-to-smbus-driver.patch \
"
