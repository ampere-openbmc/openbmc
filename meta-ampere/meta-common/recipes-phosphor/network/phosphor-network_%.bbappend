FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

PACKAGECONFIG:append = " sync-mac"
EXTRA_OEMESON:append = " -Dforce-sync-mac=false"

SRC_URI:append = " file://60-phosphor-networkd-default.network.in \
                   file://0001-Fix-mismatch-speed-data-type.patch \
                   file://0002-ethernet_interface-Read-the-DHCPv6client-from-defaul.patch \
                 "

do_configure:prepend () {
    cp ${UNPACKDIR}/60-phosphor-networkd-default.network.in ${S}/60-phosphor-networkd-default.network.in
}
