
# The proxy config to use on the booted machine (empty for no proxy)
#PROXY_URL="http://user@pass:hostname:port/"
#PROXY_URL="http://hostname:3128/"
PROXY_URL=""

# Room for the ISO in the destination drive (can be bigger than actual ISO)
ISO_MAX_SIZE="$((1500 * 1024 * 1024))" # 1500MB
DATA_MAX_SIZE="$((400 * 1024 * 1024))" # 400MB

# The name and size of the generated image (to be later dumped to a flashdrive)
TARGETIMAGE_NAME="14bis-bootable.img"
TARGETIMAGE_SIZE="$((ISO_MAX_SIZE + DATA_MAX_SIZE))"

# You want the server image (smaller)
ISOIMAGE_URL="http://releases.ubuntu.com/20.04/ubuntu-20.04.1-live-server-amd64.iso"
ISOIMAGE_NAME="${ISOIMAGE_URL##*/}"
ISOIMAGE_SHA256SUM="443511f6bf12402c12503733059269a2e10dec602916c0a75263e5d990f6bb93"

# Repo containing stage2
REPO_URL="https://git.launchpad.net/~andre-ruiz/+git/14bis/"

# Static network config
NETWORK_IFACE="ens4"
NETWORK_ADDR="192.168.250.1"
NETWORK_MASK="24"
NETWORK_GW="192.168.250.254"
NETWORK_DNS="192.168.250.254"

