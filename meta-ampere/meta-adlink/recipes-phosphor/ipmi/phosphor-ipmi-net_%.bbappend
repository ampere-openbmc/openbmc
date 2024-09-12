DEFAULT_RMCPP_IFACE = "eth0"

ALT_RMCPP_IFACE = "usb0"
SYSTEMD_SERVICE:${PN} += " \
        ${PN}@${ALT_RMCPP_IFACE}.service \
        ${PN}@${ALT_RMCPP_IFACE}.socket \
        "
