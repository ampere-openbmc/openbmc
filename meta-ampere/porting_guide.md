# Ampere OpenBMC Porting Guide

This document aims to guide users to port Ampere OpenBMC (Mt.Jade or Mt.Mitchell OpenBMC) to a new Altra or AmpereOne -based platform. Guideline for features that are not specific for Ampere reference platform is out of scope for this document.

It is expected that users have previous knowledge on developing OpenBMC. Otherwise, refer to links from the Reference section for basic knowledge on developing/porting OpenBMC for platforms.

## Ampere OpenBMC Repositories

- [linux][2]: Ampere Linux kernel, forked from OpenBMC linux kernel and adds more changes (device tree, drivers, ...) to fully support Ampere required features.
- [ampere-ipmi-oem][1]: Ampere IPMI OEM. Refer to [README](https://github.com/ampere-openbmc/ampere-ipmi-oem/blob/ampere/README.md) file for all IPMI commands supported.
- [ampere-misc](https://github.com/ampere-openbmc/ampere-misc): contain applications that provide workaround or temporary solutions that will be replaced later.
- [pldm](https://github.com/ampere-openbmc/pldm): Ampere pldm, forked from https://github.com/openbmc/pldm with adding sensors and RAS support.

## Directory Structure

```mermaid
flowchart TD
    A[openbmc] --> B(meta-ampere)
    B --> C(meta-common)
    B --> D(meta-platform)
    C --> E(recipes-ampere)
    C --> F(recipes-phosphor)
    D --> G(recipes-ampere)
    D --> H(recipes-phosphor)
```

Where: platform = mtjade, mtmitchell, ...

- `meta-ampere/meta-common/recipes-ampere `: Contain Ampere-specific (but not platform specific) features, include:
	- host
		- [`ampere-hostctrl`](https://github.com/openbmc/openbmc/tree/master/meta-ampere/meta-common/recipes-ampere/host/ampere-hostctrl): contain Ampere services to support Host control operations like for reset (via `SYS_RESET` pin), check if Host is already ON, ...
		- [`ac01-boot-progress`](https://github.com/ampere-openbmc/openbmc/tree/ampere/meta-ampere/meta-common/recipes-ampere/host/ac01-boot-progress): check boot progress from Altra-based Host, update to dbus and log events to Redfish EventLog.
		- [`ac01-openocd`](https://github.com/ampere-openbmc/openbmc/blob/ampere/meta-ampere/meta-common/recipes-ampere/host/ac01-openocd.bb): OpenOCD support for Altra silicon.
		- [`ac03-openocd`](https://github.com/ampere-openbmc/openbmc/blob/ampere/meta-ampere/meta-common/recipes-ampere/host/ac03-openocd.bb): OpenOCD support for AmpereOne silicon.
	- network
		- [`ampere-usbnet`](https://github.com/openbmc/openbmc/tree/master/meta-ampere/meta-common/recipes-ampere/network/ampere-usbnet): create virtual USB Ethernet.
	- platform
		- [`ampere-utils`](https://github.com/ampere-openbmc/openbmc/blob/ampere/meta-ampere/meta-common/recipes-ampere/platform/ampere-utils.bb): utilities to flash Host firmware images.
		- [`ampere-driver-binder`](https://github.com/ampere-openbmc/openbmc/tree/ampere/meta-ampere/meta-common/recipes-ampere/platform/ampere-driver-binder): services to bind drivers after Host power on and Host running. Platform dependent scripts will implement specific commands to bind drivers.
- `meta-ampere/meta-common/recipes-phosohor`: Contain common features that can be used in different platforms.
	- flash
		- [`phosphor-software-manager`](https://github.com/ampere-openbmc/openbmc/tree/ampere/meta-ampere/meta-common/recipes-phosphor/flash/phosphor-software-manager): backend script to flash Host firmware.
- `meta-ampere/meta-<platform>/recipes-ampere `: platform specific features.
- `meta-ampere/meta-<platform>/recipes-phosphor `: configure phosphor recipes with platform specific information.
	- [`gpio`](https://github.com/ampere-openbmc/openbmc/tree/ampere/meta-ampere/meta-jade/recipes-phosphor/gpio): `phosphor-gpio-monitor` based GPIO application to handle GPIOs from Altra silicon.

# Configure for BMC processors

There is no difference in application level for different BMC processors like Aspeed AST2500, 2600, ... however, need to configure for correct u-boot and Linux device tree for the BMC CPU. This can be done by below declaration in machine configuration file (meta-\<vendor\>/meta-\<platform\>/conf/machine/\<platform-name\>.conf) (assume new platform uses OpenBMC u-boot 2019.04)

```
require conf/machine/include/ast2600.inc     <-- replace ast2600.inc by appropriate include file if not using Aspeed AST2600
require conf/machine/include/obmc-bsp-common.inc

KMACHINE = "aspeed"                                                    <-- change with appropriate architecture if not using Aspeed processo
KERNEL_DEVICETREE = "aspeed/${KMACHINE}-bmc-ampere-mtmitchell.dtb"     <-- change for correct Linux device tree binary
UBOOT_DEVICETREE = "ast2600-bletchley"                                 <-- change to correct u-boot device tree
UBOOT_MACHINE = "ast2600_openbmc_spl_defconfig"                        <-- change to correct u-boot's defconfig file to compile u-boot image
```

## Linux kernel

Refer to [Ampere Linux kernel][2] for drivers and [device tree][4] for reference.

## Altra Host sensors and RAS report

For Altra-based platforms, do the following to enable Host sensor monitoring and RAS error reporting:

- Add smpro nodes to the device tree:

	```
		smpro@4f {
			compatible = "ampere,smpro";
			reg = <0x4f>;
		};
	```

- Enable below kernel configurations to compile the [smpro-hwmon](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/hwmon/smpro-hwmon.c), [smpro-errmon](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/misc/smpro-errmon.c) and [smpro-misc](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/misc/smpro-misc.c) Linux drivers
	```
	CONFIG_HWMON=y
	CONFIG_MFD_SMPRO=y
	CONFIG_SMPRO_MISC=y
	CONFIG_SMPRO_ERRMON=y
	```

- Add AmpereCPU device with [45334](https://gerrit.openbmc-project.xyz/c/openbmc/dbus-sensors/+/45334), [45336](https://gerrit.openbmc-project.xyz/c/openbmc/dbus-sensors/+/45336) and [45335](https://gerrit.openbmc-project.xyz/c/openbmc/dbus-sensors/+/45335) commits to support monitor the hwmon changes, update information to dbus.

- When the BMC kernel boots while the Host is OFF, no /sys interface is created for hwmon. When this happens, need to bind the hwmon /sys interface after the Host's is ON. This needs to be done after the S0_FW_BOOT_OK from Mpro is asserted but before the Host state changes to `Running`. Refer to the [`ampere_host_check.sh`](https://github.com/ampere-openbmc/openbmc/blob/ampere/meta-ampere/meta-common/recipes-ampere/host/ampere-hostctrl/ampere_host_check.sh) and [`ampere_driver_binder.sh`](https://github.com/ampere-openbmc/openbmc/blob/ampere/meta-ampere/meta-jade/recipes-ampere/platform/ampere-utils/ampere_driver_binder.sh) for an example on how to support.

- Define sensor information in the entity-manager config. Refer to [mtjade.json](https://github.com/ampere-openbmc/openbmc/blob/ampere/meta-ampere/meta-jade/recipes-phosphor/configuration/entity-manager/mtjade.json). It is good to copy the node with `"Type":"smpro_hwmon"` and update I2C bus/address information for the new platform.

- Enable the `altra-host-error-monitor` option in ampere-misc bitbake for the `altra-host-error-monitor` application with configuration to enable RAS error monitoring. Refer to Mt.Jade [`ampere-misc.bbappend`](https://github.com/ampere-openbmc/openbmc/blob/ampere/meta-ampere/meta-jade/recipes-ampere/platform/ampere-misc.bbappend) recipe configuration for reference.

 - Enable [ac01-boot-progress](https://github.com/ampere-openbmc/openbmc/tree/ampere/meta-ampere/meta-common/recipes-ampere/host/ac01-boot-progress) to monitor Host boot progress and update status to dbus.


## IPMI SSIF

IPMI SSIF enables in-band IPMI communication between BMC and Host over I2C/SMBUS. To enable IPMI SSIF driver support, do the following:

- Add bmc-ssif device node

	```
        ssif-bmc@10 {
                compatible = "ssif-bmc";
                reg = <0x10>;
        };
	```

- Enable `CONFIG_SSIF_IPMI_BMC` kernel config which will compile the [BMC SSIF driver](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/char/ipmi/ssif_bmc.c). 

- Enable `obmc-host-ipmi-hw` with `phosphor-ipmi-ssif` in [board config](https://github.com/openbmc/openbmc/blob/master/meta-ampere/meta-jade/conf/machine/mtjade.conf) file:
```
PREFERRED_PROVIDER_virtual/obmc-host-ipmi-hw = "phosphor-ipmi-ssif"
```
- Enable SSIF channel configuration in [channel_config.json](https://github.com/openbmc/openbmc/blob/master/meta-ampere/meta-jade/recipes-phosphor/ipmi/phosphor-ipmi-config/channel_config.json) file.

```
	{
		"15": {
			"name": "ipmi_ssif",
			"is_valid": true,
			"active_sessions": 0,
			"channel_info": {
				"medium_type": "smbus-v2.0",
				"protocol_type": "ipmi-smbus",
				"session_supported": "session-less",
				"is_ipmi": true
			}
		}
	}
```

- Check to ensure the `ssifbridge.service` service starts correctly and `/dev/ipmi-ssif-host` device node exists:

```
	# systemctl status ssifbridge.service
	# ls /dev/ipmi-ssif-host
```

## AmpereOne CPU Sensors and Error Report

AmpereOne CPU sensors and RAS Errors are supported by MCTP and PLDM. Do the following to enable MCTP/PLDM support:

- Configure device tree for MCTP node
```
&i2cX {
		...
        multi-master;
        mctp-controller;

        mctp@10 {
                compatible = "mctp-i2c-controller";
                reg = <(0x10 | I2C_OWN_SLAVE_ADDRESS)>;
        };
};
```

- Add `require conf/distro/include/pldm.inc` in machine config file and configure some platform specific MCTP/PLDM configuration. Refer to the [meta-ampere: mtmitchell: enable MCTP/PLDM](https://github.com/openbmc/openbmc/commit/7b3a9f5a9abeced85dd3c90e03c0259d52c16f26) commit for reference.

- This will create a new Ethernet interface like below:

```
# ifconfig
mctpi2c3  Link encap:UNSPEC  HWaddr 10-00-30-30-30-30-00-30-00-00-00-00-00-00-00-00
          UP RUNNING  MTU:254  Metric:1
          RX packets:3424628 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3424480 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1100
          RX bytes:78650459 (75.0 MiB)  TX bytes:51339300 (48.9 MiB)
```

- Change to use Ampere PLDM repository with appropriate configuration. Refer to [this commit](https://github.com/ampere-openbmc/openbmc/commit/acae8f4c797ee602417ac2615ab224148a5621a1) for reference.

- Add [ampere-mctp-i2c-binding.bb](https://github.com/ampere-openbmc/openbmc/blob/ampere/meta-ampere/meta-common/recipes-ampere/host/ampere-mctp-i2c-binding.bb) for automatic addition and removal of MCTP endpoints.

## Power Control

Altra silicon supports power control operations below:

| Redfish | IPMI | OpenBMC actions |
| --- | --- | --- |
| ForceOff | power down | DC power off host immediately |
| ForceOn | power up | DC power on host immediately |
| ForceRestart | hard reset | Trigger host `SYS_RESET` pin |
| GracefulShutdown | soft off | Graceful shutdown the host |
| GracefulRestart |  | Graceful shutdown host then DC power on |
| On | power up | Same as ForceOn |
| PowerCycle | power cycle | graceful shutdown then DC power on |

To implement power ON, OFF, cycle handling, declare GPIO pin information inside [skeleton](https://github.com/openbmc/skeleton)'s gpio_defs.json file for power good GPIO, GPIO signal to control power ON, ... Refer to Mt.Jade [gpio_defs.json](https://github.com/openbmc/openbmc/blob/master/meta-ampere/meta-jade/recipes-phosphor/skeleton/obmc-libobmc-intf/gpio_defs.json) file for an example implementation.

Graceful Shutdown in OpenBMC is implemented using SMS_ATN (Heartbeat) which is only available in IPMI KCS interface only. To implement graceful shutdown for Ampere Altra silicon, need to overwrite the `xyz.openbmc_project.Ipmi.Internal.SoftPowerOff.service` service which asserting the `SHUTDOWN_REQ` GPIO instead. Refer to [`phosphor-ipmi-host_%.bbappend`](https://github.com/openbmc/openbmc/blob/master/meta-ampere/meta-common/recipes-phosphor/ipmi/phosphor-ipmi-host_%25.bbappend) for how Ampere OpenBMC overwrite this service.

### Host power signal handling
In addition, it also supports operations from Host OS:

| Host | OpenBMC actions |
| --- | --- |
| reboot | Trigger `SYS_RESET` pin to reset host when detecting `REBOOT_ACK` GPIO asserted |
| poweroff/shutdown | Turn OFF the Host power when detecting `SHUTDOWN_ACK` GPIO asserted |

Handling `REBOOT_ACK` and `SHUTDOWN_ACK` GPIOs from Host can be done by using [`phosphor-gpio-monitor`][5]. Refer to Mt.Jade [`phosphor-gpio-monitor`](https://github.com/openbmc/openbmc/tree/master/meta-ampere/meta-jade/recipes-phosphor/gpio/phosphor-gpio-monitor) for the implementation.


## Host State Detection

OpenBMC's [phosphor-state-manager][3] just supports detect Host state via PLDM and IPMI (just available for IPMI KCS) which are not available in Ampere Altra-based platform. In Ampere Altra-based platform, a GPIO named `S0_FW_BOOT_OK` is used to identify if the Host is Running or Off.

To enable Host State detection via GPIO, define the GPIO with linename `host0-ready` in device tree, then enable the feature in [phosphor-state-manager](https://github.com/openbmc/openbmc/blob/master/meta-ampere/meta-common/recipes-phosphor/state/phosphor-state-manager_%25.bbappend)

```
EXTRA_OEMESON:append = " -Dhost-gpios=enabled"
```

## Firmware Update

OpenBMC supports firmware update for BMC and Host firmware. However, need to implement the backend code to flash Host firmware image. To do so, overwrite the `obmc-flash-host-bios@.service` service to add the script to execute the flashing.

Refer to the [`phosphor-software-manager`](https://github.com/openbmc/openbmc/tree/master/meta-ampere/meta-common/recipes-phosphor/flash/phosphor-software-manager) for how to overwrite for Host firmware update:

* Add `obmc-flash-host-bios@.service` which calls the `firmware_update.sh` script to execute the actual firmware flashing.
* The `firmware_update.sh` script will check the MANIFEST file for value of `EXTENDED_VERSION` in the MANIFEST file. Base on the value, will flash the firmware image into appropriate hardware device (Host SPI-NOR, Boot EEPROM,...)

Refer to [`code-update`](https://github.com/openbmc/docs/tree/master/architecture/code-update) document for design of OpenBMC firmware update.


## Reference

1. [https://github.com/mine260309/openbmc-intro/blob/master/Porting_Guide.md](https://github.com/mine260309/openbmc-intro/blob/master/Porting_Guide.md)
2. [IBM: How to port OpenBMC](https://developer.ibm.com/tutorials/how-to-port-openbmc/)
3. [OpenBMC Official Documentation](https://github.com/openbmc/docs)
4. [OpenBMC wiki](https://github.com/openbmc/openbmc/wiki)
5. [Yadro: OpenBMC overview](https://drive.yadro.com/s/jt8LpNEXoQZeXtE)

[1]: https://github.com/ampere-openbmc/ampere-ipmi-oem
[2]: https://github.com/ampere-openbmc/linux
[3]: https://github.com/openbmc/phosphor-state-manager
[4]: https://github.com/ampere-openbmc/linux/blob/ampere/arch/arm/boot/dts/aspeed/aspeed-bmc-ampere-mtjade.dts
[5]: https://github.com/openbmc/phosphor-gpio-monitor
