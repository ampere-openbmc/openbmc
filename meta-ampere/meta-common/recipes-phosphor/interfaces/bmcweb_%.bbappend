FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

EXTRA_OEMESON:append = " \
     -Dredfish-bmc-journal=enabled \
     -Dhttp-body-limit=65 \
     -Dredfish-dump-log=enabled \
     -Dredfish-allow-deprecated-power-thermal=disabled \
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
            file://0011-managers-pid-fan-Ignore-AccumulateSetPoint.patch \
            file://0012-Improve-IPv4-default-gateway-removal.patch \
            file://0013-Support-to-show-PCIe-Device-properties.patch \
            file://0014-Support-to-show-PCIe-Function-properties.patch \
            file://0015-Support-to-link-from-PCIeFunction-to-Drives.patch \
            file://0016-Support-to-show-PCIe-Storage-Function.patch \
            file://0017-Support-NetworkAdapter-schema.patch \
            file://0018-Support-NetworkDeviceFunction-schema.patch \
            file://0019-Support-to-show-more-options-in-Device-Type-and-Medi.patch \
            file://0020-Support-link-to-Network-Device-Function.patch \
            file://0021-Property-addition-under-FirmwareInventory.patch \
            file://0022-PCIe-Correct-the-method-to-detect-instance-of-entiti.patch \
            file://0023-Replace-getting-endpoints-property-with-getAssociate.patch \
            file://0024-update-the-association-names-of-PCIe-inventory.patch \
            file://ampere-registries.json \
           "
do_compile[network] = "1"
DEPENDS +="python3-requests-native jq-native"

do_compile:prepend() {
    jq -s '.[0] * .[1]' ${UNPACKDIR}/ampere-registries.json ${S}/redfish-core/include/registries/openbmc.json > ${S}/redfish-core/include/registries/openbmc_test.json
    mv ${S}/redfish-core/include/registries/openbmc_test.json ${S}/redfish-core/include/registries/openbmc.json
    ${S}/scripts/parse_registries.py
}
