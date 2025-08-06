FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG:remove = " intelcpusensor ipmbsensor exitairtempsensor external mcutempsensor mctpreactor"
PACKAGECONFIG:append = " nvmesensor nvme-pec-checking "

PACKAGECONFIG[nvme-pec-checking] = "-Dnvme-pec-checking=true, -Dnvme-pec-checking=false"

inherit obmc-phosphor-systemd

SRC_URI += " \
            file://0001-Remove-throwing-exception-when-can-not-write-data-to.patch \
            file://0002-ADC-Match-InterfaceAdded-signal.patch \
            file://0003-Support-configuration-Max-Min-values-from-EM.patch \
            file://0004-adcsensor-support-PresenceGpio-option.patch \
            file://0005-psusensor-monitor-interfaceAdded-signal-for-CPU-obje.patch \
            file://0006-nvmesensor-Enale-PEC-checking-to-smbus-driver.patch \
            file://0007-intrusionsensor-Initial-value-read-for-GPIO-type.patch \
            file://0008-intrusionsensor-Changes-to-sensor-object-path.patch \
            file://0009-intrusionsensor-Add-association-with-chassis.patch \
            file://adcsensor.service-override.conf \
           "

SYSTEMD_OVERRIDE:${PN}:append = "adcsensor.service-override.conf:xyz.openbmc_project.adcsensor.service.d/adcsensor.service-override.conf"
