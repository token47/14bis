#!/bin/bash

# This script deals with image creation and for that it uses linux kernel devices and tools
# While it may seem dangerous (i.e. format your system partition), good care has been taken
# to avoid any undesired effects. You should be safe to run this in your normal workstation.

source config.inc.sh
source util.inc.sh

sudo /bin/true || die rc=1 msg="Cannot use sudo"

log msg="Downloading ubuntu iso image"
wget --show-progress --progress=bar -q -c -t3 "${ISOIMAGE_URL}"

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
sudo cp "${CIDATA_USER}" /mnt/user-data
sudo cp "${CIDATA_META}" /mnt/meta-data
sudo cp "${CIDATA_NET}" /mnt/network-config
sudo umount /mnt

log msg="Detaching target image from loopback"
sudo losetup -d "${_lodevice}"

log msg="Finished."
