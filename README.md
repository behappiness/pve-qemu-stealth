# PACKAGE CHANGES AND INSTALLATION

This package has been modified to fake device names against anti-cheat detection. The package is built and installed on the following Proxmox VE version: [proxmox-ve_8.2-2.iso](https://enterprise.proxmox.com/iso/proxmox-ve_8.2-2.iso)

To install this package, you can use the provided `install.sh` script. This script automates the installation process, but user interaction is required to apply the configuration.

To run the installation script, execute the following command as root in your terminal:

```bash
wget -L https://raw.github.com/behappiness/pve-qemu-stealth/stable-8/install.sh
bash install.sh
```

To update the package, run the script again.

# Make your own changes

You can make your own changes to the package by editing the files in the `pve-qemu-stealth` directory in the following manner:

1. Clone the repository
2. Install the dependencies (see in `install.sh`)
3. Run `make submodule` to initialize and update submodules
4. Use `quilt` to apply patches:
   - Might need to `export QUILT_PATCHES=../debian/patches` and `export QUILT_REFRESH_ARGS="-p ab --no-timestamps --no-index"` for quilt to work properly
   - `cd qemu`
   - Apply existing patches: `quilt push -a`
   - Make changes to the files as needed
   - Refresh the patches: `quilt refresh`
   - Clean up the patches: `quilt pop -a`
5. Run `make clean` and `make distclean` to clean the build directory
6. Run `make` to build the package
