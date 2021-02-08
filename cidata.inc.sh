#!/bin/bash

source config.inc.sh
source util.inc.sh

# TODO: * remove hardcoded "sda3" device and search for the CIDATA partition

function generate_ci_userdata() {
cat <<EOF
#cloud-config
hostname: infrachecker
runcmd:
  - mount /dev/sda3 /mnt
  - /mnt/stage1.5.sh openvt
final_message: ">>>>>>>> Cloudinit finished 14bis injection on live image <<<<<<<<"
EOF
}

function generate_ci_metadata() {
cat <<EOF
{
  "instance-id": "iid-infrachecker",
  "dsmode": "local"
}
EOF
}

function generate_ci_vendordata() {
cat <<EOF
EOF
}

function generate_ci_networkconfig() {
# we're not using netwrong-config in cloud-init anymore
# and instead injecting netplan file in stage1.5
cat <<EOF
EOF
}

function generate_netplan_config() {
cat <<EOF
network:
  version: 2
  ethernets:
    ${NETWORK_IFACE}:
      dhcp4: false
  bridges:
    br-int:
      addresses: [ ${NETWORK_ADDR}/${NETWORK_MASK} ]
      gateway4: ${NETWORK_GW}
      nameservers:
        addresses: [ ${NETWORK_DNS} ]
      interfaces: [ ${NETWORK_IFACE} ]
      parameters:
        stp: false   
        forward-delay: 0
EOF
}
