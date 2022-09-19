#!/bin/bash

set -e

export CURRENT=$(pwd)

cd $(dirname $0)

source "../../kamaji/kamaji.env"

sonobuoy --kubeconfig=/tmp/$TENANT_NAME.kubeconfig run --mode=certified-conformance --wait=180
sonobuoy --kubeconfig=/tmp/$TENANT_NAME.kubeconfig retrieve --filename /tmp/$TENANT_NAME-sonobuoy-results.tar.gz
sonobuoy --kubeconfig=/tmp/$TENANT_NAME.kubeconfig delete
