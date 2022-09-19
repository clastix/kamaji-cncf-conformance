#!/bin/bash

set -e

cd $(dirname $0)

source "../azure.env"
source "./lib.bash"

echo "Destroy Resource Group $KAMAJI_RG"
destroy_resource_group $KAMAJI_RG

