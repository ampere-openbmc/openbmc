FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

PACKAGECONFIG[credential_bootstrapping_enable_after_reset] = "-Dcredential_bootstrapping_enable_after_reset=enabled, -Dcredential_bootstrapping_enable_after_reset=disabled"
EXTRA_OEMESON:append = " -Dcredential_bootstrapping_enable_after_reset=enabled"

SRC_URI += "file://0001-Prevent-non-admin-user-access-console.patch \
            file://0002-fix-show-manual-lock-after-failed-attempts.patch \
            file://0003-Host-CredentialBootstrapping-at-the-user-path.patch \
            file://0004-Remove-bootStrap-Accounts-on-the-service-reset-or-ho.patch \
           "
