#!/bin/bash

set -e

export CURRENT=$(pwd)

cd $(dirname $0)

source "../kamaji.env"
source "./lib.bash"

echo "Install Calico as CNI for Tenant Cluster"
kubectl --kubeconfig=/tmp/$TENANT_NAME.kubeconfig apply -f ../manifests/calico.yaml
kubectl --kubeconfig=/tmp/$TENANT_NAME.kubeconfig wait --for=condition=Ready nodes --all --timeout=120s

