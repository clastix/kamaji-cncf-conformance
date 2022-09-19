#!/bin/bash

set -e

cd $(dirname $0)

source "../azure.env"
source "./lib.bash"

echo "Setting Up Azure VMs for Tenant Workers"
create_subnet $KAMAJI_VNET_NAME $TENANT_SUBNET_NAME $TENANT_SUBNET_ADDRESS $KAMAJI_RG
create_vmss $TENANT_VMSS_NAME $TENANT_VM_IMAGE $KAMAJI_VNET_NAME $TENANT_SUBNET_NAME $KAMAJI_RG
update_vmss $TENANT_VMSS_NAME $KAMAJI_RG
scale_vmss $TENANT_VMSS_NAME 3 $KAMAJI_RG
