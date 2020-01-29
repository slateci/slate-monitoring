#!/bin/bash

# Help message
if [ "$#" -ne 1 ]; then
    echo "Removes SLATE monitoring from the cluster"
    echo
    echo "      $0 CLUSTER_NAME"
    echo
    echo "Example:  $0 umich-prod"
    exit -1
fi

cd "$( dirname "${BASH_SOURCE[0]}" )"
source common-cluster.sh || exit 1

../sbin/cluster-delete.sh $KUBECONFIG
