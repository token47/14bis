
# The proxy config to use on the booted machine (empty for no proxy)
#PROXY_URL="http://user@pass:hostname:port/"
#PROXY_URL="http://hostname:3128/"
PROXY_URL=""

# Room for the ISO in the destination drive (can be bigger than actual ISO)
ISO_MAX_SIZE="$((1500 * 1024 * 1024 * 1024))" # 1500MB
DATA_MAX_SIZE="$((400 * 1024 * 1024 * 1024))" # 400MB

# The name and size of the generated image (to be later dumped to a flashdrive)
TARGETIMAGE_NAME="14bis-bootable.img"
TARGETIMAGE_SIZE="$((ISO_MAX_SIZE + DATA_MAX_SIZE))"

# You want the server image (smaller)
ISOIMAGE_URL="http://releases.ubuntu.com/20.04/ubuntu-20.04.1-live-server-amd64.iso"
ISOIMAGE_NAME="${ISOIMAGE_URL##*/}"

# The cloud init file to be copied to the image
CIDATA_USER="cloudinit_userdata.yaml"
CIDATA_META="cloudinit_metadata.yaml"
CIDATA_NET="cloudinit_networkconfig.yaml"

