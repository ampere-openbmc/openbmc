EXTRA_OECONF += " --disable-logger "
PACKAGES_DYNAMIC = "^${PN}(?!.*(?<!logger)-native)-.*"
PACKAGES_DYNAMIC:class-native = "^${BPN}-.*(?<!logger)-native"

ALTERNATIVE:${PN}:remove = "logger"
ALTERNATIVE:${PN}-doc:remove = "logger.1"
