#! /bin/bash

# Use driverctl to rebind eth1

DEV_UUID=$(basename $(readlink /sys/class/net/eth1/device))
driverctl -b vmbus set-override $DEV_UUID uio_hv_generic
