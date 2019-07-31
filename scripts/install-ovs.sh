#!/bin/bash

set -xe

# DPDK NEEDS TO HAVE BEEN ALREADY BUILT in "/root/dpdk-${DPDK_VERSION}" folder
export DPDK_VERSION="18.02.2"
export RTE_SDK="/root/dpdk-${DPDK_VERSION}"
export RTE_TARGET="x86_64-native-linuxapp-gcc"

export OVS_VERSION="2.10.1"
export OVS_LINK="https://www.openvswitch.org/releases/openvswitch-${OVS_VERSION}.tar.gz"


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

    # use testpmd show port info <port_number>
    # we will use eth1 and eth2, which are mapped in dpdk as net_tap_vsc0 and net_tap_vsc1

    IFACE_NAME_1="eth1"
    IFACE_NAME_2="eth2"
    # TO BE SEEN BY DPDK, INTERFACES SHOULD NOT BE CONFIGURED
    ip addr flush dev $IFACE_NAME_1
    ip addr flush dev $IFACE_NAME_2

    IFACE_DPDK_NAME_1="net_tap_vsc0"
    IFACE_DPDK_NAME_2="net_tap_vsc1"
    ovs-vsctl add-port "${OVS_BRIDGE}" p1 -- set Interface p1 type=dpdk options:dpdk-devargs="${IFACE_DPDK_NAME_1}",iface="${IFACE_NAME_1}"
    ovs-vsctl add-port "${OVS_BRIDGE}" p2 -- set Interface p2 type=dpdk options:dpdk-devargs="${IFACE_DPDK_NAME_2}",iface="${IFACE_NAME_2}"
}

build_ovs

run_ovs

configure_ovs