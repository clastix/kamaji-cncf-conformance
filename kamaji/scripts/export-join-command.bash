#!/bin/bash

set -e

export CURRENT=$(pwd)

cd $(dirname $0)

source "../kamaji.env"
source "./lib.bash"

echo $TENANT_VERSION

create_join_command $TENANT_NAME $(get_internal_lb_address $TENANT_NAME):$TENANT_PORT
