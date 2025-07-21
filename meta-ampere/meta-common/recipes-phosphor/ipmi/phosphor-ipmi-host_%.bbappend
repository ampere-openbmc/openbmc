FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

PACKAGECONFIG[dynamic-storages-only] = "-Ddynamic-storages-only=enabled, -Ddynamic-storages-only=disabled"
PACKAGECONFIG[redfish-host-interface] = "-Dredfish-host-interface=enabled, -Dredfish-host-interface=disabled"

RRECOMMENDS:${PN} += "ipmitool"
RDEPENDS:${PN} += "bash"

EXTRA_OEMESON:append = " -Dredfish-host-interface=enabled"

SRC_URI += "\
            file://0002-Response-thresholds-for-Get-SDR-command.patch \
            file://0003-ampere-dbus-sdr-support-static-FRU-s-ID-configuratio.patch \
            file://0004-dcmi-Support-fully-power-limit-setting-commands.patch \
            file://0005-dbus-sdr-sel-support-getting-sensor-number-from-stat.patch \
            file://0006-dbus-sdr-support-to-get-PLDM-sensor-EIDs.patch \
            file://0007-dcmi-Support-Set-Get-AssetTag-to-FRU.patch \
            file://0008-dbus-sdr-round-up-the-M-factor-of-sensor.patch \
            file://0009-dbus-sdr-replace-sort-with-stable_sort-function.patch \
            file://0010-dbus-sdr-correct-sensor-type-code-of-Power-sensors.patch \
            file://0011-dbus-sdr-remove-unused-boost-process-header.patch \
            file://0012-build-fixes-libdynamiccmds-build-options.patch \
            file://0013-user_channel-Move-the-D-Bus-defined-to-common-file.patch \
            file://0014-redfish_host_interface-Support-GetFingerPrint.patch \
            file://0015-user_channel-Support-setUserGroups-API.patch \
            file://0016-user_channel-Add-APIs-to-manage-None-IPMI-group-user.patch \
            file://0017-user_channel-Support-setUserIsBootStrapState-API.patch \
            file://0018-redfish_host_interface-Support-GetBootStrapAccount.patch \
            file://ampere-phosphor-softpoweroff \
            file://ampere.xyz.openbmc_project.Ipmi.Internal.SoftPowerOff.service \
           "

AMPERE_SOFTPOWEROFF_TMPL = "ampere.xyz.openbmc_project.Ipmi.Internal.SoftPowerOff.service"

do_install:append(){
    install -d ${D}${includedir}/phosphor-ipmi-host
    install -m 0644 -D ${S}/selutility.hpp ${D}${includedir}/phosphor-ipmi-host
    install -m 0755 ${UNPACKDIR}/ampere-phosphor-softpoweroff ${D}/${bindir}/phosphor-softpoweroff
    install -m 0644 ${UNPACKDIR}/${AMPERE_SOFTPOWEROFF_TMPL} ${D}${systemd_unitdir}/system/xyz.openbmc_project.Ipmi.Internal.SoftPowerOff.service
}
