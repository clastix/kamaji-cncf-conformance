#!/bin/bash

set -e

cd $(dirname $0)

source "../azure.env"
source "./lib.bash"

echo "Setting Up Azure AKS"
create_resource_group $KAMAJI_RG $KAMAJI_REGION
create_vnet $KAMAJI_VNET_NAME $KAMAJI_VNET_ADDRESS $KAMAJI_RG
create_subnet $KAMAJI_VNET_NAME $KAMAJI_SUBNET_NAME $KAMAJI_SUBNET_ADDRESS $KAMAJI_RG
KAMAJI_SUBNET_ID=$(get_subnet_id $KAMAJI_VNET_NAME $KAMAJI_SUBNET_NAME $KAMAJI_RG)
create_aks $KAMAJI_CLUSTER $KAMAJI_REGION $KAMAJI_SUBNET_ID $KAMAJI_RG

echo "Get AKS Credentials"
get_aks_credentials $KAMAJI_CLUSTER $KAMAJI_RG

