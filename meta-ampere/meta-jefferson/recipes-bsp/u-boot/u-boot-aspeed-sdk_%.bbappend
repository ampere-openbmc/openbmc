FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://0001-ARM-dts-aspeed-ampere-Enable-DisplayPort-driver.patch \
            file://ampere.cfg \
           "
