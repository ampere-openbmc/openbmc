FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
                   file://yaml/ \
                 "

do_regenerate_meson() {
    cp -r ${UNPACKDIR}/yaml ${S}/
    cd ${S}/gen/
    SDBUSPP_GEN_MESON=${STAGING_BINDIR_NATIVE}/sdbus++-gen-meson ${S}/gen/regenerate-meson
    cd -
    sed -i 's/selected_subdirs = \[.*\]/selected_subdirs = \['\''com\/ampere'\'']/g' ${S}/meson.build
}
addtask regenerate_meson after do_patch before do_write_config
do_regenerate_meson[depends] = "${PYTHON_PN}-sdbus++-native:do_populate_sysroot"
do_regenerate_meson[deptask] = "do_populate_sysroot"
