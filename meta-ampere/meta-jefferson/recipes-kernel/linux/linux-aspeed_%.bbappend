FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

UBOOT_ENV_SUFFIX = "cmd"
UBOOT_ENV = "boot"
UBOOT_ENV_BINARY = "${UBOOT_ENV}.${UBOOT_ENV_SUFFIX}"

SRC_URI += " \
            file://ampere.cfg \
            file://boot.cmd \
           "

do_install:append () {
    if [ -n "${UBOOT_ENV}" ]
    then
        install -d ${STAGING_DIR_HOST}/boot
        cp ${UNPACKDIR}/${UBOOT_ENV_BINARY} ${STAGING_DIR_HOST}/boot/
    fi
}
