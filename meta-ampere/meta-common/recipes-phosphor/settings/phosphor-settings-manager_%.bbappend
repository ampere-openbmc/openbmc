FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI:append = " \
                    file://ampere_settings.override.yml \
                    file://ampere_settings.remove.yml \
                 "
