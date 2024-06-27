#!/bin/bash

set -e

cd $(dirname $0)

source "../azure.env"
source "./lib.bash"

echo "Join Azure VMs as Tenant Workers"
JOIN_CMD="sudo apt install -y kubelet=${TENANT_VERSION:1}-1.1 kubeadm=${TENANT_VERSION:1}-1.1 && "$(cat /tmp/$TENANT_NAME-join.cmd)
vmss_run_command $TENANT_VMSS_NAME "$JOIN_CMD" $KAMAJI_RG

