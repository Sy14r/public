#!/bin/bash
head -1 /etc/apt/sources.list | sed -e 's/# //g' -e 's/main/non-free/g' >> /etc/apt/sources.list
apt update
apt install vim firmware-iwlwifi
exit
