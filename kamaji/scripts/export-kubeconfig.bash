#!/bin/bash

set -e

export CURRENT=$(pwd)

cd $(dirname $0)

source "../kamaji.env"
source "./lib.bash"

echo $TENANT_VERSION

create_kubeconfig $TENANT_NAME $TENANT_DOMAIN
