#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"
source ../bin/common-platform.sh || exit 1
source ../sbin/global.param

kubectl delete pod $1 $2 $3 $4 $5 $6 $7 $8 $9 --force --grace-period=0 --namespace $PLATFORM_NAMESPACE --kubeconfig $PLATFORM_KUBECONFIG
