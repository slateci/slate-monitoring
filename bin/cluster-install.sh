#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"
source common-cluster.sh || exit 1

../sbin/cluster-install.sh $CLUSTER $KUBECONFIG ../private/bucket.yaml
