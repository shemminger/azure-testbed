#! /bin/bash
# Install mainline kernels from Ubuntu

wget \
    https://kernel.ubuntu.com/~kernel-ppa/mainline/v4.20.7/linux-headers-4.20.7-042007_4.20.7-042007.201902061234_all.deb \
    https://kernel.ubuntu.com/~kernel-ppa/mainline/v4.20.7/linux-image-unsigned-4.20.7-042007-generic_4.20.7-042007.201902061234_amd64.deb \
    https://kernel.ubuntu.com/~kernel-ppa/mainline/v4.20.7/linux-modules-4.20.7-042007-generic_4.20.7-042007.201902061234_amd64.deb

sudo dpkg -i linux*.deb
sudo reboot &
