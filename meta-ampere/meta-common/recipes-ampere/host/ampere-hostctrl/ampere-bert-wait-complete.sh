#!/bin/bash

# shellcheck disable=SC2046

function wait_bert_complete()
{
	# Wait maximum 60 seconds for BERT completed
	cnt=30
	while [ $cnt -gt 0 ]
	do
		if systemctl status ampere-bert-power-handle.service | grep "Active: inactive"; then
			break;
		fi
		sleep 2
		cnt=$((cnt - 1))
	done
	if [ "$cnt" -eq "0" ]; then
		echo "Timeout 60 seconds, The Ampere BERT is not finished"
	fi
	echo "The Ampere BERT is finished."
}

# Only call if this script run directly, not when sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	wait_bert_complete
fi
