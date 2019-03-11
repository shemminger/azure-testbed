#! /bin/bash

# get necessary packages
sudo apt-get install git build-essential pkg-config \
     libnuma-dev libmnl-dev rdma-core libibverbs-dev -y

cd /usr/src
git clone https://gerrit.fd.io/r/vpp

cd vpp
make install-dep
make install-ext-deps
