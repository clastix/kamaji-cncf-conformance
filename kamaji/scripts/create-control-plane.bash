#!/bin/bash

set -e

export CURRENT=$(pwd)

cd $(dirname $0)

source "../kamaji.env"
source "./lib.bash"

echo "Creating Control Plane for Tenant"
create_tenant_controlplane $TENANT_NAME $TENANT_DOMAIN $TENANT_VERSION $TENANT_PORT $TENANT_PROXY_PORT
sleep 30
get_tenants
