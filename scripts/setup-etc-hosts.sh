#!/bin/bash
set -ex

sed -i -e "s/^.*${HOSTNAME}.*/${1} ${HOSTNAME} ${HOSTNAME}.local/" /etc/hosts
