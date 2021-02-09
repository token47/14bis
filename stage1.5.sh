#!/bin/bash

# This is stage 1.5, it is executed on the booted host by cloud-init.
# It's function is to download stage 2 from internet and execute it
# It's a two step stage and runs twice, first by cloud-init user-data
# and later re-spawned by itself on the virtual terminal 7 so it can
# run concurrently and let cloud-init finish.

# TODO: * Use proxy if set (for git download)

_dir="${0%/*}"
cd "$_dir"

source util.inc.sh
source config.inc.sh
source cidata.inc.sh

if [ "$1" == "openvt" ]; then
    # We are running from cloud-init, let's be quick and exit
    openvt -c 7 -- $0 reentered
    exit 0
elif [ "$1" == "reentered" ]; then
    # now we are running outside of cloud-init
    sleep 1
    chvt 7
    log msg="Stage1.5 re-entered running from virtual terminal 7"
fi

log msg="Stage1.5 starting"

log msg="Configuring the network"
#for f in /etc/netplan/*; do
#    mv "${f}" "${f}-disabled"
#done

# if iface = auto, find first *physical* network interface with link up
_found=false
if [ "${NETWORK_IFACE}" == "auto" ]; then
    log msg="Network interface set to auto, searching for the first link up"
    while read _iface; do
        _output="$(cat /sys/class/net/$_iface/operstate)"
        if [ "$_output" == "up" ]; then
            _found=true
            break
        fi
    done < <(find /sys/class/net -type l -not -lname '*virtual*' -printf '%f\n')

    if [ "$_found" == "true" ]; then
        NETWORK_IFACE="$_iface"
        log msg="Found interface $_iface with link up, using it"
    else
        log msg="ERROR: did not find any interface with link up, hanging."
        read
    fi
fi

log msg="Network config: iface=$NETWORK_IFACE ip=$NETWORK_ADDR/$NETWORK_MASK gw=$NETWORK_GW dns=$NETWORK_DNS"
generate_netplan_config > /etc/netplan/10-14bis.yaml
netplan apply

log msg="Downloading Stage2"
git clone "${REPO_URL}" /tmp/14bis

cd /tmp/14bis

log msg="Exec'ing Stage2"
chmod +x stage2.sh
exec ./stage2.sh

