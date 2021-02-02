#!/bin/bash

# launch target image in KVM for testing purposes (not needed in the field)

source util.inc.sh
source config.inc.sh

qemu-system-x86_64 --enable-kvm -cpu host -m 2048 -drive file="${TARGETIMAGE_NAME}",format=raw

