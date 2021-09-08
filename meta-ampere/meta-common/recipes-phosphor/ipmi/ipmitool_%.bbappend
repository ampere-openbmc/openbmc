
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:remove = " \
    file://0001-Fru-Fix-edit-field-not-checking-area-existence.patch \
"

SRC_URI += " \
            file://0001-update-the-wrote-FRU-s-size-based-on-data-in-binary-.patch \
            file://0002-support-editing-FRU-field-which-changes-the-size-of-.patch \
           "
