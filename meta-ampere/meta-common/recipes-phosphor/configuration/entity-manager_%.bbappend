FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://0001-Generate-UUID-if-not-exist-in-FRU.patch \
            file://0002-configuration-ampere-various-updates.patch \
            file://0003-configurations-mtjade-update-Min-Max-values.patch \
            file://0004-configurations-mtmitchell-update-Min-Max-values.patch \
           "

PACKAGECONFIG:append = " fru-device-resizefru"
PACKAGECONFIG[fru-device-resizefru] = "-Dfru-device-resizefru=true, -Dfru-device-resizefru=false"
