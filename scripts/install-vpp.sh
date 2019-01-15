#! /bin/bash

cd /usr/src
git clone https://gerrit.fd.io/r/vpp

cd vpp
make install-dep
make install-ext-deps
