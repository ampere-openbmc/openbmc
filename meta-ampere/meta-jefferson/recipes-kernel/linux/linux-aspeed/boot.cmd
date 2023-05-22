## DESCRIPTION: U-boot boot script
## AUTHOR: Chanh Nguyen

#====================Save default environment==================================
# Save default environment to u-boot-env once the u-boot-env partition is empty
# The u-boot-env partition offset is 0xe0000 and length is 0x1a0

sf probe

# Save The u-boot-env partition to temp memory (0x83000000)
sf read 0x83000000 0xe0000 0x1a0

# Prepare temp memory (0x83000300) for comparison
mw.b 0x83000300 0xFF 0x1a0

if cmp.b 0x83000000 0x83000300 0x1a0;
then
	echo "The u-boot-env partition is empty - save the default env"
	saveenv
else
	echo "The u-boot-env partition is NOT empty"
fi

#======================Capture HPM FRU==================================
# Probe I2C port which include the HPM FRU
i2c dev 4

# Set the internal pointer register address to first address
i2c mw 0x50 0x0000.2 0x01 1

# Read HPM FRU content ( Addr 0x50, offset 0x0, length 0x200) to
# temp memory (0x83000000)
i2c read 0x50 0x00 0x200 0x83000000

# Capture the FRU table present at address 0x83000000
fru capture 0x83000000

#======================AC power case checking==================================
# Check BMC reset cause by the "WDTn Timeout Status Register" (0x1E785010)

# Save the "WDTn Timeout Status Register" to temp memory (0x83000000)
cp.l 0x1E785010 0x83000000 0x1

# Prepare temp memory (0x83000300) for comparison
mw.l 0x83000300 0x00000000 1

if cmp.l 0x83000000 0x83000300 1;
then
	echo "BMC reset cause by Power On Reset"

	#==============Authenticate FRU HPM==============
	echo "Authenticate FRU HPM base on DCSCM 2.0 spec"

	# Save 0x0200 (DC-SCM Revision) string to temp memory (0x83000300)
	mw.w 0x83000300 0x0200 1

	# Get the HPM multirecord (ID = 0xC1) to address 0x83000400
	fru get m 0xc1 0x83000400

	# Compare HPM Fru base on Multi Record Area ("DC-SCM Revision")
	# at offset 0x83000400 + 0x4
	if cmp.b 0x83000300 0x83000404 2;
	then
		echo "Authenticate FRU HPM Success - Set BMC_GPIOB6_FRU_RD_COMPLETE to high"
		gpio set gpio@1e78000014
	else
		echo "Authenticate FRU HPM Failed"
	fi

else
	echo "BMC reset cause by WatchDog. Ignore the FRU HPM authentication"
fi

#========================Check boardname on the FRU HPM========================
# Clear 0x20 bytes (Max Field FRU size) + 0xE byte ("cio_boardname=" string) on
# 0x83000500 and 0x83000600 memory for comparison
mw.b 0x83000500 0x00 0x2E
mw.b 0x83000600 0x00 0x2E

# Export cio_boardname variable to memory 0x83000600 (cio_boardname=..........)
env export -b 0x83000600 cio_boardname

# Get the Board Product field on HPM FRU to address 0x8300050E
fru get b 1 0x8300050E

if cmp.b 0x8300050E 0x8300060E 0x20;
then
	echo "The cio_boardname existed"
else
	echo "The cio_boardname updated"

	# Save "cio_boardname=" varname string (size = 0xE) to temp memory (0x83000500)
	mw.l 0x83000500 0x5F6F6963 1
	mw.l 0x83000504 0x72616F62 1
	mw.l 0x83000508 0x6D616E64 1
	mw.w 0x8300050C 0x3D65 1

	# Import cio_boardname variable
	# from memory 0x83000500 (size = 0x20 byte + 0xE byte)
	env import -t 0x83000500 0x2E

	# Save environment
	saveenv
fi

#========================Capture BMC FRU======================================
# Probe I2C port which include the BMC FRU
i2c dev 14

# Set the internal pointer register address to first address
i2c mw 0x50 0x00 0x00

# Read BMC FRU content ( Addr 0x50, offset 0x0, length 0x200) to
# temp memory (0x83001000)
i2c read 0x50 0x00 0x200 0x83001000

# Capture the FRU table present at address 0x83001000
fru capture 0x83001000

#========================Check boardname on the BMC FRU========================
# Clear 0x20 bytes (Max Field FRU size) + 0xE byte ("bmc_boardname=" string) on
# 0x83000500 and 0x83000600 memory for comparison
mw.b 0x83000500 0x00 0x2E
mw.b 0x83000600 0x00 0x2E

# Export bmc_boardname variable to memory 0x83000600 (bmc_boardname=..........)
env export -b 0x83000600 bmc_boardname

# Get the Board Product field on BMC FRU to address 0x8300050E
fru get b 1 0x8300050E

if cmp.b 0x8300050E 0x8300060E 0x20;
then
	echo "The bmc_boardname existed"
else
	echo "The bmc_boardname updated"

	# Save "bmc_boardname=" varname string (size = 0xE) to temp memory (0x83000500)
	mw.l 0x83000500 0x5F636D62 1
	mw.l 0x83000504 0x72616F62 1
	mw.l 0x83000508 0x6D616E64 1
	mw.w 0x8300050C 0x3D65 1

	# Import bmc_boardname variable
	# from memory 0x83000500 (size = 0x20 byte + 0xE byte)
	env import -t 0x83000500 0x2E

	# Save environment
	saveenv
fi

#==============================================================================

# Boot to Linux kernel by bootm command
fdt addr 20100000
fdt header get fitsize totalsize
cp.b 20100000 ${loadaddr} ${fitsize}
bootm

#==============================================================================
