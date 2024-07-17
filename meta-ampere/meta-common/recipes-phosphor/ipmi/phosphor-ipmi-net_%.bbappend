FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

PACKAGECONFIG:remove = "rmcp-ping"

SRC_URI += "\
             file://0001-sol-change-to-use-async_connect-method-to-prevent-bl.patch \
           "
