#!/bin/bash

# launch target image in KVM for testing purposes (not needed in the field)

source util.inc.sh
source config.inc.sh

# This is temporary. By default qemu is using "User Network" on ens3 and adding a second
# interface ens4 because of the -device e1000 config below. We are using this ens4 interface
# to test configuring the network. When this gets sufficiently mature the whole network
# model will be changed to bridged.
# If you see the network config (ip/netmaks/etc) ending up in ens4 things are good for now.

BRIDGE="virbr0" # attach to existing libvirt bridge
                # don't forget to "allow <bridge>" it in /etc/qemu/brdige.conf

sudo qemu-system-x86_64 \
        --enable-kvm \
        -cpu host \
        -m 2048 \
        -drive file="${TARGETIMAGE_NAME}",format=raw \
        -netdev bridge,br=${BRIDGE},id=net0 \
        -device virtio-net-pci,netdev=net0 \
|| die rc=1 msg="Failed to start qemu. Pay attention to any messages above."

