FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://0001-spi-nor-check-4b-opcode-support.patch \
           "
