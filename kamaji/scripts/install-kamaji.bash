#!/bin/bash

set -e

export CURRENT=$(pwd)

cd $(dirname $0)

source "../kamaji.env"
source "./lib.bash"

echo "Install Kamaji and prerequisites"

helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true

helm repo add clastix https://clastix.github.io/charts
helm repo update
helm install kamaji clastix/kamaji -n kamaji-system --create-namespace --set image.tag=$KAMAJI_VERSION