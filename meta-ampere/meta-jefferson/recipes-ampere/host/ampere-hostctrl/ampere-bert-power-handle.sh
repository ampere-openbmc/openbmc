#!/bin/bash

# shellcheck disable=SC2046
# shellcheck source=meta-ampere/meta-common/recipes-ampere/platform/ampere-utils/ampere_power_control_lock.sh
source /usr/sbin/ampere_power_control_lock.sh

wait_bert_complete() {
	# Wait maximum 60 seconds for BERT completed
	cnt=20
	while [ $cnt -gt 0 ]
	do
		bert_done=$(busctl get-property com.ampere.CrashCapture.Trigger /com/ampere/crashcapture/trigger com.ampere.CrashCapture.Trigger TriggerActions | cut -d"." -f6)
		if ! [ "$bert_done" == "Done\"" ]; then
			sleep 3
			cnt=$((cnt - 1))
		else
			break
		fi
	done
	if [ "$cnt" -eq "0" ]; then
		echo "Timeout 60 seconds, BERT is still not completed"
		return 1
	fi
	return 0
}


echo "Notify Crash Capture to read BERT."
busctl set-property com.ampere.CrashCapture.Trigger \
       /com/ampere/crashcapture/trigger \
       com.ampere.CrashCapture.Trigger \
       TriggerProcess b true
bert_timeout="0"
# Wait until RAS BERT process completed
wait_bert_complete
bert_timeout=$?
# If the crash capture process is crash or works unstable, it does
# not unmask the power action. We should call unmask here to make sure
# the power control is unmasked
if [[ "${bert_timeout}" == "1" ]]; then
    unmask_reboot_targets
    unmask_off_targets
fi
