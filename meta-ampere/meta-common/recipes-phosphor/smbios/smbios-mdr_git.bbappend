PACKAGECONFIG:append = " smbios-ipmi-blob"
FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

EXTRA_OEMESON:append = " \
     -Dfirmware-inventory-dbus=enabled \
     -Dexpose-firmware-component-name=enabled \
     "


SRC_URI:append = " \
                  file://0001-Expose-the-SMBIOS-Type-128-PCIe-Device-information.patch \
                  file://0002-Expose-the-SMBIOS-Type-130-Storage-Device-Function-i.patch \
                  file://0003-Expose-the-SMBIOS-Type-131-Network-Device-Function-i.patch \
                  file://0004-Expose-the-SMBIOS-Type-129-CXL-Function-information.patch \
                  file://0005-PCIeDevice-create-association-to-Chassis-motherboard.patch \
                  file://0006-Change-PDI-to-Software.Asset.patch \
                  file://0007-Remove-trailing-whitespace-from-ReleaseDate-field.patch \
                 "
