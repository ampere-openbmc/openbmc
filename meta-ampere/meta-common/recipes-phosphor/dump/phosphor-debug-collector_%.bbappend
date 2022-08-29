FILESEXTRAPATHS:prepend := "${THISDIR}/phosphor-debug-collector:"

SRC_URI += " \
            file://0001-Add-CPER-Log-and-Crashdump-support-in-FaultLog.patch \
            file://0002-Support-maximum-theshold-for-each-type-of-faultlog.patch \
            file://0003-Support-BERT-and-Diagnostic-type.patch \
            file://0004-Support-restore-FaultLog-entries-after-service-resta.patch \
            file://0005-Prevent-too-many-dump-is-captured-simultaneously.patch \
           "

EXTRA_OEMESON += " \
        -DMAX_TOTAL_FAULT_LOG_ENTRIES=100 \
        -DMAX_TOTAL_CPER_LOG_ENTRIES=10 \
        -DMAX_TOTAL_BERT_ENTRIES=4 \
        -DMAX_TOTAL_DIAGNOSTIC_ENTRIES=8 \
        -DMAX_TOTAL_CRASHDUMP_ENTRIES=12 \
        -Ddump_rotate_config=enabled \
        "
