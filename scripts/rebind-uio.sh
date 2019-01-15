#! /bin/bash

# rebind eth1 to be used by uio_hv_generic

# Setup UIO
NET_UUID="f8615163-df3e-46c5-913f-f2d2f965ed0e"
if [ ! -d /sys/module/uio_hv_generic ]; then
    sudo modprobe uio_hv_generic
    echo $NET_UUID > /sys/bus/vmbus/drivers/uio_hv_generic/new_id
fi

DEV_UUID=$(basename $(readlink /sys/class/net/eth1/device))
sudo "echo $DEV_UUID > /sys/bus/vmbus/drivers/hv_netvsc/unbind"
sudo "echo $DEV_UUID > /sys/bus/vmbus/drivers/uio_hv_generic/bind"
