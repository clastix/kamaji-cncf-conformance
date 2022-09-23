#!/bin/bash

function login() {
    print_action "Log into Azure"
    az login
}

function create_resource_group() {
    RG_NAME=$1
    LOCATION=$2
    az group create --location $LOCATION --name $RG_NAME 
}

function destroy_resource_group() {
    RG_NAME=$1
    az group delete --name $RG_NAME --yes --no-wait
}

function create_nsg() {
    NSG_NAME=$1
    RG=$2

    az network nsg create \
        --resource-group $RG \
        --name $NSG_NAME

    az network nsg rule create \
        --resource-group $RG \
        --nsg-name $NSG_NAME \
        --name $NSG_NAME-ssh \
        --protocol tcp \
        --priority 1000 \
        --destination-port-range 22 \
        --access allow
}

function create_vnet() {
    VNET_NAME=$1
    VNET_ADDRESS=$2
    RG=$3

    az network vnet create \
        --resource-group $RG \
        --name $VNET_NAME \
        --address-prefix $VNET_ADDRESS
}

function create_subnet() {
    VNET_NAME=$1
    SUBNET_NAME=$2
    SUBNET_ADDRESS=$3
    RG=$4

    az network vnet subnet create \
    --resource-group $RG \
    --vnet-name $VNET_NAME \
    --name $SUBNET_NAME \
    --address-prefixes $SUBNET_ADDRESS
}

function get_subnet_id() {
    VNET_NAME=$1
    SUBNET_NAME=$2
    RG=$3

    echo $(az network vnet subnet show \
    --resource-group ${RG} \
    --vnet-name ${VNET_NAME} \
    --name ${SUBNET_NAME} \
    --query id --output tsv)
}

function create_aks() {
    AKS_NAME=$1
    REGION=$2
    SUBNET_ID=$3
    RG=$4

    az aks create \
    --name $AKS_NAME \
    --location $REGION \
    --zones 1 2 3 \
    --node-count 3 \
    --nodepool-name $AKS_NAME \
    --vnet-subnet-id $SUBNET_ID \
    --resource-group $RG \
    --generate-ssh-keys --yes 

    az aks wait --resource-group $RG --name $AKS_NAME --created --interval 60 --timeout 600
    az aks show --resource-group $RG --name $AKS_NAME
}

function get_aks_credentials() {
    AKS_NAME=$1
    RG=$2

    az aks get-credentials  \
    --resource-group $RG \
    --name $AKS_NAME \
    --overwrite-existing

    kubectl cluster-info
}

function create_vmss() {
    VMSS_NAME=$1
    VM_IMAGE=$2
    VNET_NAME=$3
    SUBNET_NAME=$4
    RG=$5

    az vmss create \
        --name $VMSS_NAME \
        --resource-group $RG \
        --image $VM_IMAGE \
        --vnet-name $VNET_NAME \
        --subnet $SUBNET_NAME \
        --computer-name-prefix $VMSS_NAME- \
        --custom-data ../config/cloudinit.yaml \
        --load-balancer "" \
        --instance-count 0 
    az vmss wait --created --name $VMSS_NAME --resource-group $RG
}

function update_vmss() {
    VMSS_NAME=$1
    RG=$2
    az vmss update \
        --resource-group $RG \
        --name $VMSS_NAME \
        --set virtualMachineProfile.networkProfile.networkInterfaceConfigurations[0].enableIPForwarding=true
    az vmss wait --updated --name $VMSS_NAME --resource-group $RG
}

function scale_vmss() {
    VMSS_NAME=$1
    CAPACITY=$2
    RG=$3

    az vmss scale \
        --resource-group $RG \
        --name $VMSS_NAME \
        --new-capacity $CAPACITY
    az vmss wait --custom provisioningState!='InProgress' --name $VMSS_NAME --resource-group $RG
    az vmss list --resource-group $RG --output table
}

function vmss_run_command() {
    VMSS_NAME=$1
    COMMAND=$2
    echo "Running command: $COMMAND"
    RG=$3

    VMIDS=($(az vmss list-instances \
    --resource-group $RG \
    --name $VMSS_NAME \
    --query [].instanceId \
    --output tsv))

    for i in ${!VMIDS[@]}; do
    VMID=${VMIDS[$i]}

    az vmss wait \
        --updated \
        --instance-id ${VMID} \
        --name $VMSS_NAME \
        --resource-group $RG

    az vmss run-command create \
	    --name kubeadm-join-command \
        --vmss-name $VMSS_NAME \
	    --resource-group $RG \
	    --instance-id ${VMID} \
	    --script "${COMMAND}"
done

}
