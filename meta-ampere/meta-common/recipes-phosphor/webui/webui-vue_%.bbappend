FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"

SRC_URI += "\
            file://0001-Add-show-info-about-password-Ampere-policy.patch \
            file://0002-Update-Server-status-in-Server-power-operations-page.patch \
            file://0003-Change-to-display-1000-last-event-logs.patch \
            file://0004-Set-ApplyTime-to-Immediate.patch \
            file://0005-Parsing-string-arguments-for-Account-policy-settings.patch \
            file://0006-Fix-the-error-preventing-user-edits.patch \
            file://0007-Add-target-to-update-BIOS-host-firmware.patch \
            file://0008-Use-TaskService-to-manage-firmware-flash-completion.patch \
            file://0009-Preserve-selected-network-interface-across-reloads.patch \
           "
