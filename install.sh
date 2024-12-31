#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Define the branch name and package name as variables
BRANCH_NAME="stable-8"  # Adjust this to the correct branch if needed
PACKAGE_NAME="pve-qemu-kvm"
REPO_NAME="pve-qemu-stealth"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "[INSTALL_ERROR] Please run as root"
    exit 1
fi

echo "[INSTALL_INFO] Updating package lists..."
apt update -y

echo "[INSTALL_INFO] Installing necessary packages..."
apt install -y git devscripts quilt meson check libacl1-dev libaio-dev libattr1-dev libcap-ng-dev libcurl4-gnutls-dev libepoxy-dev libfdt-dev libgbm-dev libglusterfs-dev libgnutls28-dev libiscsi-dev libjpeg-dev libpci-dev libpixman-1-dev libproxmox-backup-qemu0-dev librbd-dev libsdl1.2-dev libseccomp-dev libslirp-dev libspice-protocol-dev libspice-server-dev libsystemd-dev liburing-dev libusb-1.0-0-dev libusbredirparser-dev libvirglrenderer-dev libzstd-dev python3-sphinx-rtd-theme python3-venv quilt uuid-dev xfslibs-dev

# Check if we are already inside the repository directory
if [ ! -d ".git" ]; then
    echo "[INSTALL_INFO] Cloning the repository..."
    if [ ! -d "$REPO_NAME" ]; then
        git clone https://github.com/behappiness/$REPO_NAME.git
    fi
    if [ -f install.sh ]; then
        rm install.sh
    fi
    cd $REPO_NAME
else
    echo "[INSTALL_INFO] Already inside the repository directory."
    git pull
fi

echo "[INSTALL_INFO] Checking out the specific branch..."
git checkout "$BRANCH_NAME"

echo "[INSTALL_INFO] Creating a fresh build directory..."
make clean

echo "[INSTALL_INFO] Removing qemu folder if it exists..."
if [ -d "qemu" ]; then
    rm -rf qemu
    echo "[INSTALL_INFO] qemu folder has been deleted."
else
    echo "[INSTALL_INFO] qemu folder does not exist."
fi

echo "[INSTALL_INFO] Initializing and updating submodules..."
make submodule

echo "[INSTALL_INFO] Spoofing all Models & Serial Numbers"
bash apply_randomized_names.sh

echo "[INSTALL_INFO] Building the package..."
make

echo "[INSTALL_INFO] Installing the built package..."
dpkg -i ${PACKAGE_NAME}_*.deb

echo "[INSTALL_INFO] Fixing dependencies..."
apt install -f -y

echo "[INSTALL_INFO] Freezing the package to prevent updates..."
apt-mark hold "$PACKAGE_NAME"

echo "[INSTALL_INFO] Reboot the system for changes to take effect..."
read -p "Do you want to reboot the system now? (y/n): " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    reboot
else
    echo "[INSTALL_INFO] Reboot canceled."
fi