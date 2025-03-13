EXTRA_OEMESON:append = " -DIFACES_PATH=${T}/yaml "

do_compile:prepend:class-target () {
	rm -rf ${T}/yaml
	mkdir -p ${T}/yaml/xyz/openbmc_project
	cp -r \
		${STAGING_DIR_TARGET}${yaml_dir}/xyz/openbmc_project/Inventory* \
		${STAGING_DIR_TARGET}${yaml_dir}/xyz/openbmc_project/State* \
		${T}/yaml/xyz/openbmc_project/

	# HACK: invalidate generated files
	# 
	# we wouldn't need those deletions if phosphor-inventory-manager kept
	# track of inputs correctly, e.g, by filling in the "input" field of
	# custom_target("generated.cpp") with paths to yaml files, so that meson knows to
	# rebuild the target when its inputs (the yamls) change
	rm -f ${B}/generated.cpp
	rm -f ${B}/gen_serialization.hpp
}
