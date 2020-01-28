#!/bin/bash

# Help message
if [ "$#" -ne 1 ]; then
    echo "Checks SLATE monitoring status on the cluster"
    echo
    echo "      $0 KUBECONF_LOCATION"
    echo
    echo "Example:  $0 ~/.kube/conf"
    exit -1
fi

# Get input parameters
KUBECONFIG=`realpath $1`

# Move to script directory
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Get global parameters
source global.param

kubectl get pods --namespace $NAMESPACE --kubeconfig $KUBECONFIG
kubectl get services --namespace $NAMESPACE --kubeconfig $KUBECONFIG
