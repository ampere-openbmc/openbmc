#!/bin/bash
units=(
    bmcweb_440.socket
    bmcweb.socket
    bmcweb.service
)

for unit in "${units[@]}"; do
    systemctl stop "$unit"
done

# Wait for 1 second
sleep 1s

for unit in "${units[@]}"; do
    systemctl start "$unit"
done

