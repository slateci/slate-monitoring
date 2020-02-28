#!/bin/bash

# Help message
if [ "$#" -ne 1 ]; then
    echo "Removes SLATE monitoring from the platform"
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

echo Delete the old grafana installation
helm delete grafana-slate --namespace $PLATFORM_NAMESPACE --kubeconfig $KUBECONFIG
sleep 5

echo Delete services
kubectl delete services query store-gateway --namespace $PLATFORM_NAMESPACE --kubeconfig $KUBECONFIG

echo Delete deployments
kubectl delete deployments thanos-query thanos-store --namespace $PLATFORM_NAMESPACE --kubeconfig $KUBECONFIG

echo Delete the secret with access information to the long term storage
kubectl delete secret slate-metrics-bucket --namespace $PLATFORM_NAMESPACE --kubeconfig $KUBECONFIG

echo Deleting platform namespace
kubectl delete namespace $PLATFORM_NAMESPACE --kubeconfig $KUBECONFIG


