#!/bin/bash

# Help message
if [ "$#" -ne 1 ]; then
    echo "Removes SLATE monitoring from the cluster"
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

# Removing port for thanos-store
kubectl delete service/thanos-store --namespace $NAMESPACE --kubeconfig $KUBECONFIG

# Delete the old installation
helm delete --purge prometheus-operator --kubeconfig $KUBECONFIG
sleep 5

# Remove leftover crds
kubectl delete crd alertmanagers.monitoring.coreos.com prometheuses.monitoring.coreos.com  servicemonitors.monitoring.coreos.com prometheusrules.monitoring.coreos.com podmonitors.monitoring.coreos.com --kubeconfig $KUBECONFIG

# Delete the secret with access information to the long term storage
kubectl delete secret slate-metrics-bucket --namespace $NAMESPACE --kubeconfig $KUBECONFIG

# Deleting platform namespace
kubectl delete namespace $NAMESPACE --kubeconfig $KUBECONFIG

