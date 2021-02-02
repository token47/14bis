#!/bin/bash

# This stage is not copied over to the bootable image, but instead downloaded
# from the internet in real time from stage1.5 when the host boots.

source util.inc.sh
source config.inc.sh

log msg="Starting stage2"

# Do here whatever needed to setup PXE boot and other stuff.

read

log msg="Finished --- Terminal Halted."
