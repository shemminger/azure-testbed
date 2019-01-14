#! /bin/bash -e

sudo apt-get install make pkg-config -y

# Install current version of driverctl

git clone https://gitlab.com/driverctl/driverctl.git

cd driverctl
sudo make install
