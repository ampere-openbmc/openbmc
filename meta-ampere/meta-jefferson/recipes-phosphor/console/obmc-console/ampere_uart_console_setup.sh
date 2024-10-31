#!/bin/sh -e
#
# Copyright (c) 2023 Ampere Computing LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#	http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Platform can add tty ports for console server to OBMC_CONSOLE_TTYS in their
# bbappend. The target tty devices exposed by kernel will then start their
# corresponding obmc-console-server instance and the
# obmc-console@<tty-port>.service will execute this script to direct the uart
# port of the <tty-port> to BMC

set -euo pipefail

tty="$1"
uart=0

case "${tty}" in
 "ttyS0") uart=1
 ;;
 "ttyS1") uart=2
 ;;
 *) echo "Invalid tty passed to $0. Exiting!"
    exit 0;
 ;;
esac

# Default the host routing through the mux to use the BMC (2)
# This allows the SoL console in webui, and the ssh port 2200, to work
# upon startup. If UART transceivers are installed on the header and required,
# this value should be set to 1
/usr/sbin/ampere_uartmux_ctrl.sh ${uart} 2
