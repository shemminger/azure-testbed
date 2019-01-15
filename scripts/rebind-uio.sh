#! /bin/bash

# rebind eth1 to be used by uio_hv_generic

# Setup UIO
NET_UUID="f8615163-df3e-46c5-913f-f2d2f965ed0e"
if [ ! -d /sys/module/uio_hv_generic ]; then
    sudo modprobe uio_hv_generic
    echo $NET_UUID > /sys/bus/vmbus/drivers/uio_hv_generic/new_id
fi

if [ ! -l /sys/class/net/eth1 ]; then
    echo  "eth1 is missing (already rebound?)"
    exit 1
fi

DEV_UUID=$(basename $(readlink /sys/class/net/eth1/device))
if [ -z "$DEV_UUID" ]; then
    echo "can't find device UUID"
    exit 1
fi

sudo "echo $DEV_UUID > /sys/bus/vmbus/drivers/hv_netvsc/unbind"
sudo "echo $DEV_UUID > /sys/bus/vmbus/drivers/uio_hv_generic/bind"
