#! /bin/bash -e

# Install current version of driverctl

git clone https://gitlab.com/driverctl/driverctl.git

cd driverctl
sudo make install
