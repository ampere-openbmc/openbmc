FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

EXTRA_OEMESON:append = " \
     -Dhttp-body-limit=65 \
     -Dadditional-bind-to-device="usb0" \
     -Dadditional-ports="440" \
"

PACKAGECONFIG:append = " \
     redfish-bmc-journal \
"

PACKAGECONFIG:remove = " \
     redfish-allow-deprecated-power-thermal \
"

SRC_URI += " \
            file://0001-ampere-support-BootProgress-OemLastState.patch \
            file://0002-Support-Redfish-Hostinterface-schema.patch \
            file://0003-ampere-prevent-the-Operator-user-to-flash-the-firmwa.patch \
            file://0004-chassis-Methods-to-PhysicalSecurity-s-properties.patch \
            file://0005-Support-remove-user-s-web-session.patch \
            file://0006-ampere-enable-vm-nbdproxy-for-Redfish-Virtual-Media.patch \
            file://0007-Fix-for-Redfish-URI-Sensors-Chassis-Baseboard.patch \
            file://0008-LogService-Add-CPER-logs-crashdumps-to-FaultLog.patch \
            file://0009-LogService-Support-download-FaultLog-data-via-Additi.patch \
            file://0010-update-service-get-ApplyTime-from-Dbus.patch \
            file://0011-Improve-IPv4-default-gateway-removal.patch \
            file://0012-Support-to-show-PCIe-Device-properties.patch \
            file://0013-Support-to-show-PCIe-Function-properties.patch \
            file://0014-Support-to-show-PCIe-Storage-Function.patch \
            file://0015-Support-NetworkAdapter-and-NetworkDeviceFunction-sch.patch \
            file://0016-Support-to-show-more-options-in-Device-Type-and-Medi.patch \
            file://0017-Property-addition-under-FirmwareInventory.patch \
            file://0018-update-the-association-names-of-PCIe-inventory.patch \
            file://ampere-registries.json \
           "
do_compile[network] = "1"
DEPENDS += "python3-requests-native jq-native"

SYSTEMD_SERVICE:${PN} += "bmcweb_440.socket"

do_compile:prepend() {
    jq -s '.[0] * .[1]' ${UNPACKDIR}/ampere-registries.json ${S}/redfish-core/include/registries/openbmc.json > ${S}/redfish-core/include/registries/openbmc_test.json
    mv ${S}/redfish-core/include/registries/openbmc_test.json ${S}/redfish-core/include/registries/openbmc.json
    ${S}/scripts/parse_registries.py
}