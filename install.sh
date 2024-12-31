#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Define the branch name and package name as variables
BRANCH_NAME="stable-8"  # Adjust this to the correct branch if needed
PACKAGE_NAME="pve-qemu-kvm"
REPO_NAME="pve-qemu-stealth"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

echo "Updating package lists..."
apt update -y

echo "Installing necessary packages..."
apt install -y git devscripts quilt meson check libacl1-dev libaio-dev libattr1-dev libcap-ng-dev libcurl4-gnutls-dev libepoxy-dev libfdt-dev libgbm-dev libglusterfs-dev libgnutls28-dev libiscsi-dev libjpeg-dev libpci-dev libpixman-1-dev libproxmox-backup-qemu0-dev librbd-dev libsdl1.2-dev libseccomp-dev libslirp-dev libspice-protocol-dev libspice-server-dev libsystemd-dev liburing-dev libusb-1.0-0-dev libusbredirparser-dev libvirglrenderer-dev libzstd-dev python3-sphinx-rtd-theme python3-venv quilt uuid-dev xfslibs-dev

echo "Cloning or updating the repository..."
if [ ! -d "$REPO_NAME" ]; then
    git clone https://github.com/behappiness/$REPO_NAME.git
fi
cd $REPO_NAME
git pull

echo "Checking out the specific branch..."
git checkout "$BRANCH_NAME"

echo "Initializing and updating submodules..."
make submodule

echo "Spoofing all Models & Serial Numbers"
wget -L https://raw.github.com/behappiness/pve-qemu-stealth/stable-8/apply_randomized_names.sh
bash apply_randomized_names.sh

echo "Creating a fresh build directory..."
make clean
make distclean
make

echo "Building the package..."
make

echo "Installing the built package..."
dpkg -i *.deb

echo "Fixing dependencies..."
apt install -f -y

echo "Freezing the package to prevent updates..."
apt-mark hold "$PACKAGE_NAME"

echo "Rebooting the system..."
reboot