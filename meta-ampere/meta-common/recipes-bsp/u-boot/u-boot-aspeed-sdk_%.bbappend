FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://0001-spi-nor-check-4b-opcode-support.patch \
            file://0002-cmd-fru-Add-support-for-FRU-commands.patch \
            file://0003-cmd-fru-add-product-chassis-and-multirecord-area.patch \
            file://0004-cmd-fru-support-fru-get-command.patch \
           "
