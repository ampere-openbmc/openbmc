FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
            file://0001-Generate-UUID-if-not-exist-in-FRU.patch \
            file://0002-configuration-ampere-various-updates.patch \
            file://0003-mtjeffeson-correct-the-thresholds-EntityID-of-sensor.patch \
           "

TARGET_LDFLAGS += "-luuid"

PACKAGECONFIG:append = " fru-device-resizefru"
PACKAGECONFIG[fru-device-resizefru] = "-Dfru-device-resizefru=true, -Dfru-device-resizefru=false"
