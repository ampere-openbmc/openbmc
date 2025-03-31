FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://0001-Generate-UUID-if-not-exist-in-FRU.patch \
            file://0002-configuration-ampere-various-updates.patch \
            file://0003-configurations-remove-redundant-Backplane-Version.patch \
            file://0004-configurations-mtjefferson-update-PowerState-for-12V.patch \
            file://0005-configuration-mtjefferson-add-Riser-card.patch \
            file://0006-configurations-mtjade-update-Min-Max-values.patch \
            file://0007-configurations-mtmitchell-update-Min-Max-values.patch \
            file://0008-configurations-update-Backplane-s-configurations.patch \
           "

PACKAGECONFIG:append = " fru-device-resizefru"
PACKAGECONFIG[fru-device-resizefru] = "-Dfru-device-resizefru=true, -Dfru-device-resizefru=false"
