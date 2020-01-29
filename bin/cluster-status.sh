#!/bin/bash

# Help message
if [ "$#" -ne 1 ]; then
    echo "Checks SLATE monitoring status on the cluster"
    echo
    echo "      $0 CLUSTER_NAME"
    echo
    echo "Example:  $0 umich-prod"
    exit -1
fi

cd "$( dirname "${BASH_SOURCE[0]}" )"
source common-cluster.sh || exit 1

../sbin/cluster-status.sh $KUBECONFIG
