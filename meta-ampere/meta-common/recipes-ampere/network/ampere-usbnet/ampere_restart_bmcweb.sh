#!/bin/bash

systemctl stop bmcweb_440.socket
systemctl stop bmcweb.socket
systemctl stop bmcweb.service

sleep 1s

systemctl start bmcweb_440.socket
systemctl start bmcweb.socket
systemctl start bmcweb.service
