FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += " \
file://0001-Add-extern-declaration-for-getNewRecordId.patch \
"

PACKAGECONFIG:append = " log-threshold log-alarm"
