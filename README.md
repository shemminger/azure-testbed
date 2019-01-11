# Azure testbed

These scripts provide a simple way to setup a three machine network testbed on Azure with some common DPDK projects preloaded.

## Getting Started

All these scripts rely on the [Azure CLI][https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest] on Linux.

These instructions will show you how to set a simple 3 machine scenario using an existing Azure account.

```
$ az login
$ ./create-testbed dpdk upgrade install-dpdk
```

This will create the following:

![alt two machine plus bastion example][img/testbed.png"]

### Environment variables

This script can be customized to use different location or other Azure values by setting these environment variables:

 - AZURE_USER name used to prefix the resources (defaults to the username).
 - AZURE_LOCATION where to put the resources (defaults to westus).
 - AZURE_SKU machine type for the network hosts (defaults to D8s_v3)
 - AZURE_SSH_KEY - the public key file to see the bastion host with (defaults to .ssh/id_rsa.pub)

## Customizing

To add more post installation steps just add them to the scripts directory.
