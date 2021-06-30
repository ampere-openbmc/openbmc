#!/bin/bash

# Initialize variables
BOOTSTRAP_ACC_LIST=$(< /etc/passwd awk -F: '{print $1}' | grep obmcRedfish)

# shellcheck disable=SC2068
# shellcheck disable=SC2086

for USER_NAME in ${BOOTSTRAP_ACC_LIST[@]}
do
	USER_ID=$(ipmitool user list 1 | grep "$USER_NAME" | cut -c1-2)
	echo "Delete Bootstrap account $USER_NAME, User ID is $USER_ID"
	ipmitool user disable $USER_ID
	ipmitool user set name $USER_ID ""
done

# If the EnableAfterReset property within the CredentialBootstrapping property
# of the host interface resource is true, services shall set the Enabled property
# to true
st=$(busctl get-property xyz.openbmc_project.User.Manager \
	/xyz/openbmc_project/user/root \
	xyz.openbmc_project.HostInterface.CredentialBootstrapping \
	EnableAfterReset | cut -d" " -f2)
if [ "$st" == "true" ]; then
	busctl set-property xyz.openbmc_project.User.Manager \
	/xyz/openbmc_project/user/root \
	xyz.openbmc_project.HostInterface.CredentialBootstrapping \
	Enabled b true
fi
