#!/bin/bash

# Help message
if [ "$#" -ne 2 ]; then
    echo "Removes SLATE monitoring from the cluster"
    echo
    echo "      $0 KUBECONF_LOCATION MONITORING_NAMESPACE"
    echo
    echo "Example:  $0 ~/.kube/conf slate-monitoring"
    exit -1
fi

# Check helm exists
HELM_VERSION=`helm version --short`
if [ "$?" -ne 0 ]; then
    echo "Unable to locate helm in the search path"
    echo
    echo "If it is not installed, you can download it from https://github.com/helm/helm/releases"
fi

# Get input parameters
KUBECONF_LOCATION=`realpath $1`
MONITORING_NAMESPACE=$2

# Move to script directory
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Delete the old installation
helm delete prometheus-operator --namespace $MONITORING_NAMESPACE --kubeconfig $KUBECONF_LOCATION
sleep 5

# Delete the secret with access information to the long term storage
kubectl delete secret slate-metrics-bucket --namespace $MONITORING_NAMESPACE --kubeconfig $KUBECONF_LOCATION

# Deleting platform namespace
kubectl delete namespace $MONITORING_NAMESPACE --kubeconfig $KUBECONF_LOCATION
