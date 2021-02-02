#!/bin/bash

source config.inc.sh

# TODO: remove hardcoded "sda3" device and swarch for the CIDATA partition

function generate_ci_userdata() {
cat <<EOF
#cloud-config
runcmd:
  - mount /dev/sda3 /mnt
  - /mnt/stage1.5.sh openvt
final_message: ">>>>>>>> Cloudinit finished 14bis injection on live image <<<<<<<<"
EOF
}

function generate_ci_metadata() {
cat <<EOF
EOF
}

function generate_ci_networkconfig() {
cat <<EOF
version: 2
ethernets:
  ${NETWORK_IFACE}:
     dhcp4: false
     addresses: [ ${NETWORK_ADDR}/${NETWORK_MASK} ]
     gateway4: ${NETWORK_GW}
     nameservers:
       addresses: [ ${NETWORK_DNS} ]
EOF
}

