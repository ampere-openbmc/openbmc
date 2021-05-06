EXTRA_OECONF += " --disable-logger "
PACKAGES_DYNAMIC = "^${PN}-.*(?<!logger)$"

ALTERNATIVE:${PN}:remove = "logger"
ALTERNATIVE:${PN}-doc:remove = "logger.1"
