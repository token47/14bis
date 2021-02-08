#!/bin/bash

# This script deals with image creation and for that it uses linux kernel devices and tools
# While it may seem dangerous (i.e. format your system partition), good care has been taken
# to avoid any undesired effects. You should be safe to run this in your normal workstation.

# What we do here is dump the ISO image into a larger raw image, add a new partition on that
# extra space and put cloud init data there. This works because the ISO image is a hybrid
# one and embeds a partition table to be able to just be dumped into a usb flash drive and
# booted. The resulting image is a raw image with partitions and can be flashed to usb drive.
# That cloud init data could be placed in a separate device (local datastore only cares for
# a filesystem with the "cidata" label). We use the same image for convenience.

source config.inc.sh
source util.inc.sh
source cidata.inc.sh

sudo /bin/true || die rc=1 msg="Cannot use sudo"

log msg="Downloading ubuntu iso image"
wget --show-progress --progress=bar -q -c -t3 "${ISOIMAGE_URL}" || \
    die rc=1 msg="Error downloading image, please check url and/or network connection"

log msg="Verifying ISO checksum"
if ! echo "${ISOIMAGE_SHA256SUM} ${ISOIMAGE_NAME}" | sha256sum --check; then
    die rc=1 msg="ISO checksum does not match"
fi

log msg="Creating empty target image"
rm -f "${TARGETIMAGE_NAME}"
truncate -s "${TARGETIMAGE_SIZE}" "${TARGETIMAGE_NAME}"

log msg="Writing iso image to target image"
dd if="${ISOIMAGE_NAME}" of="${TARGETIMAGE_NAME}" status=progress conv=notrunc

log msg="Adding data partition to target image"
echo ",,b,;" | sudo sfdisk -q --append "${TARGETIMAGE_NAME}"

log msg="Attaching target image to loopback device"
_lodevice="$(sudo losetup -b 512 -f --show --partscan "${TARGETIMAGE_NAME}")"

_rc="$?"
if [ "$_rc" -ne 0 -o -z "$_lodevice" ]; then
    die rc=1 msg="Could not create loopback for the target image (rc=${_rc}, lodevice=${_lodevice})"
fi

log msg="${TARGETIMAGE_NAME} loopback is ${_lodevice}"

# be very paranoid over the returned device
if [[ ! "$_lodevice" =~ ^/dev/loop ]]; then
    die rc=1 msg="Returned loopback device is not a loop device"
fi
if ! losetup | grep -q "^${_lodevice}.*${TARGETIMAGE_NAME}"; then
    die rc=1 msg="Returned loopback device is not for the specified file"
fi

log msg="Creating fat filesystem on data partition"
sudo mkfs.fat -n CIDATA "${_lodevice}p3"

log msg="Mounting data partition, copying data, unmounting"
sudo mount "${_lodevice}p3" /mnt
generate_ci_userdata | sudo dd status=none of=/mnt/user-data
generate_ci_metadata | sudo dd status=none of=/mnt/meta-data
generate_ci_networkconfig | sudo dd status=none of=/mnt/network-config
sudo cp config.inc.sh /mnt/
sudo cp util.inc.sh /mnt/
sudo cp stage1.5.sh /mnt/
sudo chmod +x /mnt/stage1.5.sh
sudo umount /mnt

log msg="Detaching target image from loopback"
sudo losetup -d "${_lodevice}"

log msg="Finished."
