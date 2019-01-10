#! /bin/bash -e

# get necessary packages
sudo apt update
sudo apt upgrade -y
sudo apt install git build-essential libnuma-dev rdma-core libibverbs-dev -y

# get current source
git clone https://dpdk.org/git/dpdk

cd dpdk
cat >config/defconfig_azure <<@EOF@
# SPDX-License-Identifier: BSD-3-Clause
# Copyright(c) 2010-2014 Intel Corporation

# subset of x86_64-native-linuxapp-gcc

#include "common_base"

# subset of common_linuxapp
CONFIG_RTE_EXEC_ENV="linuxapp"
CONFIG_RTE_EXEC_ENV_LINUXAPP=y

CONFIG_RTE_MACHINE="native"

CONFIG_RTE_ARCH="x86_64"
CONFIG_RTE_ARCH_X86_64=y
CONFIG_RTE_ARCH_X86=y
CONFIG_RTE_ARCH_64=y

CONFIG_RTE_TOOLCHAIN="gcc"
CONFIG_RTE_TOOLCHAIN_GCC=y

CONFIG_RTE_EAL_NUMA_AWARE_HUGEPAGES=y
CONFIG_RTE_EAL_IGB_UIO=n
CONFIG_RTE_EAL_VFIO=n
CONFIG_RTE_LIBRTE_PMD_AF_PACKET=y
CONFIG_RTE_LIBRTE_PMD_TAP=y
CONFIG_RTE_PROC_INFO=y

CONFIG_RTE_LIBRTE_VDEV_NETVSC_PMD=y
CONFIG_RTE_LIBRTE_VMBUS=y
CONFIG_RTE_LIBRTE_NETVSC_PMD=y
CONFIG_RTE_LIBRTE_MLX5_PMD=y
@EOF@

make config T=azure
make -j8

