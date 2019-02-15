#!/bin/bash

set -xe

export DPDK_VERSION="18.02.2"

export OVS_VERSION="2.10.1"

export OVS_LINK="https://www.openvswitch.org/releases/openvswitch-${OVS_VERSION}.tar.gz"

export RTE_SDK="/root/dpdk-${DPDK_VERSION}"

export RTE_TARGET="x86_64-native-linuxapp-gcc"

function build_ovs() {
    apt install -y autoconf libtool
    pushd /root
    wget $OVS_LINK
    tar -xzvf "openvswitch-${OVS_VERSION}.tar.gz"
    pushd "openvswitch-${OVS_VERSION}"
        ./boot.sh
        ./configure --with-dpdk=$RTE_SDK/$RTE_TARGET --prefix=/usr \
                --localstatedir=/var --sysconfdir=/etc \
                --with-linux=/lib/modules/`uname -r`/build
        proc_nr=$(cat /proc/cpuinfo | grep vendor | wc -l)
        # BUILD OVS
        make -j$proc_num

        # Install OVS binaries/libraries
        make install

        # Install kernel module
        openssl req -new -x509 -sha512 -newkey rsa:4096 -nodes -keyout key.pem \
            -days 36500 -out certificate.pem \
            -subj "/C=US/ST=Redmond/L=Redmond/O=LIS/OU=LIS/CN=microsft.com"
        cp key.pem /usr/src/linux-headers-$(uname -r)/certs/signing_key.pem
        cp certificate.pem /usr/src/linux-headers-$(uname -r)/certs/signing_key.x509
        make modules_install
        modprobe openvswitch
        lsmod | grep openvswitch
    popd
    popd
}

function run_ovs() {
    export PATH=$PATH:/usr/share/openvswitch/scripts/
    ovs-ctl start
}

function configure_ovs() {
    # Configure OVS with DPDK support
    ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
    ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-lcore-mask=0xF
    ovs-vsctl --no-wait set Open_vSwitch . other_config:pmd-cpu-mask=0x6

    OVS_BRIDGE="br-dpdk"
    ovs-vsctl add-br "${OVS_BRIDGE}" -- set bridge "${OVS_BRIDGE}" datapath_type=netdev

    ovs-vsctl add-port "${OVS_BRIDGE}" p1 -- set Interface p1 type=dpdk options:dpdk-devargs=net_vdev_netvsc0,iface=eth1
    ovs-vsctl add-port "${OVS_BRIDGE}" p2 -- set Interface p2 type=dpdk options:dpdk-devargs=net_vdev_netvsc1,iface=eth2
    ovs-vsctl add-port "${OVS_BRIDGE}" p3 -- set Interface p3 type=dpdk options:dpdk-devargs=0002:00:02.0
    ovs-vsctl add-port "${OVS_BRIDGE}" p4 -- set Interface p4 type=dpdk options:dpdk-devargs=mlx4_2
}

build_ovs

run_ovs

configure_ovs