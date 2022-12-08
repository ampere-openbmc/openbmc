FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-Add-Hostinterface-CredentialBootstrapping-interface.patch \
            file://0002-Support-HostInterface-privilege-role.patch \
            file://0003-Prevent-non-admin-user-access-console.patch \
           "
