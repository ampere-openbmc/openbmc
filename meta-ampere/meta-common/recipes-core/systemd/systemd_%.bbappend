FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://0001-timedate-Remove-RTC-sync-down-in-SetTime-method.patch"
